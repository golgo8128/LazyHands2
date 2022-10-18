/*
 * EPheMatrix1.cpp
 *
 *  Created on: 2022/06/23
 *      Author: rsaito
 */

#include <iostream>
#include <stdio.h>

#include "MassSpec/EPheMatrix1.h"
#include "MassSpec/RS_MassSpectra_simple.h"
#include "MassSpec/MassSpectrum_simple.h"
#include "PeakProc/spectrum_proc1.h"
#include "Usefuls/array2d.h"
#include "Usefuls/rsBinaryDat1.h"
#include "Usefuls/closest_value_in_sorted1.h"
#include "Usefuls/array_usefuls1.h"


using namespace std;

namespace rsMassSpec {

	template <class T_mtime, class T_mz, class T_intst>
	EPheMatrix1<T_mtime, T_mz, T_intst>::EPheMatrix1(
		RS_MassSpectra_simple<T_mtime, T_mz, T_intst>* irsmspectra_p){

		this->rsmspectra_p = irsmspectra_p;
		// this->ref_mspectrum_p = this->rsmspectra_p->mspectra[iref_mt_idx];

	}

	template <class T_mtime, class T_mz, class T_intst>
	EPheMatrix1<T_mtime, T_mz, T_intst>::EPheMatrix1(
		RS_MassSpectra_simple<T_mtime, T_mz, T_intst>* irsmspectra_p, T_mtime iref_mt){

		int iref_mt_idx = irsmspectra_p->get_closest_mt_idx_from_mt(iref_mt);

		this->rsmspectra_p = irsmspectra_p;
		this->initialize_by_ref_spectrum(iref_mt_idx);

	}

	template <class T_mtime, class T_mz, class T_intst>
	EPheMatrix1<T_mtime, T_mz, T_intst>::EPheMatrix1(
		RS_MassSpectra_simple<T_mtime, T_mz, T_intst>* irsmspectra_p, T_mtime iref_mt,
		double imz_diff_thres, int itop_prefer_mode){

		this->mz_diff_thres = imz_diff_thres;
		this->top_prefer_mode = itop_prefer_mode;

		int iref_mt_idx = irsmspectra_p->get_closest_mt_idx_from_mt(iref_mt);

		this->rsmspectra_p = irsmspectra_p;
		this->initialize_by_ref_spectrum(iref_mt_idx);

	}




	template <class T_mtime, class T_mz, class T_intst>
	void EPheMatrix1<T_mtime, T_mz, T_intst>::initialize_by_ref_spectrum(int iref_mt_idx) {

		this->ref_mt_idx = iref_mt_idx;

		this->set_ref_mts();
		this->set_ref_mzs();

		this->ephe_mat = init_array2d<T_intst>(this->num_mzs, this->num_mts, 0);
		this->matched_mz_mat = init_array2d<T_mz>(this->num_mzs, this->num_mts, 0);

		this->gen_ephe_matrix(); // gen_ephe_matrix_prefer_peaktop(2); //



	}

	template <class T_mtime, class T_mz, class T_intst>
	void EPheMatrix1<T_mtime, T_mz, T_intst>::set_ref_mts() {

		cout << "Setting reference MTs based on original MTs ... " << endl;
		this->num_mts = this->rsmspectra_p->num_spectra;
		this->ref_mts = this->rsmspectra_p->mtimes;

	}

	template <class T_mtime, class T_mz, class T_intst>
	void EPheMatrix1<T_mtime, T_mz, T_intst>::set_ref_mzs() {

		cout << "Setting reference m/z's based on original m/z's ... " << endl;
		this->num_mzs = this->rsmspectra_p->mspectra[this->ref_mt_idx]->num_mzs;
		this->ref_mzs = this->rsmspectra_p->mspectra[this->ref_mt_idx]->mzs;

	}


	template <class T_mtime, class T_mz, class T_intst>
	void EPheMatrix1<T_mtime, T_mz, T_intst>::output_ephe_mat(const char *ofilename) {

		rsBinaryDat::write_2dmap<T_mz, T_mtime, T_intst, unsigned int>(
				ofilename,
				this->ref_mzs, this->num_mzs,
				this->ref_mts, this->num_mts,
				this->ephe_mat,
				256);

	}

