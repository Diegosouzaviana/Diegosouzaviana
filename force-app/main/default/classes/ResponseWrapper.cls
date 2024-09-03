public class ResponseWrapper {
    // public String chave_ext {get;set;}
    // public String status {get;set;}
    // public String message {get;set;}

    // public ResponseWrapper(String chave_ext, String status, String msg) {
    //     this.chave_ext  = chave_ext;
    //     this.status     = status;
    //     this.message    = msg;
    // }

    public class GetBookingSlot {
        public Integer Slot {get;set;}
        public DateTime Start {get;set;}
        public DateTime Finish {get;set;}
        public Decimal Grade {get;set;}
    
        public GetBookingSlot(Integer Slot, DateTime Start, DateTime Finish, Decimal Grade) {
            this.Slot = Slot;
            this.Start = Start;
            this.Finish = Finish;
            this.Grade = Grade;
        }
    }


    public class BookingSlot {
        public String ServiceAppointment {get;set;}
        public String Status {get;set;}
        public String Message {get;set;}

        public BookingSlot(String sA, String status, String message) {
            this.ServiceAppointment = sA;
            this.Status = status;
            this.Message = message;
        }
    }
}