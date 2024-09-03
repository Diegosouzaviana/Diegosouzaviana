public class AppointmentBookingRequestWrapper {
    
    public Id ServiceAppointment {get;set;}

    public static AppointmentBookingRequestWrapper parse(String json) {
        return (AppointmentBookingRequestWrapper) System.JSON.deserialize(json, AppointmentBookingRequestWrapper.class);
    }
}