	template <class T_mtime, class T_mz, class T_intst>
	void EPheMatrix1<T_mtime, T_mz, T_intst>::output_matched_mz_mat(const char *ofilename) {

		rsBinaryDat::write_2dmap<T_mz, T_mtime, T_mz, unsigned int>(
				ofilename,
				this->ref_mzs, this->num_mzs,
				this->ref_mts, this->num_mts,
				this->matched_mz_mat,
				256);

	}


	template <class T_mtime, class T_mz, class T_intst>
	void EPheMatrix1<T_mtime, T_mz, T_intst>::output_ephe_mat_txt(const char* ofilename) {

		write_array2d(
			ofilename,
			this->ephe_mat,
			this->num_mzs, this->num_mts,
			this->ref_mzs, this->ref_mts);

	}

	template <class T_mtime, class T_mz, class T_intst>
	void EPheMatrix1<T_mtime, T_mz, T_intst>::output_matched_mz_mat_txt(const char* ofilename) {

		write_array2d(
			ofilename,
			this->matched_mz_mat,
			this->num_mzs, this->num_mts,
			this->ref_mzs, this->ref_mts);

	}



	template <class T_mtime, class T_mz, class T_intst>
	int EPheMatrix1<T_mtime, T_mz, T_intst>::get_closest_ref_mt_idx(T_mtime imt) {

		return closest_value_in_sorted_get_idx<T_mtime>(
					this->ref_mts, this->num_mts, imt);

	}

	template <class T_mtime, class T_mz, class T_intst>
	int EPheMatrix1<T_mtime, T_mz, T_intst>::get_closest_ref_mz_idx(T_mz imz) {

		return closest_value_in_sorted_get_idx<T_mz>(
					this->ref_mzs, this->num_mzs, imz);

	}

	template <class T_mtime, class T_mz, class T_intst>
	int EPheMatrix1<T_mtime, T_mz, T_intst>::get_ephe_mt_idx_from_mspec_mt_idx(int mt_idx) {

		return mt_idx;

	}


/*
	template <class T_mtime, class T_mz, class T_intst>
	void EPheMatrix1<T_mtime, T_mz, T_intst>::gen_ephe_matrix() {

		for (int j = 0; j < this->num_mts; j++) {
			// cout << "--- Time point " << j << "th " << this->rsmspectra_p->mtimes[j] << "---" << endl;
			MassSpectrum_simple<T_mz, T_intst> *cur_mspectrum_p = this->rsmspectra_p->mspectra[ j ];
			for(int i = 0;i < this->num_mzs;i ++){
				T_mz cur_ref_mz = this->ref_mzs[ i ];
				int closest_cur_spectrum_idx =
					cur_mspectrum_p->find_closest_mz_idx_given_mz(cur_ref_mz);
					// closest_value_in_sorted_get_idx<T_mz>(cur_mspectrum_p->mzs, cur_mspectrum_p->num_mzs, cur_ref_mz);

				this->ephe_mat[ i ][ j ] = cur_mspectrum_p->intsts[ closest_cur_spectrum_idx ];
				this->matched_mz_mat[ i ][ j ] = cur_mspectrum_p->mzs[ closest_cur_spectrum_idx ];

				// cout << "Reference m/z: " << cur_ref_mz << " ";
				// cout << "Matched   m/z: " << cur_mspectrum_p->mzs[ closest_idx ] << " ";
				// cout << "Current intensity: " << this->ephe_mat[ i ][ j ] << endl;

			}
			// cout << endl;

		}
*/
		/*
		display_array2d<T_intst, T_mz, T_mtime>(this->ephe_mat, this->num_mzs, this->num_mts,
				ref_mspectrum_p->mzs, this->rsmspectra_p->mtimes);
		cout << endl;
		display_array2d<T_mz, T_mz, T_mtime>(this->matched_mz_mat, this->num_mzs, this->num_mts,
				ref_mspectrum_p->mzs, this->rsmspectra_p->mtimes);
		 */
		/*
		for(int j = 0;j < this->num_mts;j ++)
			cout << "\t" << this->rsmspectra_p->mtimes[j];
		cout << '\n';
		for(int i = 0;i < this->num_mzs;i ++){
			cout << ref_mspectrum_p->mzs[i];
			for(int j = 0;j < this->num_mts;j ++)
				cout << "\t" << this->ephe_mat[ i ][ j ];
			cout << endl;
		}
		 */

