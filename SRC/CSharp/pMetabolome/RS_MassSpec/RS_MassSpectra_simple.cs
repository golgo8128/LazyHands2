
using System;


namespace rsMassSpec {

	public class RS_MassSpectra_simple<T_mtime, T_mz, T_intst>
		where T_mtime : unmanaged, IComparable
		where T_mz : unmanaged, IComparable
		where T_intst : unmanaged, IComparable
	{

		public int num_spectra;
		private int num_spectra_registered;
		internal T_mtime[] mtimes;
		internal MassSpectrum_simple<T_mz, T_intst>[] mspectra;


		public RS_MassSpectra_simple(int inum_spectra) {


			this.num_spectra = inum_spectra;
			this.num_spectra_registered = 0;
			this.mtimes = new T_mtime[inum_spectra];
			this.mspectra = new MassSpectrum_simple<T_mz, T_intst>[inum_spectra];

		}

		public int get_num_spectra_registered()
		{
			return this.num_spectra_registered;
		}

		public void add_spectrum(
				T_mtime imt, MassSpectrum_simple<T_mz, T_intst> ispectrum)
		{

			this.mtimes[ this.num_spectra_registered ]   = imt;
			this.mspectra[ this.num_spectra_registered ] = ispectrum;
			this.num_spectra_registered++;

		}

	}

}
