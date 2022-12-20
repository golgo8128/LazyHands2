
package RS.MassSpec;

import java.io.DataOutputStream;
import java.io.IOException;

public class MassSpecrum_simple1_2 <T_mz, T_intst>{

	public T_mz[] mzs;
	public T_intst[] intsts;

	public void output_to_file(DataOutputStream fw) throws IOException {
		
		for(T_mz mz : this.mzs) {
				this.output_to_file_each_mz(fw, mz); // Big endian
		}
		for(T_intst intsty : this.intsts) {
				this.output_to_file_each_intst(fw, intsty); // Big endian
		}
		
	}
	
	
	public int bytesize_ms() {
		
		return this.bytesize_mzs() + this.bytesize_intsts();
		
	}
	
	
	public int bytesize_mzs() 
		throws IllegalArgumentException {

		int oval;
		
		if(this.mzs.length > 0) {
			T_mz mz1st = this.mzs[0];

			if(Integer.class.isInstance(mz1st)){
				oval = 4 * this.mzs.length;
			} else if (Float.class.isInstance(mz1st)) {
				oval = 4 * this.mzs.length;
			} else if (Double.class.isInstance(mz1st)) {
				oval = 8 * this.mzs.length;
			} else if (Long.class.isInstance(mz1st)) {
				oval = 8 * this.mzs.length;
			}
			else {
				throw new IllegalArgumentException("Illegal data type for m/z's.");
			}
		}
		
		else {
			oval = 0;
		}
			
		return(oval);
		
	}

	public int bytesize_intsts() 
			throws IllegalArgumentException {

			int oval;
			
			if(this.intsts.length > 0) {
				T_intst intsts1st = this.intsts[0];

				if(Integer.class.isInstance(intsts1st)){
					oval = 4 * this.intsts.length;
				} else if (Float.class.isInstance(intsts1st)) {
					oval = 4 * this.intsts.length;
				} else if (Double.class.isInstance(intsts1st)) {
					oval = 8 * this.intsts.length;
				} else if (Long.class.isInstance(intsts1st)) {
					oval = 8 * this.intsts.length;
				} else {
					throw new IllegalArgumentException("Illegal data type for intensities.");
				}
			}
			
			else {
				oval = 0;
			}
				
			return(oval);
			
		}	
	
	
	public void output_to_file_each_mz (
			DataOutputStream fw,
			T_mz val)
			throws IOException, IllegalArgumentException {
		
		if(Integer.class.isInstance(val)){
			fw.writeInt((int) val);
		} else if(Float.class.isInstance(val)) {
			fw.writeFloat((float) val);
		} else if(Double.class.isInstance(val)) {
			fw.writeDouble((double) val);
		} else if(Long.class.isInstance(val)) {
			fw.writeLong((long) val);
		} else {
			throw new IllegalArgumentException("Writing to file failed.");
		}
		
	}
	
	public void output_to_file_each_intst (
			DataOutputStream fw,
			T_intst val)
			throws IOException, IllegalArgumentException {
		
		if(Integer.class.isInstance(val)){
			fw.writeInt((int) val);
		} else if(Float.class.isInstance(val)) {
			fw.writeFloat((float) val);
		} else if(Double.class.isInstance(val)) {
			fw.writeDouble((double) val);
		} else if(Long.class.isInstance(val)) {
			fw.writeLong((long) val);
		} else {
			throw new IllegalArgumentException("Writing to file failed.");
		}
		
	}
	
		
}