		/*
		for (int j = 0; j < this->num_mts; j++) {
			cout << "--- Time point " << j << "th " << this->rsmspectra_p->mtimes[j] << "---" << endl;
			MassSpectrum_simple<T_mz, T_intst> *cur_mspectrum_p = this->rsmspectra_p->mspectra[ j ];
			for(int i = 0;i < cur_mspectrum_p->num_mzs;i ++){
				T_mz cur_mz = cur_mspectrum_p->mzs[ i ];
				int closest_idx =
						closest_value_in_sorted_get_idx<T_mz>(ref_mspectrum_p->mzs, ref_mspectrum_p->num_mzs, cur_mz);
				this->ephe_mat[ closest_idx  ][ j ] = cur_mspectrum_p->intsts[ i ];

				cout << "Current m/z: " << cur_mz << " ";
				cout << "Matched m/z: " << ref_mspectrum_p->mzs[ closest_idx ] << " ";
				cout << "Current intensity: " << this->ephe_mat[ closest_idx  ][ j ] << endl;

			}
			cout << endl;

		}
		*/

	// }


	template <class T_mtime, class T_mz, class T_intst>
	void EPheMatrix1<T_mtime, T_mz, T_intst>::gen_ephe_matrix() {

		for (int j = 0; j < this->num_mts; j++) {
			// cout << "--- Time point " << j << "th " << this->rsmspectra_p->mtimes[j] << "---" << endl;
			MassSpectrum_simple<T_mz, T_intst> *cur_mspectrum_p = this->rsmspectra_p->mspectra[ j ];
			if (cur_mspectrum_p->num_mzs){
				for(int i = 0;i < this->num_mzs;i ++){
					T_mz cur_ref_mz = this->ref_mzs[ i ];
					int mz_idx;

					found_mz_idx found_mz =
						cur_mspectrum_p->find_peak_top_idx_given_mz(cur_ref_mz);
					T_mz peak_top_mz = cur_mspectrum_p->mzs[ found_mz.peak_top_idx ];
					T_mz closest_mz  = cur_mspectrum_p->mzs[ found_mz.nearest_idx ];

					if(this->mz_diff_thres < 0){
						mz_idx = found_mz.nearest_idx;
					} else if (this->top_prefer_mode  && abs(peak_top_mz - cur_ref_mz) <= this->mz_diff_thres){
						mz_idx = found_mz.peak_top_idx;
					} else if (abs(closest_mz - cur_ref_mz) <= this->mz_diff_thres){
						mz_idx = found_mz.nearest_idx;
					} else {
						mz_idx = -1;
					}

					if(mz_idx >= 0){
						this->ephe_mat[ i ][ j ] = cur_mspectrum_p->intsts[ mz_idx ];
						this->matched_mz_mat[ i ][ j ] = cur_mspectrum_p->mzs[ mz_idx ];
					} else {
						this->ephe_mat[ i ][ j ] = 0;
						this->matched_mz_mat[ i ][ j ] = -1;
					}

					/*
					printf("i:%d (m/z:%.2lf), j:%d (MT:%.2lf)  nearest idx:%d (m/z: %.2lf) peak top idx:%d (m/z: %.2lf) selected mz idx: %d (%.2lf)\n",
							i, (double)this->ref_mzs[i],
							j, (double)this->ref_mts[j],
							found_mz.nearest_idx, (double)cur_mspectrum_p->mzs[ found_mz.nearest_idx ],
							found_mz.peak_top_idx, (double)cur_mspectrum_p->mzs[ found_mz.peak_top_idx ],
							mz_idx, (double)cur_mspectrum_p->mzs[ mz_idx ]);
							*/

				}
			} else {
				for(int i = 0;i < this->num_mzs;i ++){

					this->ephe_mat[ i ][ j ] = 0;
					this->matched_mz_mat[ i ][ j ] = -1;

				}

			}

		}

	}



