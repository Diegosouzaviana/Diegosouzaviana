public class ScheduledServiceAppointmentClass {
  	public void schedule() {
		DateTime dt = DateTime.now();
		String dateTimeStr = dt.format('yyyy/MM/dd hh:mm:ss');

		//System.schedule('ScheduledServiceAppointment 1 '+dateTimeStr, '0 54 10 * * ?', new ScheduledServiceAppointment());
		System.schedule('ScheduledServiceAppointment 1 '+dateTimeStr, '0 00 09 * * ?', new ScheduledServiceAppointment());
		System.schedule('ScheduledServiceAppointment 2 '+dateTimeStr, '0 00 12 * * ?', new ScheduledServiceAppointment());
		System.schedule('ScheduledServiceAppointment 3 '+dateTimeStr, '0 00 15 * * ?', new ScheduledServiceAppointment());
		System.schedule('ScheduledServiceAppointment 4 '+dateTimeStr, '0 00 18 * * ?', new ScheduledServiceAppointment());
		System.schedule('ScheduledServiceAppointment 5 '+dateTimeStr, '0 00 21 * * ?', new ScheduledServiceAppointment());
    }
}