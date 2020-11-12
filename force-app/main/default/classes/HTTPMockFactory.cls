@isTest
public class HTTPMockFactory implements HttpCalloutMock {
  private Integer code;
  private String status;
  private String body;
    
  public HTTPMockFactory(Integer code, String status, String body) {
    this.code = code;
    this.status = status;
    this.body = body;
  }
  public HTTPResponse respond(HTTPRequest req) {
    HttpResponse res = new HttpResponse();
    
    res.setBody(this.body);
    res.setStatusCode(this.code);
    res.setStatus(this.status);
    return res;
  }
}