	template <class T_mtime, class T_mz, class T_intst>
	EPheMatrix1<T_mtime, T_mz, T_intst>::~EPheMatrix1() {
		// TODO Auto-generated destructor stub

		// delete[] this->ref_mts;
		// delete[] this->ref_mzs;

		cout << "Deleting matrices of electropherograms ... " << endl;

		del_array2d<T_intst>(this->ephe_mat, this->num_mzs, this->num_mts);
		del_array2d<T_mz>(this->matched_mz_mat, this->num_mzs, this->num_mts);

	}


/*
 *
 * Derived class EPheMatrix1_eq_intervals
 *
 */

	
	template <class T_mtime, class T_mz, class T_intst>
	EPheMatrix1_eq_intervals<T_mtime, T_mz, T_intst>::EPheMatrix1_eq_intervals(
		RS_MassSpectra_simple<T_mtime, T_mz, T_intst>* irsmspectra_p, T_mtime iref_mt)
			:EPheMatrix1<T_mtime, T_mz, T_intst>::EPheMatrix1(irsmspectra_p)
	{


		int iref_mt_idx = irsmspectra_p->get_closest_mt_idx_from_mt(iref_mt);
		this->initialize_by_ref_spectrum(iref_mt_idx);

	};


	template <class T_mtime, class T_mz, class T_intst>
	EPheMatrix1_eq_intervals<T_mtime, T_mz, T_intst>::EPheMatrix1_eq_intervals(
		RS_MassSpectra_simple<T_mtime, T_mz, T_intst>* irsmspectra_p, T_mtime iref_mt,
		double imz_diff_thres, int itop_prefer_mode)
			:EPheMatrix1<T_mtime, T_mz, T_intst>::EPheMatrix1(irsmspectra_p)
	{

		this->mz_diff_thres = imz_diff_thres;
		this->top_prefer_mode = itop_prefer_mode;

		int iref_mt_idx = irsmspectra_p->get_closest_mt_idx_from_mt(iref_mt);
		this->initialize_by_ref_spectrum(iref_mt_idx);

	};



	template <class T_mtime, class T_mz, class T_intst>
	void EPheMatrix1_eq_intervals<T_mtime, T_mz, T_intst>::initialize_by_ref_spectrum(int iref_mt_idx) {

		this->ref_mt_idx = iref_mt_idx;

		this->set_ref_mts();
		this->set_ref_mzs();

		this->ephe_mat = init_array2d<T_intst>(this->num_mzs, this->num_mts, 0);
		this->matched_mz_mat = init_array2d<T_mz>(this->num_mzs, this->num_mts, 0);

		this->gen_ephe_matrix();


	}


	template <class T_mtime, class T_mz, class T_intst>
	void EPheMatrix1_eq_intervals<T_mtime, T_mz, T_intst>::set_ref_mts()
	{

		cout << "Setting reference MTs based on calculated MTs ... " << endl;
		this->num_mts = this->rsmspectra_p->num_spectra;
		this->ref_mts = alloc_eq_intervals<T_mtime>(this->rsmspectra_p->mtimes, this->num_mts);

	};

	template <class T_mtime, class T_mz, class T_intst>
	void EPheMatrix1_eq_intervals<T_mtime, T_mz, T_intst>::set_ref_mzs()
	{

		cout << "Setting reference m/z's based on calculated m/z's ... " << endl;
		this->num_mzs = this->rsmspectra_p->mspectra[this->ref_mt_idx]->num_mzs;
		this->ref_mzs = alloc_eq_intervals<T_mz>(this->rsmspectra_p->mspectra[this->ref_mt_idx]->mzs, this->num_mzs);

	};


	template <class T_mtime, class T_mz, class T_intst>
	int EPheMatrix1_eq_intervals<T_mtime, T_mz, T_intst>::get_ephe_mt_idx_from_mspec_mt_idx(int mt_idx) {

		// cout << "int get_ephe_mt_idx_from_mspec_mt_idx(int) in EPheMatrix1_eq_interval" << endl;
		T_mtime mt = this->rsmspectra_p->mtimes[ mt_idx ];
		return this->get_closest_ref_mt_idx(mt);

	}


