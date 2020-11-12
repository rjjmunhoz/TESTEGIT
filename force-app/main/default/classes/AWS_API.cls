/**************************************************************************************************************
* Avanxo Brasil
* @author           Eduardo Costa (eduardo.borges@globant.com)
* Project:          Porto Socorro
* Description:      Classe para consumo das APIs fornecidas pelo AWS Porto Socorro
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-12-05      Eduardo Costa           class created 
**************************************************************************************************************/
public abstract class AWS_API {
	
    private static final String tokenCache = Label.TokenAWSEndPoint;
    private static final String partitionName = Label.Partition_PortoSocorro;
 
	protected transient HttpRequest fReq;
	private static String fEndpointName;

	private static final Map<String,WebserviceConfiguration__mdt> fWebserviceConfigurationMap {
        get {
            if(fWebserviceConfigurationMap != null && fWebserviceConfigurationMap.containsKey(fEndpointName)) {
                return fWebserviceConfigurationMap;
            }
            else {
                if(fWebserviceConfigurationMap == null) fWebserviceConfigurationMap = new Map<String,WebserviceConfiguration__mdt>();
				for(WebserviceConfiguration__mdt lWebserviceConfiguration :[SELECT EndPoint__c, Method__c, Timeout__c FROM WebserviceConfiguration__mdt 
						WHERE DeveloperName = :fEndpointName AND DeveloperName NOT IN :fWebserviceConfigurationMap.keySet()]) {
					fWebserviceConfigurationMap.put(fEndpointName, lWebserviceConfiguration);
                }
                return fWebserviceConfigurationMap;
            }            
        }
        set;
    }

	public AWS_API(String aEndpointName){
		fEndpointName = aEndpointName;
		WebserviceConfiguration__mdt lWebserviceConfiguration = fWebserviceConfigurationMap.get(aEndpointName);
		if(lWebserviceConfiguration != null) {
			this.fReq = this.getRequest(lWebserviceConfiguration.Method__c, lWebserviceConfiguration.Timeout__c, lWebserviceConfiguration.EndPoint__c);
		}
        else {
            this.fReq = this.getRequest('GET', 120000, '');
        }
	}	
	
	public HttpRequest getRequest(String aMethod, Decimal aTimeout, String aEndpoint) {
		HttpRequest lRequest = new HttpRequest();
		// lRequest.setEndpoint('callout:AWS' + aEndpoint);
		lRequest.setEndpoint(aEndpoint);
		lRequest.setMethod(aMethod); 
		lRequest.setHeader(Label.String_Content_Type, Label.String_Application_JSON);
		lRequest.setTimeout(Integer.valueOf(aTimeout));
		return lRequest;
	}

  	public ResponseWrapper doRequest() {
  		ResponseWrapper lRespWr = new ResponseWrapper();
		Http lHttp = new Http();
		try{
            String lToken = getToken(false);
            system.debug('###lToken ' + lToken);
			this.fReq.setHeader(Label.String_Authorization, lToken!=null?lToken:'');
			system.debug('###Endpoint ' + this.fReq.getEndpoint());
			lRespWr.response = lHttp.send(this.fReq);
			system.debug('this.fReq ' + this.fReq.getBody());
			System.debug('StatusCode ' + lRespWr.response.getStatusCode());
			// System.debug('Result ' + lRespWr.response.getBody());	
			// Se retornar 401(Unauthorized) força a atualização do token no cache 		
			if (lRespWr.response.getStatusCode() == 401) {
				this.fReq.setHeader(Label.String_Authorization, getToken(true));
				lRespWr.response = lHttp.send(this.fReq);
			}			
			if (lRespWr.response.getStatusCode() != 200 && lRespWr.response.getStatusCode() != 201) {
				lRespWr.success = false; 
				lRespWr.message = lRespWr.response.getStatusCode() + '-' + lRespWr.response.getStatus() + '-' + lRespWr.response.getBody();				
			}
		}
		catch(System.CalloutException e){lRespWr.success = false; lRespWr.message = e.getMessage();}
		return lRespWr;
	}

	public static String getToken(Boolean refreshToken) {		
		Cache.OrgPartition lPartition = Cache.Org.getPartition(partitionName);
		String token = (String)lPartition.get(tokenCache);
        if (token != null && !refreshToken) {
            return token;
        } else {
            List<WebserviceConfiguration__mdt> lWebserviceConfigurationLst = [SELECT  GrantType__c, EndPoint__c, Timeout__c, 
					Method__c, ClientId__c, Scopes__c, ClientSecret__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :tokenCache];
			
			if(lWebserviceConfigurationLst.isEmpty()) return null;

			HttpRequest lRequest = new HttpRequest();
			lRequest.setEndpoint(lWebserviceConfigurationLst[0].EndPoint__c);
			lRequest.setMethod(lWebserviceConfigurationLst[0].Method__c); 
			lRequest.setHeader(Label.String_Content_Type, Label.String_Application_Form);
			lRequest.setTimeout(Integer.valueOf(lWebserviceConfigurationLst[0].Timeout__c));			
			
			String lPayload = Label.RequestBody_ClientId+EncodingUtil.urlEncode(lWebserviceConfigurationLst[0].ClientId__c,Label.String_UTF8) +
							Label.RequestBody_ClientSecret+EncodingUtil.urlEncode(lWebserviceConfigurationLst[0].ClientSecret__c,Label.String_UTF8) +
							Label.RequestBody_Scopes+EncodingUtil.urlEncode(lWebserviceConfigurationLst[0].Scopes__c,Label.String_UTF8) +
							Label.RequestBody_GrantType + lWebserviceConfigurationLst[0].GrantType__c;

			lRequest.setBody(lPayload);

			Http lHttp = new Http();
			try{
				HttpResponse lResp = lHttp.send(lRequest);
				if (lResp.getStatusCode() == 200) {
					TokenWrapper lToken = (TokenWrapper) System.JSON.deserialize(lResp.getBody(), TokenWrapper.class);	
					Integer lSecondsLifetime = lToken.expires_in;
					lPartition.put(tokenCache, lToken.access_token, lSecondsLifetime<300?300:lSecondsLifetime, Cache.Visibility.ALL, false);
					return lToken.access_token;
				}
			}
			catch(System.CalloutException e){
				// Armazenar o erro no objeto de log
				system.debug('Get Token Exception: ' + e.getMessage());
			}				
        }	
		return null;	
	}

	public class ResponseWrapper {
		public HttpResponse response;
		public Boolean success;
		public String message;

		public ResponseWrapper() {
			this.response = new HttpResponse();
			this.success = true;
			this.message = '';
		}
	}

	public class TokenWrapper {
		public String access_token;
		public Integer expires_in;
		public String token_type;
	}
}