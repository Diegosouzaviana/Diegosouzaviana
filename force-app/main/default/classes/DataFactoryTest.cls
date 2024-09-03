@IsTest
public class DataFactoryTest {
@TestSetup
public static void makeData(){
//createWorkOrderAndServiceAppointment();
Id adminProfileId = [SELECT Id 
                    FROM Profile 
                    WHERE Name = 'Administrador do sistema' 
                    OR Name = 'System Administrator'
                    LIMIT 1].Id;
User adminUser = new User(
    ProfileId = adminProfileId,
    FirstName = 'System',
    LastName = 'Administrator',
    UserName = System.now().getTime() + '@sse.demo',
    Alias = 'sadmin',
    Email = 'swetha@sse.demo',
    EmailEncodingKey = 'UTF-8',
    LanguageLocaleKey = 'en_US',
    LocaleSidKey = 'nl_NL',
    TimeZoneSidKey = UserInfo.getTimeZone().getID(),
    UserPermissionsSupportUser = true
);

// Add FSL Admin Permissions if not already to running user (assuming admin)
System.runAs(adminUser){
    // Lookup the Field Service Admin Permissions permission set
    PermissionSet psSFSAdmin = [
        select Id from PermissionSet where Name ='FSL_Admin_Permissions'];

    // Associate it to the current user
    try {
        insert new PermissionSetAssignment(
            PermissionSetId = psSFSAdmin.Id,
            AssigneeId = UserInfo.getUserId()
        );
    } catch (Exception e) {
        // Perm set already assigned, continue
    }
}        
// Create foundation records for scheduling
FSL__Scheduling_Policy__c sp = new FSL__Scheduling_Policy__c(
    Name = 'Policy For Testing'
);
insert sp;
List<OperatingHours> ohs = new List<OperatingHours>();
// Operating Hours for availability
OperatingHours ohAvailability = new OperatingHours(
    Name = 'Availability Hours',
    TimeZone = UserInfo.getTimeZone().getID()
);
ohs.add(ohAvailability);
// Operating Hours for time slots
OperatingHours ohTimeSlots = new OperatingHours(
    Name = 'Time Slot Hours',
    TimeZone = UserInfo.getTimeZone().getID()
);
ohs.add(ohTimeSlots);
insert ohs;
System.debug('ohTimeSlots.Id '+ohTimeSlots.Id);
System.debug('ohAvailability.Id '+ohAvailability.Id);
// monday tuesday wednesday thursday friday saturday sunday
// Create time slots for operating hours
List<TimeSlot> timeSlots = new List<TimeSlot>();
timeSlots.add(new TimeSlot(
    OperatingHoursId = ohAvailability.Id,
    DayOfWeek = 'Monday',
    StartTime = Time.newInstance(8,0,0,0),
    EndTime = Time.newInstance(17,0,0,0)
));
timeSlots.add(new TimeSlot(
    OperatingHoursId = ohAvailability.Id,
    DayOfWeek = 'Tuesday',
    StartTime = Time.newInstance(8,0,0,0),
    EndTime = Time.newInstance(17,0,0,0)
));
timeSlots.add(new TimeSlot(
    OperatingHoursId = ohAvailability.Id,
    DayOfWeek = 'Wednesday',
    StartTime = Time.newInstance(08,0,0,0),
    EndTime = Time.newInstance(17,0,0,0)
));
timeSlots.add(new TimeSlot(
    OperatingHoursId = ohAvailability.Id,
    DayOfWeek = 'Thursday',
    StartTime = Time.newInstance(08,0,0,0),
    EndTime = Time.newInstance(17,0,0,0)
));
timeSlots.add(new TimeSlot(
    OperatingHoursId = ohAvailability.Id,
    DayOfWeek = 'Friday',
    StartTime = Time.newInstance(08,0,0,0),
    EndTime = Time.newInstance(17,0,0,0)
));
timeSlots.add(new TimeSlot(
    OperatingHoursId = ohAvailability.Id,
    DayOfWeek = 'Saturday',
    StartTime = Time.newInstance(08,0,0,0),
    EndTime = Time.newInstance(17,0,0,0)
));
timeSlots.add(new TimeSlot(
    OperatingHoursId = ohAvailability.Id,
    DayOfWeek = 'Sunday',
    StartTime = Time.newInstance(08,0,0,0),
    EndTime = Time.newInstance(17,0,0,0)
));

insert timeSlots; 

// Create Service Territory
ServiceTerritory st = new ServiceTerritory(
    Name = 'Test Service Territory',
    isActive = true,
    Street = 'Kerstraat 1',
    PostalCode = '1017 GA',
    City = 'Amsterdam',
    Country = 'NL',
    NotificationEmailCOP__c = 'thiago.silva@sys4b.com.br',
    NotificationEmailFM__c = 'kaymon.storino@sys4b.com.br', 
    NotificationEmailFS__c = 'thiago.fernandes@sys4b.com.b',
    Break__c = '60 Minutos',
    OperatingHoursId = ohAvailability.Id
);
insert st;
ServiceTerritory st2 = new ServiceTerritory(
    Name = 'Test Service Territory 2',
    isActive = true,
    Street = '',
    PostalCode = '30110-001',
    City = 'Belo Horizonte',
    Country = 'MG',
    NotificationEmailCOP__c = 'thiago.silva@sys4b.com.br',
    NotificationEmailFM__c = 'kaymon.storino@sys4b.com.br', 
    NotificationEmailFS__c = 'thiago.fernandes@sys4b.com.b',
    Break__c = '60 Minutos',
    OperatingHoursId = ohAvailability.Id
);
insert st2;
// Create user for a field technician resource with the right permission sets
System.runAs(adminUser){
    Id profileId = [select Id from Profile where Name LIKE 'Técnico de Campo%' limit 1].Id;
    User tech = new User(
        ProfileId = profileId,
        FirstName = 'Integração',
        LastName = 'Desktop',
        UserName = 'integracao@desktop.net.br',
        Alias = 'tsttech1',
        Email = 'tsttech1@ftech.demo',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'nl_NL',
        TimeZoneSidKey = UserInfo.getTimeZone().getID(),
        UserPermissionsSupportUser = true
    );
    insert tech;
     
    List<PermissionSet> sfsPermSets = [select Id from PermissionSet where Name = 'FSL_Resource_Permissions' OR Name ='FSL_Resource_License'];
    
    List<PermissionSetAssignment> permSetAssigns = new List<PermissionSetAssignment>();
    for (PermissionSet sfsPermSet : sfsPermSets){
        permSetAssigns.Add(
            new PermissionSetAssignment(
                PermissionSetId = sfsPermSet.Id,
                AssigneeId = tech.Id
            )
        );
    }

    insert permSetAssigns;
    ServiceResource sr = new ServiceResource(
        Name = tech.FirstName + ' ' + tech.LastName,
        isActive = true,
        IsOptimizationCapable = true, // This is important otherwise the resource is not available for scheduling
        ResourceType = 'T',
        RelatedRecordId = tech.Id,
        CPF__c = '28869941035',
        email__c = 'tsttech1@ftech.demo'
    );
    insert sr;
    // Make resource part of the service territory
    insert new ServiceTerritoryMember(
        ServiceTerritoryId = st.Id,
        ServiceResourceId = sr.Id,
        TerritoryType = 'P',
        EffectiveStartDate = System.now().addDays(-3)
    );

    // Create Work Type record 
    List<WorkType> WorkTypeList = new List<WorkType>();
    WorkTypeList.add(
        new WorkType(
            Name = 'Maintenance',
            ShouldAutoCreateSvcAppt = true,
            FSL__Due_Date_Offset__c = 60*24*7, // 1 week in minutes
            DurationType = 'Minutes',
            EstimatedDuration = 60
        )
    );
    WorkTypeList.add(
        new WorkType(
            Name = 'Alteração de Plano - Alteração de Velocidade',
            Work_Type_WT__c = 'Alteração de Plano',
            Work_Subtype_WT__c = 'Alteração de Velocidade',
            ShouldAutoCreateSvcAppt = true,
            FSL__Due_Date_Offset__c = 60*24*7, // 1 week in minutes
            DurationType = 'Minutes',
            EstimatedDuration = 60
        )
    );
    insert WorkTypeList; 

    insert new Account(
      
        Name = 'New Account Name',
        CNPJ__c = '49401667000196',
        LXD_CPF__c = '40094880001',
        LXD_Email__c='teste@gmail.com'
    );
}

}

@IsTest
public static void startTest(){
// Retrieve Work Type Id
Id wtId = [select Id from WorkType where Name = 'Maintenance'].Id;
Id accId = [select Id from Account where Name = 'New Account Name'].Id;

// Create Work Order. Service Appointment is created via the Work Type
WorkOrder wo = new WorkOrder(
    AccountId = accId,
    WorkTypeId = wtId,
    Subject = 'Test',
    Street = 'Kerkstraat 2',
    PostalCode = '3581 RD',
    City = 'Utrecht',
    Country = 'NL',
    State = 'AM'
);
insert wo;

// Get the details for getSlots
OperatingHours oh = [select Id, TimeZone from OperatingHours where Name = 'Time Slot Hours'];
Timezone tz = Timezone.getTimeZone(oh.TimeZone);
Id spId = [select Id from FSL__Scheduling_Policy__c limit 1].Id;

Test.startTest();
System.debug('starting test...');
Id saId = [select Id from ServiceAppointment where ParentRecordId = :wo.Id].Id;
System.debug('saId '+saId);
// List<FSL.AppointmentBookingSlot> slots = FSL.AppointmentBookingService.getSlots(saId, spId, oh.Id, tz, false);  

// System.debug(slots);
Test.stopTest();
}

@IsTest
public static void DeleteBookAppointment() {
Id wtId = [select Id from WorkType where Name = 'Maintenance'].Id;
Id accId = [select Id from Account where Name = 'New Account Name'].Id;

WorkOrder wo = new WorkOrder(
    AccountId = accId,
    WorkTypeId = wtId,
    Subject = 'Test DeleteBookAppointment',
    Street = 'Kerkstraat 2',
    PostalCode = '3581 RD',
    City = 'Utrecht',
    Country = 'NL',
    State = 'CL'
);
insert wo;

ServiceAppointment sa = [select Id, Status from ServiceAppointment where ParentRecordId = :wo.Id];
System.debug('status in DeleteBookAppointment '+sa.Status);
}
}