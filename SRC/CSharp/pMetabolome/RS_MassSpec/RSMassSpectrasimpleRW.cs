
using System.IO;
using System;
using System.Runtime.InteropServices;


namespace rsMassSpec
{
	public class RS_MassSpectra_simple_RW<T_mtime, T_mz, T_intst, T_rpos>
		where T_mtime : unmanaged, IComparable
		where T_mz : unmanaged, IComparable
		where T_intst : unmanaged, IComparable
		where T_rpos : unmanaged, IComparable
	{

		private const char MAGIC_ZERO = (char)0;
		private const int MAGIC_ENDIAN_CHECK = 0x01020304;

		private const int NUM_VARINFO_SYMBS = 4;
		private const int VARINFO_MT_WITHIN_VARINFO_IDX = 0;
		private const int VARINFO_MZ_WITHIN_VARINFO_IDX = 1;
		private const int VARINFO_INTST_WITHIN_VARINFO_IDX = 2;
		private const int VARINFO_RPOS_WITHIN_VARINFO_IDX = 3;

		private RS_MassSpectra_simple<T_mtime, T_mz, T_intst> rsmspectra;

		private T_rpos[] rposs_mzsstarts_allocarray;
		private T_rpos[] rposs_mzsends_allocarray;
		private T_rpos[] rposs_intstsstarts_allocarray;
		private T_rpos[] rposs_intstsends_allocarray;

		private int[] sizes_mzs_allocarray;
		private int[] sizes_intsts_allocarray;


		void write_foffset(
			BinaryWriter ibfw,
			int foffset_byte_size, byte[] vartype_symbs)
		{

			int head_size = 0;

			ibfw.Write(foffset_byte_size);
			head_size += sizeof(int);
			ibfw.Write(MAGIC_ENDIAN_CHECK);
			head_size += sizeof(int);
			ibfw.Write(vartype_symbs);
			head_size += vartype_symbs.Length;

			for (int i = head_size; i < foffset_byte_size; i++)
			{
				ibfw.Write(MAGIC_ZERO);
			}

		}

		public RS_MassSpectra_simple_RW(
			RS_MassSpectra_simple<T_mtime, T_mz, T_intst> irsmspectra)
		{
			// TODO Auto-generated constructor stub

			if (irsmspectra.get_num_spectra_registered() < irsmspectra.num_spectra)
			{
				throw new Exception("Incomplete registeration of spectra");
			}

			this.rsmspectra = irsmspectra;

			// CAUTION: Order matters.
			this.rposs_mzsstarts_allocarray = this.relposs_mzs_starts_alloc();
			this.rposs_mzsends_allocarray = this.relposs_mzs_ends_alloc();
			this.rposs_intstsstarts_allocarray = this.relposs_intsts_starts();
			this.rposs_intstsends_allocarray = this.relposs_intsts_ends();

			this.sizes_mzs_allocarray = this.sizes_mzs_alloc();
			this.sizes_intsts_allocarray = this.sizes_intsts_alloc();

			/*
			for(int i = 0;i < this->rsmspectra->num_spectra;i ++){
				cout << i << " -- " <<  this->rposs_mzsends_allocarray[i] << endl;
			}
			 */

		}

		void write_header_to_file(
			BinaryWriter ibfw,
			int foffset_byte_size)
		{

			if (this.rsmspectra.num_spectra == 0) return;

			int header_bytes = this.get_header_bytes(foffset_byte_size);
			T_rpos[] buf_rpos = new T_rpos[this.rsmspectra.num_spectra];
			byte[] binarybuf_rpos = new byte[this.rsmspectra.num_spectra * Marshal.SizeOf(typeof(T_rpos))];
			byte[] binarybuf_sizes = new byte[this.rsmspectra.num_spectra * Marshal.SizeOf(typeof(int))];

			ibfw.Write(this.rsmspectra.num_spectra);

			byte[] binarybuf_mtimes = new byte[this.rsmspectra.num_spectra * Marshal.SizeOf(typeof(T_mtime))];
			Buffer.BlockCopy(this.rsmspectra.mtimes, 0, binarybuf_mtimes, 0, binarybuf_mtimes.Length);
			ibfw.Write(binarybuf_mtimes);

			for (int i = 0; i < this.rsmspectra.num_spectra; i++)
			{
				buf_rpos[i] = this.rposs_mzsstarts_allocarray[i] + (dynamic)header_bytes;
			}
			Buffer.BlockCopy(buf_rpos, 0, binarybuf_rpos, 0, binarybuf_rpos.Length);
			ibfw.Write(binarybuf_rpos);

			Buffer.BlockCopy(this.sizes_mzs_allocarray, 0, binarybuf_sizes, 0, binarybuf_sizes.Length);
			ibfw.Write(binarybuf_sizes);

			for (int i = 0; i < this.rsmspectra.num_spectra; i++)
				buf_rpos[i] = this.rposs_intstsstarts_allocarray[i] + (dynamic)header_bytes;
			Buffer.BlockCopy(buf_rpos, 0, binarybuf_rpos, 0, binarybuf_rpos.Length);
			ibfw.Write(binarybuf_rpos);

			Buffer.BlockCopy(this.sizes_intsts_allocarray, 0, binarybuf_sizes, 0, binarybuf_sizes.Length);
			ibfw.Write(binarybuf_sizes);


		}



		public void output_to_file(string opath, int foffset_byte_size)
		{

			string parentdir = Directory.GetParent(opath).FullName;
			Directory.CreateDirectory(parentdir);

			BinaryWriter bfw = new BinaryWriter(File.Open(opath, FileMode.Create));

			byte[] vartype_symbs = new byte[NUM_VARINFO_SYMBS];
			vartype_symbs[VARINFO_MT_WITHIN_VARINFO_IDX]
				= (byte)VariableType.VariableType.get_symb_from_varnam(typeof(T_mtime).Name);
			vartype_symbs[VARINFO_MZ_WITHIN_VARINFO_IDX]
				= (byte)VariableType.VariableType.get_symb_from_varnam(typeof(T_mz).Name);
			vartype_symbs[VARINFO_INTST_WITHIN_VARINFO_IDX]
				= (byte)VariableType.VariableType.get_symb_from_varnam(typeof(T_intst).Name);
			vartype_symbs[VARINFO_RPOS_WITHIN_VARINFO_IDX]
				= (byte)VariableType.VariableType.get_symb_from_varnam(typeof(T_rpos).Name);

			write_foffset(bfw, foffset_byte_size, vartype_symbs); // namespace O.K?
			write_header_to_file(bfw, foffset_byte_size);

			// int i = 0;
			foreach (MassSpectrum_simple<T_mz, T_intst> mspec in this.rsmspectra.mspectra)
			{
				// if(1200 < i && i < 1260)
				//	Console.WriteLine($"{i}\t{mspec.intsts[0]}");

				mspec.output_to_file(bfw);
				// i++;
			}

			bfw.Close();

		}

		public int get_header_bytes(int foffset_byte_size)
		{

			return foffset_byte_size
					+ Marshal.SizeOf(typeof(int)) // <--- Number of spectra is represented by the type int.
					+ this.rsmspectra.num_spectra * Marshal.SizeOf(typeof(T_mtime))
					+ this.rsmspectra.num_spectra * Marshal.SizeOf(typeof(T_rpos)) * 2 // rposs
					+ this.rsmspectra.num_spectra * Marshal.SizeOf(typeof(int)) * 2; // sizes

			// + this.rsmspectra.num_spectra * Marshal.SizeOf(typeof(T_rpos)) * 4; // 4 types of relative positions
			// <--- !!!

		}

		public T_rpos[] relposs_mzs_starts_alloc()
		{
			// ofstream fw (without "&") will probably not work probably because operator= is not defined.
			// https://yohhoy.hatenadiary.jp/entry/20130203/p1
			// fw should be opened with std::ios::out | std::ios::binary

			T_rpos[] relposs_alloc = new T_rpos[this.rsmspectra.num_spectra];

			relposs_alloc[0] = (dynamic)0;
			for (int i = 0; i < this.rsmspectra.num_spectra - 1; i++)
			{
				relposs_alloc[i + 1] = relposs_alloc[i] + (dynamic)this.rsmspectra.mspectra[i].bytesize_ms();
			}

			return (relposs_alloc);

		}

		public T_rpos[] relposs_mzs_ends_alloc()
		{
			// ofstream fw (without "&") will probably not work probably because operator= is not defined.
			// https://yohhoy.hatenadiary.jp/entry/20130203/p1
			// fw should be opened with std::ios::out | std::ios::binary

			T_rpos[] relposs_alloc = new T_rpos[this.rsmspectra.num_spectra];

			relposs_alloc[0] = (dynamic)0;
			for (int i = 0; i < this.rsmspectra.num_spectra; i++)
			{
				relposs_alloc[i] =
						this.rposs_mzsstarts_allocarray[i] + (dynamic)this.rsmspectra.mspectra[i].bytesize_mzs() - 1;
			}

			return (relposs_alloc);

		}

		T_rpos[] relposs_intsts_starts()
		{
			// ofstream fw (without "&") will probably not work probably because operator= is not defined.
			// https://yohhoy.hatenadiary.jp/entry/20130203/p1
			// fw should be opened with std::ios::out | std::ios::binary

			T_rpos[] relposs_alloc = new T_rpos[this.rsmspectra.num_spectra];

			for (int i = 0; i < this.rsmspectra.num_spectra; i++)
			{
				relposs_alloc[i] = this.rposs_mzsends_allocarray[i] + (dynamic)1;
			}

			return (relposs_alloc);

		}

		T_rpos[] relposs_intsts_ends()
		{
			// ofstream fw (without "&") will probably not work probably because operator= is not defined.
			// https://yohhoy.hatenadiary.jp/entry/20130203/p1
			// fw should be opened with std::ios::out | std::ios::binary

			T_rpos[] relposs_alloc = new T_rpos[this.rsmspectra.num_spectra];

			for (int i = 0; i < this.rsmspectra.num_spectra; i++)
			{
				relposs_alloc[i] = this.rposs_intstsstarts_allocarray[i]
						+ (dynamic)this.rsmspectra.mspectra[i].bytesize_intsts() - 1;
			}

			return (relposs_alloc);

		}

		int[] sizes_ms_alloc()
		{
			// ofstream fw (without "&") will probably not work probably because operator= is not defined.
			// https://yohhoy.hatenadiary.jp/entry/20130203/p1
			// fw should be opened with std::ios::out | std::ios::binary

			int[] osizes_ms_alloc = new int[this.rsmspectra.num_spectra];
			for (int i = 0; i < this.rsmspectra.num_spectra; i++)
			{
				osizes_ms_alloc[i] = this.rsmspectra.mspectra[i].bytesize_ms();
			}

			return osizes_ms_alloc;

		}

		int[] sizes_mzs_alloc()
		{
			// ofstream fw (without "&") will probably not work probably because operator= is not defined.
			// https://yohhoy.hatenadiary.jp/entry/20130203/p1
			// fw should be opened with std::ios::out | std::ios::binary

			int[] osizes_mzs_alloc = new int[this.rsmspectra.num_spectra];
			for (int i = 0; i < this.rsmspectra.num_spectra; i++)
			{
				osizes_mzs_alloc[i] = this.rsmspectra.mspectra[i].bytesize_mzs();
			}

			return osizes_mzs_alloc;

		}


		int[] sizes_intsts_alloc()
		{
			// ofstream fw (without "&") will probably not work probably because operator= is not defined.
			// https://yohhoy.hatenadiary.jp/entry/20130203/p1
			// fw should be opened with std::ios::out | std::ios::binary

			int[] osizes_intsts_alloc = new int[this.rsmspectra.num_spectra];
			for (int i = 0; i < this.rsmspectra.num_spectra; i++)
			{
				osizes_intsts_alloc[i] = this.rsmspectra.mspectra[i].bytesize_intsts();
			}

			return osizes_intsts_alloc;

		}


	}
}





