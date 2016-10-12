public class LightMsg extends net.tinyos.message.Message {
	
    /** The default size of this message type in bytes. */
    public static final int DEFAULT_MESSAGE_SIZE = 60;
    
    /** The Active Message type associated with this message. */
    public static final int AM_TYPE = 6;
    
    public LightMsg() {
        super(DEFAULT_MESSAGE_SIZE);
	amTypeSet(AM_TYPE);
    }
    
    public int getElement_readings(int i) {
        return (int)getUIntBEElement(offsetBits_readings(i), 16);
    }
    
    public static int offsetBits_readings(int i) {
        return i * 16;
    }
}
