package RS.MassSpec;

import java.io.BufferedOutputStream;
import java.io.DataOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;

public class RS_MassSpectra_simple1_5 <T_mtime, T_mz, T_intst>{

	public ArrayList<T_mtime> mtimes;
	public ArrayList<MassSpecrum_simple1_2<T_mz, T_intst>> mspecs;
	private char vartype_symb_relpos;
	
	public RS_MassSpectra_simple1_5() {
		
		this.mtimes   = new ArrayList<T_mtime>();
		this.mspecs   = new ArrayList<MassSpecrum_simple1_2<T_mz, T_intst>>();
		this.vartype_symb_relpos = 'i';
		
	}	

	public void set_vartype_symb_relpos(char ivartype_symb_relpos) {
		
		if(ivartype_symb_relpos != 'i' && ivartype_symb_relpos != 'x'){
			throw new IllegalArgumentException(String.format(
					"Illegal data type for relative position : %c",
					ivartype_symb_relpos));
		}
		
		this.vartype_symb_relpos = ivartype_symb_relpos;
	}
	
	public void add_ms(T_mtime imt, MassSpecrum_simple1_2<T_mz, T_intst> ms){
		
		this.mtimes.add(imt);
		this.mspecs.add(ms);

	}
	
	public void add_ms(T_mtime imt, T_mz[] mzs, T_intst[] intsts){
		
		this.mtimes.add(imt);
		
		MassSpecrum_simple1_2<T_mz, T_intst> ms = new MassSpecrum_simple1_2<T_mz, T_intst>();
		ms.mzs    = mzs;
		ms.intsts = intsts;
		this.mspecs.add(ms);

	}
	
	
	public void output_to_file(Path opath, int foffset_byte_size) throws IOException {
		
		Files.createDirectories(opath.getParent());
		
		DataOutputStream fw = new DataOutputStream(
				new BufferedOutputStream(new FileOutputStream(opath.toString())));
		
		this.write_foffset(fw, foffset_byte_size);
		fw.writeInt(this.mtimes.size());
		this.write_header_to_file(fw, foffset_byte_size);
		
		for(MassSpecrum_simple1_2<T_mz, T_intst>mspec : this.mspecs) {
			mspec.output_to_file(fw);			
		}
		
		fw.close();
		
	}

	public int get_header_bytes(int foffset_byte_size)
			throws IllegalArgumentException {
		
		if(this.mtimes.size() == 0) {
			return foffset_byte_size;
		}
		
		T_mtime mt_1st = this.mtimes.get(0);
		int mtime_byte_size;
		
		if(Integer.class.isInstance(mt_1st)){
			mtime_byte_size = 4;
		} else if (Float.class.isInstance(mt_1st)) {
			mtime_byte_size = 4;
		} else if (Double.class.isInstance(mt_1st)) {
			mtime_byte_size = 8;
		} else if (Long.class.isInstance(mt_1st)) {
			mtime_byte_size = 8;
		} else {
			throw new IllegalArgumentException("Illegal data type for MT's.");
		}
			
		int relposs_size;
		if(this.vartype_symb_relpos == 'i') {
			relposs_size = mtimes.size() * Integer.BYTES * 2;
		} else {
			relposs_size = mtimes.size() * Long.BYTES * 2;
		}
		
		return foffset_byte_size
				+ Integer.BYTES // <--- Number of spectra is represented by the type int.
				+ mtimes.size() * mtime_byte_size
				+ relposs_size
				+ mtimes.size() * Integer.BYTES * 2; // <--- Sizes are expressed in the type int.

	}
	
	public void write_foffset(DataOutputStream fw,
			int foffset_byte_size) throws IOException {
		
		fw.writeInt(foffset_byte_size); // 4 bytes
		fw.writeInt(0x01020304); // 4 bytes
		
		if(this.mtimes.size() > 0) {
			// 1 byte
			T_mtime mt_1st = this.mtimes.get(0);
			if(Integer.class.isInstance(mt_1st)){
				fw.writeByte('i');
			} else if (Float.class.isInstance(mt_1st)) {
				fw.writeByte('f');
			} else if (Double.class.isInstance(mt_1st)) {
				fw.writeByte('d');
			} else if (Long.class.isInstance(mt_1st)) {
				fw.writeByte('x');
			} else {
				throw new IllegalArgumentException("Illegal data type for MT's.");
			}
	
			// 1 byte
			T_mz mz_1st1st = this.mspecs.get(0).mzs[0];
			if(Integer.class.isInstance(mz_1st1st)){
				fw.writeByte('i');
			} else if (Float.class.isInstance(mz_1st1st)) {
				fw.writeByte('f');
			} else if (Double.class.isInstance(mz_1st1st)) {
				fw.writeByte('d');
			} else if (Long.class.isInstance(mz_1st1st)) {
				fw.writeByte('x');
			} else {
				throw new IllegalArgumentException("Illegal data type for m/z's.");
			}		
	
			// 1 byte
			T_intst intst_1st1st = this.mspecs.get(0).intsts[0];
			if(Integer.class.isInstance(intst_1st1st)){
				fw.writeByte('i');
			} else if (Float.class.isInstance(intst_1st1st)) {
				fw.writeByte('f');
			} else if (Double.class.isInstance(intst_1st1st)) {
				fw.writeByte('d');
			} else if (Long.class.isInstance(intst_1st1st)) {
				fw.writeByte('x');
			} else {
				throw new IllegalArgumentException("Illegal data type for intensities.");
			}
			
			// 1 byte ... Relative positions
			fw.writeByte(this.vartype_symb_relpos);
			
		}
		
		
		for(int i = Integer.BYTES * 2 + 4; // BE CAREFUL ... Number of bytes
				i < foffset_byte_size;i ++) { 
			fw.writeByte(0x00);
		}
		
	}
	