	template <class T_mtime, class T_mz, class T_intst>
	void EPheMatrix1_eq_intervals<T_mtime, T_mz, T_intst>::gen_ephe_matrix() {

		for (int j = 0; j < this->num_mts; j++) {
			// cout << "--- Time point " << j << "th " << this->rsmspectra_p->mtimes[j] << "---" << endl;
			T_mtime cur_mt_border_l = this->ref_mts[j];
			int closest_actual_mt_idx = closest_value_in_sorted_get_idx<T_mtime>(
					this->rsmspectra_p->mtimes,
					this->rsmspectra_p->num_spectra,
					cur_mt_border_l);

			// cout << j << '\t' << "Reference MT: " << cur_mt_border_l << '\t';
			// cout << "Matched   MT: " << this->rsmspectra_p->mtimes[ closest_actual_mt_idx ] << endl;

			MassSpectrum_simple<T_mz, T_intst> *cur_mspectrum_p = this->rsmspectra_p->mspectra[ closest_actual_mt_idx ];

			if (cur_mspectrum_p->num_mzs){

				for(int i = 0;i < this->num_mzs;i ++){

					T_mz cur_ref_mz = this->ref_mzs[ i ];
					int mz_idx;

					found_mz_idx found_mz =
						cur_mspectrum_p->find_peak_top_idx_given_mz(cur_ref_mz);
					T_mz peak_top_mz = cur_mspectrum_p->mzs[ found_mz.peak_top_idx ];
					T_mz closest_mz  = cur_mspectrum_p->mzs[ found_mz.nearest_idx ];

					/*
					if(64.8866 < cur_ref_mz && cur_ref_mz < 65.2208 &&
					   7.22577 < cur_mt_border_l && cur_mt_border_l < 7.78357){
						cout << "Target m/z: " << cur_ref_mz << "  Current MT: " << this->ref_mts[j] << endl;
						for(int i2 = 0;i2 < cur_mspectrum_p->num_mzs;i2 ++)
							cout << i2 << ": " << cur_mspectrum_p->mzs[i2] << " " << cur_mspectrum_p->intsts[i2] << endl;
						cout << "Peak top m/z: " << peak_top_mz << "  Closest m/z: " << closest_mz << "  Peak top mz diff thres: " << this->mz_diff_thres << endl;
					}
					*/

					if(this->mz_diff_thres < 0){
						mz_idx = found_mz.nearest_idx;
						// cout << "Absolute nearest." << endl;
					} else if (this->top_prefer_mode  && abs(peak_top_mz - cur_ref_mz) <= this->mz_diff_thres){
						mz_idx = found_mz.peak_top_idx;
						// cout << "Got top." << endl;
					} else if (abs(closest_mz - cur_ref_mz) <= this->mz_diff_thres){
						mz_idx = found_mz.nearest_idx;
						// cout << "Nearest." << endl;
					} else {
						mz_idx = -1;
						// cout << "No hit." << endl;
					}

					if(mz_idx >= 0){
						this->ephe_mat[ i ][ j ] = cur_mspectrum_p->intsts[ mz_idx ];
						this->matched_mz_mat[ i ][ j ] = cur_mspectrum_p->mzs[ mz_idx ];
					} else {
						this->ephe_mat[ i ][ j ] = 0;
						this->matched_mz_mat[ i ][ j ] = -1;
					}

					// cout << "Hit m/z idx: " << mz_idx << " ... " << cur_mspectrum_p->mzs[ mz_idx ] << " " << cur_mspectrum_p->intsts[ mz_idx ] << endl << endl;

				}


			} else {

				for(int i = 0;i < this->num_mzs;i ++){

					this->ephe_mat[ i ][ j ] = 0;
					this->matched_mz_mat[ i ][ j ] = -1;

				}

			}

		}
	}



	template <class T_mtime, class T_mz, class T_intst>
	EPheMatrix1_eq_intervals<T_mtime, T_mz, T_intst>::~EPheMatrix1_eq_intervals()
	{

		cout << "Deleting calculated MTs and m/z's ... " << endl;
		delete[] this->ref_mts;
		delete[] this->ref_mzs;

	};




	template class EPheMatrix1<float, float, int>;
	template class EPheMatrix1<float, double, int>;
	template class EPheMatrix1<float, float, double>;

	template class EPheMatrix1_eq_intervals<float, float, int>;
	template class EPheMatrix1_eq_intervals<float, double, int>;
	template class EPheMatrix1_eq_intervals<float, float, double>;


} /* namespace rsMassSpec */
