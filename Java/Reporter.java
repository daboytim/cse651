import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;
import java.io.*;
import java.sql.Timestamp;

public class Reporter implements MessageListener {
    
    MoteIF mote;
    FileWriter f;
    Timestamp time;
    final int NSAMPLES = 30;
    String filename;
    
    public Reporter(MoteIF mif, String filename) {
	this.mote = mif;
	this.mote.registerListener(new LightMsg(), this);
	this.filename = filename;
    }
    
    public synchronized void messageReceived(int to, Message msg) {
	if (msg instanceof LightMsg) {
	    try {
		f = new FileWriter(filename, true);
		BufferedWriter out = new BufferedWriter(f);
	        LightMsg lmsg = (LightMsg) msg;
		out.write(new Timestamp(System.currentTimeMillis()).toString() + ':');
		for (int i = 0; i < NSAMPLES; i++) {
		    // write a line containing reading and timestamp to output file
		    out.write(lmsg.getElement_readings(i) + " ");
		}
		out.write("\n");
		out.close();
	    } catch (Exception e) {
		e.printStackTrace();
	    }
	}
    }
    public static void main(String[] args) {
	String source = "serial@/dev/ttyUSB0:telosb";
	PhoenixSource phoenix;
	phoenix = BuildSource.makePhoenix(source, null);
	MoteIF mif = new MoteIF(phoenix);
	Reporter me = new Reporter(mif, args[0]);
    }
}
