@isTest
public class ScheduleFactory {
	@isTest
    public static Schedule__c makeData(){
        Schedule__c lSchedule = new Schedule__c();
        lSchedule.Frequency__c = '10 dias';
        Insert lSchedule;
        
        SchedulingDay__c lSchedulingDay = new SchedulingDay__c();
        lSchedulingDay.Schedule__c = lSchedule.Id;
        lSchedulingDay.PayDay__c = system.today();
        insert lSchedulingDay;
        
        return lSchedule;
    }
}