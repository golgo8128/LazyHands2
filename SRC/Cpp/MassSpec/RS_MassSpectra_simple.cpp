
#include "RS_MassSpectra_simple.h"
#include "MassSpectrum_simple.h"

#include "Usefuls/closest_value_in_sorted1.h"

#include "Usefuls/Feat2DSpace1.h"

#include <iostream>

using namespace std;

namespace rsMassSpec {

	template <class T_mtime, class T_mz, class T_intst>
	RS_MassSpectra_simple<T_mtime, T_mz, T_intst>::RS_MassSpectra_simple(int inum_spectra) {


		this->num_spectra = inum_spectra;
		this->num_spectra_registered = 0;
		this->mtimes = new T_mtime[inum_spectra];
		this->mspectra = new MassSpectrum_simple<T_mz, T_intst>*[inum_spectra];

		// cout << "Newly allocated mtimes and mspectra " << this->mtimes << " " << this->mspectra << endl;


		this->delete_every_mspectrum_at_end = 1;

	}

	template <class T_mtime, class T_mz, class T_intst>
	RS_MassSpectra_simple<T_mtime, T_mz, T_intst>::~RS_MassSpectra_simple() {

		if (this->delete_every_mspectrum_at_end) {
			for (int i = 0; i < this->num_spectra_registered; i++) {
				delete this->mspectra[i];
			}
			// cout << "Every spectrum deleted." << endl;
		}
		else {
			// cout << "Every spectrum NOT deleted." << endl;
		}

		// cout << "Trying to delete mtimes and mspectra " << this->mtimes << " " << this->mspectra << endl;

		delete[] this->mtimes;
		delete[] this->mspectra;

		// cout << "RS_MassSpectra_simple released." << endl;

	}

	template <class T_mtime, class T_mz, class T_intst>
	void RS_MassSpectra_simple<T_mtime, T_mz, T_intst>::disable_delete_mspectra_at_end() {

		this->delete_every_mspectrum_at_end = 0;

	}

	template <class T_mtime, class T_mz, class T_intst>
	int RS_MassSpectra_simple<T_mtime, T_mz, T_intst>::get_num_spectra_registered() {

		return this->num_spectra_registered;

	}


	template <class T_mtime, class T_mz, class T_intst>
	void RS_MassSpectra_simple<T_mtime, T_mz, T_intst>::add_spectrum(
		T_mtime imt, MassSpectrum_simple<T_mz, T_intst>* ispectrum) {

		this->mtimes[this->num_spectra_registered] = imt;
		this->mspectra[this->num_spectra_registered] = ispectrum;
		this->num_spectra_registered++;

	}

	template <class T_mtime, class T_mz, class T_intst>
	Feat2DSpace_EqSegmsLen<T_mz, T_mtime, T_intst>
		* RS_MassSpectra_simple<T_mtime, T_mz, T_intst>::get_2dmap_mzmt_alloc(
			T_mz mz_l, T_mz mz_h, int mz_num_segms,
			T_mtime mt_l, T_mtime mt_h, int mt_num_segms
		) {

		Feat2DSpace_EqSegmsLen<T_mz, T_mtime, T_intst>* map2d_mtmz_alloc =
			new Feat2DSpace_EqSegmsLen<T_mz, T_mtime, T_intst>(
				mz_l, mz_h, mz_num_segms, 0,
				mt_l, mt_h, mt_num_segms, 0,
				0);

		for (int i = 0; i < this->num_spectra_registered; i++) {

			MassSpectrum_simple<T_mz, T_intst>* mspectra_p = this->mspectra[i];
			for (int j = 0; j < mspectra_p->num_mzs; j++) {

				map2d_mtmz_alloc->map_to_2d_evalmax(
					mspectra_p->mzs[j],
					this->mtimes[i],
					mspectra_p->intsts[j]);
			}

		}

		return map2d_mtmz_alloc;

	}


	template <class T_mtime, class T_mz, class T_intst>
	int RS_MassSpectra_simple<T_mtime, T_mz, T_intst>
		::get_closest_mt_idx_from_mt(T_mtime imt) {

		return closest_value_in_sorted_get_idx(this->mtimes, this->num_spectra, imt);

	}


	template <class T_mtime, class T_mz, class T_intst>
	range_idx_simple RS_MassSpectra_simple<T_mtime, T_mz, T_intst>
		::get_closest_mt_idx_range_from_mt_pair(T_mtime mt_start, T_mtime mt_end){


		range_idx_simple range_idx;
		range_idx.start =
			closest_limit_value_in_sorted_get_idx(this->mtimes, this->num_spectra, mt_start, 'l');
		range_idx.end =
			closest_limit_value_in_sorted_get_idx(this->mtimes, this->num_spectra, mt_end, 'h');

		return range_idx;

	}


	template class RS_MassSpectra_simple<float, float, int>;
	template class RS_MassSpectra_simple<float, double, int>;
	template class RS_MassSpectra_simple<float, float, double>;

}
