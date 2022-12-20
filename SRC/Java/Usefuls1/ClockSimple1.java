package RS.Usefuls1;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class ClockSimple1 {

	static public String current_time(String itime_format) {

		LocalDateTime date1 = LocalDateTime.now();
		DateTimeFormatter dtformat = 
				DateTimeFormatter.ofPattern(itime_format);
		String fdate1 = dtformat.format(date1);

		return fdate1;
		
	}

}
