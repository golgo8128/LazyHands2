using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading;
// using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

namespace rsMassSpec {

	public class MassSpectrum_simple<T_mz, T_intst>
			where T_mz : unmanaged, IComparable
			where T_intst : unmanaged, IComparable

	{

		public int num_mzs;
		public T_mz[] mzs;
		public T_intst[] intsts;


		public MassSpectrum_simple()
		{

			this.num_mzs = 0;

		}

		public void set_spectrum(
				int inum_mzs, T_mz[] i_allocated_mzs, T_intst[] i_allocated_intsts)
		{

			this.num_mzs = inum_mzs;
			this.mzs = i_allocated_mzs;
			this.intsts = i_allocated_intsts;

		}

		public void print_spectrum()
		{

			for (int i = 0; i < this.num_mzs; i++)
			{
				T_mz mz = this.mzs[i];
				T_intst intst = this.intsts[i];
				Console.WriteLine($"{mz}\t{intst}");
			}

		}

		public void output_spectrum_to_txtfile(
					string otxtfile)
		{

			using (StreamWriter fw = new StreamWriter(otxtfile, false, Encoding.UTF8))
			{
				for (int i = 0; i < this.num_mzs; i++)
				{
					T_mz mz = this.mzs[i];
					T_intst intst = this.intsts[i];
					fw.WriteLine($"{mz}\t{intst}");
				}
			}

		}


		public void output_to_file(BinaryWriter ibfw)
		{

			// Caution: sizeof(bool) not equal to Marshal.SizeOf(typeof(bool))
			byte[] binarybuf_mzs = new byte[this.mzs.Length * Marshal.SizeOf(typeof(T_mz))];
			Buffer.BlockCopy(this.mzs, 0, binarybuf_mzs, 0, binarybuf_mzs.Length);
			ibfw.Write(binarybuf_mzs);

			byte[] binarybuf_intsts = new byte[this.mzs.Length * Marshal.SizeOf(typeof(T_intst))];
			Buffer.BlockCopy(this.intsts, 0, binarybuf_intsts, 0, binarybuf_intsts.Length);
			ibfw.Write(binarybuf_intsts);

		}


		public int bytesize_ms()
		{

			return this.bytesize_mzs() + this.bytesize_intsts();

		}

		public int bytesize_mzs()
		{

			return (int)(Marshal.SizeOf(typeof(T_mz)) * this.num_mzs);

		}

		public int bytesize_intsts()
		{

			return (int)(Marshal.SizeOf(typeof(T_intst)) * this.num_mzs);

		}

	}

}
