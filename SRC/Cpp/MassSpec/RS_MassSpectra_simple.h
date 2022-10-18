#pragma once

#include <iostream>
#include <fstream>

// Clean the solution and re-build

using namespace std;

template <class T_m, class T_n, class T_val> class Feat2DSpace_EqSegmsLen;

struct range_idx_simple {

	int start;
	int end;

};

namespace rsMassSpec {

	template <class T_mz, class T_intst> class MassSpectrum_simple;

	template <class T_mtime, class T_mz, class T_intst> class RS_MassSpectra_simple
	{

	public:
		int num_spectra;
		T_mtime* mtimes;
		MassSpectrum_simple<T_mz, T_intst> **mspectra;

		RS_MassSpectra_simple<T_mtime, T_mz, T_intst>(int); // <T_mtime, T_mz, T_intst> unnecessary?
		~RS_MassSpectra_simple<T_mtime, T_mz, T_intst>();

		void disable_delete_mspectra_at_end();

		void add_spectrum(T_mtime, MassSpectrum_simple<T_mz, T_intst>*);
		int get_num_spectra_registered();

		int get_closest_mt_idx_from_mt(T_mtime);
		range_idx_simple get_closest_mt_idx_range_from_mt_pair(T_mtime, T_mtime);

		Feat2DSpace_EqSegmsLen<T_mz, T_mtime, T_intst> *get_2dmap_mzmt_alloc(
				T_mz, T_mz, int, T_mtime, T_mtime, int
		);


	private:
		int num_spectra_registered;
		int delete_every_mspectrum_at_end;

	};

}