	public void write_header_to_file(DataOutputStream fw, int foffset_byte_size)
			throws IOException{
		
		int header_bytes = this.get_header_bytes(foffset_byte_size);
		
		
		if(this.mtimes.size() == 0) {
			return;
		}
		
		T_mtime mt_1st = this.mtimes.get(0);
		
		for(T_mtime mt : this.mtimes) {
			if(Integer.class.isInstance(mt_1st)){
				fw.writeInt((int)mt);
			} else if (Float.class.isInstance(mt_1st)) {
				fw.writeFloat((float)mt);
			} else if (Double.class.isInstance(mt_1st)) {
				fw.writeDouble((double)mt);
			} else if (Long.class.isInstance(mt_1st)) {
				fw.writeLong((long)mt);
			} else {
				throw new IllegalArgumentException("Illegal data type for MT's.");
			}
		}
		
		for(long relpos : this.relposs_mzs_starts()) {
			if(this.vartype_symb_relpos == 'i') {
				fw.writeInt((int)(relpos + header_bytes));
			} else {
				fw.writeLong(relpos + header_bytes);
			} 
		}
		
		for(int csize : this.sizes_mzs()) {
			fw.writeInt(csize);
		}
		
		for(long relpos : this.relposs_intsts_starts()) {
			if(this.vartype_symb_relpos == 'i') {
				fw.writeInt((int)(relpos + header_bytes));
			} else  {
				fw.writeLong(relpos + header_bytes);
			}
		}
		
		for(int csize : this.sizes_intsts()) {
			fw.writeInt(csize);
		}
		
	}
	
	public long[] relposs_mzs_starts()
			throws IllegalArgumentException {

		long[] relposs = new long[ this.mtimes.size() ];
		
		int[] ms_sizes = this.sizes_ms();
		
		relposs[ 0 ] = 0;
		for(int i = 0; i < this.mtimes.size() - 1; i ++) {
			relposs[ i + 1 ] = relposs[ i ] + ms_sizes[ i ];
		}
		
		return(relposs);
	}
	
	public long[] relposs_mzs_ends()
			throws IllegalArgumentException {

		long[] relposs = new long[ this.mtimes.size() ];

		long[] relpos_mzs_starts = this.relposs_mzs_starts();
		int[] mzs_sizes = this.sizes_mzs();

		for(int i = 0; i < this.mtimes.size(); i ++) {
			relposs[ i ] = relpos_mzs_starts[ i ] + mzs_sizes[ i ] - 1;
		}
		
		return(relposs);
	}
	

	public long[] relposs_intsts_starts()
			throws IllegalArgumentException {

		long[] relposs = new long[ this.mtimes.size() ];
		long[] relpos_mzs_ends = this.relposs_mzs_ends();

		for(int i = 0; i < this.mtimes.size(); i ++) {
			relposs[ i ] = relpos_mzs_ends[ i ] + 1;
		}
		
		return(relposs);
	}
	
	public long[] relposs_intsts_ends()
			throws IllegalArgumentException {

		long[] relposs = new long[ this.mtimes.size() ];
		long[] relpos_intsts_starts = this.relposs_intsts_starts();
		int[] intsts_sizes = this.sizes_intsts();

		for(int i = 0; i < this.mtimes.size(); i ++) {
			relposs[ i ] = relpos_intsts_starts[ i ] + intsts_sizes[ i ] - 1;
		}
		
		return(relposs);
		
	}	

	public int[] sizes_ms()
			throws IllegalArgumentException {
		
		int[] osizes = new int[ this.mtimes.size() ];
		int p = 0;
		
		for(MassSpecrum_simple1_2<T_mz, T_intst> ms : this.mspecs) {
			osizes[ p ] = ms.bytesize_ms();	
			p ++;
		}
		
		return(osizes);
	}
		
	public int[] sizes_mzs()
			throws IllegalArgumentException {
		
		int[] osizes = new int[ this.mtimes.size() ];
		int p = 0;
		
		for(MassSpecrum_simple1_2<T_mz, T_intst> ms : this.mspecs) {
			osizes[ p ] = ms.bytesize_mzs();	
			p ++;
		}
		
		return(osizes);
	}
	
	public int[] sizes_intsts()
			throws IllegalArgumentException {
		
		int[] osizes = new int[ this.mtimes.size() ];
		int p = 0;
		
		for(MassSpecrum_simple1_2<T_mz, T_intst> ms : this.mspecs) {
			osizes[ p ] = ms.bytesize_intsts();			
			p ++;
		}
		
		return(osizes);
	}	
	
	
	
}
