/*
 * ROIDetectsimple1.cpp
 *
 *  Created on: 2022/07/05
 *      Author: rsaito
 */

#include <list>
#include <iostream>

#include "MassSpec/ROIDetectsimple1.h"
#include "MassSpec/EPheMatrix1.h"
#include "MassSpec/MassSpectrum_simple.h"
#include "MassSpec/ROIEPheMatFindPeaks1.h"
#include "Tasks/mspectra_ROI1.h"

#include "Usefuls/array2d.h"
#include "Usefuls/closest_value_in_sorted1.h"
#include "Usefuls/calc_simple1.h"
#include "Usefuls/list_proc1.h"

#include "MATLAB/MATLAB_scan_spectrum_gauss_fit1_4.h"

using namespace std;

namespace rsMassSpec {

	template <class T_mtime, class T_mz, class T_intst>
	ROI_Detect_simple1<T_mtime, T_mz, T_intst>::ROI_Detect_simple1(
			EPheMatrix1<T_mtime, T_mz, T_intst> *iephemat_p
	){
		// TODO Auto-generated constructor stub

		this->ephemat_p = iephemat_p;

	}

	template <class T_mtime, class T_mz, class T_intst>
	ROI_Detect_simple1<T_mtime, T_mz, T_intst>::~ROI_Detect_simple1() {
		// TODO Auto-generated destructor stub

		if(this->roi_flag != nullptr){
			del_array2d<char>(
					this->roi_flag,
					this->ephemat_p->num_mzs,
					this->ephemat_p->num_mts);
			cout << "Released ROI marks." << endl;
		}

		if(this->zscore_smoothed_mat != nullptr){
			del_array2d<double>(
					this->zscore_smoothed_mat,
					this->ephemat_p->num_mzs,
					this->ephemat_p->num_mts);
			cout << "Released Z score smoothed matrix." << endl;
		}

		if(this->zscore_mat != nullptr){
			del_array2d<double>(
					this->zscore_mat,
					this->ephemat_p->num_mzs,
					this->ephemat_p->num_mts);
			cout << "Released Z Score matrix." << endl;
		}

	}

	template <class T_mtime, class T_mz, class T_intst>
		void ROI_Detect_simple1<T_mtime, T_mz, T_intst>::mark_ROIs(
				T_mtime base_mt_start, T_mtime base_mt_end,
				double smooth_range_mz_cells,
				double smooth_range_mt_cells,
				double zscore_signal_thres,
				double zscore_base_thres,
				int num_mzs_extensions,
				int num_mts_extensions){

		cout << "Calculating Z-scores ..." << endl;
		this->calc_zscore(base_mt_start, base_mt_end);
		cout << "Calculating Z-scores ... done." << endl;

		this->zscore_smoothed_mat = init_array2d<double>(
				this->ephemat_p->num_mzs,
				this->ephemat_p->num_mts,
				0);

		cout << "Smoothing Z-scores ..." << endl;
		smooth_triang_simple<double>(
				this->zscore_mat,
				this->ephemat_p->num_mzs,
				this->ephemat_p->num_mts,
				smooth_range_mz_cells,
				smooth_range_mt_cells,
				this->zscore_smoothed_mat);
		cout << "Smoothing Z-scores ... done." << endl;



		/*
		ROI_EPheMat_FindPeaks1<T_mtime, T_mz> roi_ephemat_fpeaks
			= ROI_EPheMat_FindPeaks1<T_mtime, T_mz>(
					this->zscore_mat, this->zscore_smoothed_mat,
					this->ephemat_p->ref_mzs, this->ephemat_p->num_mzs,
					this->ephemat_p->ref_mts, this->ephemat_p->num_mts);
		roi_ephemat_fpeaks.search_write_peak_info(
				zscore_signal_thres, zscore_base_thres);
		 */


		this->roi_flag =
			init_array2d<char>(
					this->ephemat_p->num_mzs,
					this->ephemat_p->num_mts,
					0);

		cout << "Marking ROIs ..." << endl;
		mark_ephemat_roi_surround(
				this->zscore_smoothed_mat,
				this->ephemat_p->num_mzs,
				this->ephemat_p->num_mts,
				this->roi_flag,
				zscore_signal_thres,
				zscore_base_thres,
				num_mzs_extensions,
				num_mts_extensions);
		cout << "Marking ROIs ... done." << endl;

	}


	template <class T_mtime, class T_mz, class T_intst>
		void ROI_Detect_simple1<T_mtime, T_mz, T_intst>::calc_zscore(
				T_mtime mt_start, T_mtime mt_end){

		this->zscore_mat = init_array2d<double>(
				this->ephemat_p->num_mzs,
				this->ephemat_p->num_mts,
				0);

		int mt_start_idx = this->ephemat_p->get_closest_ref_mt_idx(mt_start);
		int mt_end_idx = this->ephemat_p->get_closest_ref_mt_idx(mt_end);

		// cout << mt_start_idx << "---" << mt_end_idx << endl;

		for(int i = 0;i < this->ephemat_p->num_mzs;i ++){
			double cmean =
				mean_simple<T_intst>(&this->ephemat_p->ephe_mat[i][mt_start_idx], mt_end_idx - mt_start_idx + 1);
			double csd   =
				sd_estim_simple(&this->ephemat_p->ephe_mat[i][mt_start_idx], mt_end_idx - mt_start_idx + 1);


			/*
			if(65.0 <= this->ephemat_p->ref_mzs[i] && this->ephemat_p->ref_mzs[i] <= 65.1){
				cout << i << " " << this->ephemat_p->ref_mzs[i] << " Mean: " << cmean << "  SD: " << csd <<
						"  Var: " << var_estim_simple(&this->ephemat_p->ephe_mat[i][mt_start_idx], mt_end_idx - mt_start_idx + 1)
						<< endl;
			}

			if(i == 1728){
				for(int j = mt_start_idx;j <= mt_end_idx;j ++){
					cout << j << " " << this->ephemat_p->ref_mts[j] << " " << this->ephemat_p->ephe_mat[i][j] << endl;
				}
				// var_estim_simple(&this->ephemat_p->ephe_mat[i][mt_start_idx], mt_end_idx - mt_start_idx + 1); // For debugger

			}
			 */


			for(int j = 0;j < this->ephemat_p->num_mts;j ++)
				// this->zscore_mat[i][j] = (this->ephemat_p->ephe_mat[i][j] - cmean) / csd;
				if(csd != 0)
					this->zscore_mat[i][j] = (this->ephemat_p->ephe_mat[i][j] - cmean) / csd;
				else
					this->zscore_mat[i][j] = 0;
		}

	}

	template <class T_mtime, class T_mz, class T_intst>
	RS_MassSpectra_simple<T_mtime, T_mz, T_intst>
		*ROI_Detect_simple1<T_mtime, T_mz, T_intst>::get_mspectra_roi(){
		// Needs to be checked & debugged.

		list<MassSpectrum_simple<T_mz, T_intst> *> roi_mspectrum_p_list;
		list<T_mtime> roi_MT_list;

		for(int j = 0;j < this->ephemat_p->num_mts;j ++){
			MassSpectrum_simple<T_mz, T_intst> *cur_mspectrum
				= this->ephemat_p->rsmspectra_p->mspectra[ j ];
			int closest_ref_mt_idx = this->ephemat_p->get_ephe_mt_idx_from_mspec_mt_idx(j);

			list<T_mz> roi_mzs_list;
			list<T_intst> roi_intsts_list;

			for(int i = 0;i < cur_mspectrum->num_mzs;i ++){

				T_mz cur_mz = cur_mspectrum->mzs[i];
				int closest_ref_mz_idx = this->ephemat_p->get_closest_ref_mz_idx(cur_mz);
				if(this->roi_flag[closest_ref_mz_idx][ closest_ref_mt_idx ]){
					roi_mzs_list.push_back(cur_mz);
					roi_intsts_list.push_back(cur_mspectrum->intsts[i]);
					// cout << "-ROI-";
				}
				else {
					// cout << "-DEL-";
				}

				/*
				cout << " MT #" << j << "(" << this->ephemat_p->rsmspectra_p->mtimes[j] << ") m/z #" << i << " (" << cur_mz << ") Intensity: " << cur_mspectrum->intsts[i];
				cout << " Matched MT: " << this->ephemat_p->ref_mts[closest_ref_mt_idx] << " Matched MT index: " << closest_ref_mt_idx;
				cout << " Matched m/z: " << this->ephemat_p->ref_mzs[closest_ref_mz_idx] << " Matched m/z index: " << closest_ref_mz_idx << endl;
				 */

			}

			if(roi_mzs_list.size()){
				T_mz *roi_mzs = list_to_allocated_array(roi_mzs_list);
				T_intst *roi_intsts = list_to_allocated_array(roi_intsts_list);
				MassSpectrum_simple<T_mz, T_intst> *roi_spectrum_p
					= new MassSpectrum_simple<T_mz, T_intst>();

				roi_spectrum_p->set_spectrum(roi_mzs_list.size(), roi_mzs, roi_intsts);
				roi_mspectrum_p_list.push_back(roi_spectrum_p);
				roi_MT_list.push_back(this->ephemat_p->rsmspectra_p->mtimes[ j ]);

			}

		}

		RS_MassSpectra_simple<T_mtime, T_mz, T_intst> *mspectra_roi_p
			= new RS_MassSpectra_simple<T_mtime, T_mz, T_intst>(roi_mspectrum_p_list.size());

		typename list<MassSpectrum_simple<T_mz, T_intst> *>::iterator itr_mspectrum_p;
			// = roi_mspectrum_p_list.begin();
		typename list<T_mtime>::iterator itr_MT;
			// = roi_MT_list.begin();

		for (itr_mspectrum_p = roi_mspectrum_p_list.begin(),
			 itr_MT = roi_MT_list.begin();
			itr_mspectrum_p != roi_mspectrum_p_list.end() && itr_MT != roi_MT_list.end();
			itr_mspectrum_p++, itr_MT++) {

			mspectra_roi_p->add_spectrum(
				*itr_MT,
				*itr_mspectrum_p);

		}

		/*
		MassSpectrum_simple<T_mz, T_intst> *roi_mspectrum_p
			= list_to_allocated_array(roi_mspectrum_p_list);
		T_mtime *roi_MTs
			= list_to_allocated_array(roi_MT_list);
		*/

		return mspectra_roi_p;

	}

	template <class T_mtime, class T_mz, class T_intst>
	RS_MassSpectra_simple<T_mtime, T_mz, T_intst>
		*ROI_Detect_simple1<T_mtime, T_mz, T_intst>::get_mspectra_roi_gaussfit(){
		// Needs to be checked & debugged.

		list<MassSpectrum_simple<T_mz, T_intst> *> roi_mspectrum_p_list;
		list<T_mtime> roi_MT_list;

		for(int j = 0;j < this->ephemat_p->num_mts;j ++){

			list<T_mz> roi_mzs_list;
			list<T_intst> roi_intsts_list;
			this->get_mspectrum_roi_gaussfit(j, roi_mzs_list, roi_intsts_list);

			if(roi_mzs_list.size()){
				T_mz *roi_mzs       = list_to_allocated_array(roi_mzs_list);
				T_intst *roi_intsts = list_to_allocated_array(roi_intsts_list);
				MassSpectrum_simple<T_mz, T_intst> *roi_spectrum_p
					= new MassSpectrum_simple<T_mz, T_intst>();

				roi_spectrum_p->set_spectrum(roi_mzs_list.size(), roi_mzs, roi_intsts);
				roi_mspectrum_p_list.push_back(roi_spectrum_p);
				roi_MT_list.push_back(this->ephemat_p->rsmspectra_p->mtimes[ j ]);

			}

			// cout << "Looked mass spectrum " << j << endl;

		}

		// cout << "Gone through all mass spectra." << endl;

		RS_MassSpectra_simple<T_mtime, T_mz, T_intst> *mspectra_roi_p
			= new RS_MassSpectra_simple<T_mtime, T_mz, T_intst>(roi_mspectrum_p_list.size());

		typename list<MassSpectrum_simple<T_mz, T_intst> *>::iterator itr_mspectrum_p;
			// = roi_mspectrum_p_list.begin();
		typename list<T_mtime>::iterator itr_MT;
			// = roi_MT_list.begin();

		for (itr_mspectrum_p = roi_mspectrum_p_list.begin(),
			 itr_MT = roi_MT_list.begin();
			itr_mspectrum_p != roi_mspectrum_p_list.end() && itr_MT != roi_MT_list.end();
			itr_mspectrum_p++, itr_MT++) {

			mspectra_roi_p->add_spectrum(
				*itr_MT,
				*itr_mspectrum_p);

		}

		/*
		MassSpectrum_simple<T_mz, T_intst> *roi_mspectrum_p
			= list_to_allocated_array(roi_mspectrum_p_list);
		T_mtime *roi_MTs
			= list_to_allocated_array(roi_MT_list);
		*/

		return mspectra_roi_p;

	}


	template <class T_mtime, class T_mz, class T_intst>
	void ROI_Detect_simple1<T_mtime, T_mz, T_intst>::write_zscore_mat(const char* ofilenam) {

		write_array2d(
			ofilenam,
			this->zscore_mat,
			this->ephemat_p->num_mzs,
			this->ephemat_p->num_mts,
			this->ephemat_p->ref_mzs,
			this->ephemat_p->ref_mts);

	}

	template <class T_mtime, class T_mz, class T_intst>
	void ROI_Detect_simple1<T_mtime, T_mz, T_intst>::write_zscore_smoothed_mat(const char* ofilenam) {

		write_array2d(
			ofilenam,
			this->zscore_smoothed_mat,
			this->ephemat_p->num_mzs,
			this->ephemat_p->num_mts,
			this->ephemat_p->ref_mzs,
			this->ephemat_p->ref_mts);

	}



	template <class T_mtime, class T_mz, class T_intst>
	void ROI_Detect_simple1<T_mtime, T_mz, T_intst>::write_roi_flag_mat(const char *ofilenam) {

		write_array2d(
			ofilenam,
			this->roi_flag,
			this->ephemat_p->num_mzs,
			this->ephemat_p->num_mts,
			this->ephemat_p->ref_mzs,
			this->ephemat_p->ref_mts);

	}


	template <class T_mtime, class T_mz, class T_intst>
	void ROI_Detect_simple1<T_mtime, T_mz, T_intst>::get_mspectrum_roi_gaussfit(
			int j, list<T_mz> &roi_mzs_list, list<T_intst> &roi_intsts_list){

		list<T_mz> roi_mzs_list_partial;
		list<T_intst> roi_intsts_list_partial;
		int matlab_coder_func_used = 0;

		MassSpectrum_simple<T_mz, T_intst> *cur_mspectrum
			= this->ephemat_p->rsmspectra_p->mspectra[ j ];
		int closest_ref_mt_idx = this->ephemat_p->get_ephe_mt_idx_from_mspec_mt_idx(j);

		for(int i = 0;i <= cur_mspectrum->num_mzs;i ++){
			// Caution: i goes up to cur_mspectrum->num_mzs

			T_mz cur_mz;
			int closest_ref_mz_idx;

			if(i < cur_mspectrum->num_mzs){
				cur_mz = cur_mspectrum->mzs[i];
				closest_ref_mz_idx = this->ephemat_p->get_closest_ref_mz_idx(cur_mz);
			}

			if (i == cur_mspectrum->num_mzs || this->roi_flag[ closest_ref_mz_idx ][ closest_ref_mt_idx ] == 0)
			 { // Be careful about the last m/z
				int spectrum_fragm_size;
				double *roi_mzs_partial    = list_to_allocated_array_tconv<T_mz, double>(roi_mzs_list_partial);
				double *roi_intsts_partial = list_to_allocated_array_tconv<T_intst, double>(roi_intsts_list_partial);

				// cout << "Spectrum fragment size: " << roi_mzs_list_partial.size() << endl;

				if (roi_mzs_list_partial.size() >= GAUSSFIT_MIN_DAT_POINTS){

					double *roi_mzs_partial_gs;
					double *roi_intsts_partial_gs;

					/* if(j == 1000){
						cout << "Fragment size: " << roi_mzs_list_partial.size() << endl;
						for(int tmp_i = 0;tmp_i < roi_mzs_list_partial.size(); tmp_i ++){
							cout << roi_mzs_partial[tmp_i] << ' ' << roi_intsts_partial[tmp_i] << ';' << endl;
						}
					} */

					spectrum_fragm_size = MATLAB_scan_spectrum_gauss_fit1_4(
							roi_mzs_partial, roi_intsts_partial,
							roi_mzs_list_partial.size(),
							&roi_mzs_partial_gs, &roi_intsts_partial_gs);
					matlab_coder_func_used = 1;

					delete[] roi_mzs_partial;
					delete[] roi_intsts_partial;
					roi_mzs_partial    = roi_mzs_partial_gs;
					roi_intsts_partial = roi_intsts_partial_gs;


					/* if(j == 1000){
						cout << "Gaussian fitting done." << endl;
						for(int tmp_i = 0;tmp_i < spectrum_fragm_size; tmp_i ++){
							cout << roi_mzs_partial[tmp_i] << ' ' << roi_intsts_partial[tmp_i] << ';' << endl;
						}
					} */


				} else {
					spectrum_fragm_size = roi_mzs_list_partial.size();
				}

				for(int k = 0;k < spectrum_fragm_size;k ++){
					roi_mzs_list.push_back((T_mz)roi_mzs_partial[k]);
					roi_intsts_list.push_back((T_intst)roi_intsts_partial[k]);

				}

				delete[] roi_mzs_partial;
				delete[] roi_intsts_partial;
				roi_mzs_list_partial.clear();
				roi_intsts_list_partial.clear();
				// cout << "-DEL-";

			}

			else {
				roi_mzs_list_partial.push_back(cur_mz);
				roi_intsts_list_partial.push_back(cur_mspectrum->intsts[i]);
				// if (j == 1000)cout << "[ ROI ] " << cur_mz << '\t' << cur_mspectrum->intsts[i] << endl;
				// cout << "within ROI." << endl;
				// cout << "-ROI-";
			}


			/*
			cout << " MT #" << j << "(" << this->ephemat_p->rsmspectra_p->mtimes[j] << ") m/z #" << i << " (" << cur_mz << ") Intensity: " << cur_mspectrum->intsts[i];
			cout << " Matched MT: " << this->ephemat_p->ref_mts[closest_ref_mt_idx] << " Matched MT index: " << closest_ref_mt_idx;
			cout << " Matched m/z: " << this->ephemat_p->ref_mzs[closest_ref_mz_idx] << " Matched m/z index: " << closest_ref_mz_idx << endl;
			 */

		}

		if (matlab_coder_func_used > 0)
			MATLAB_scan_spectrum_gauss_fit1_4_terminate(); // If MATLAB function used.


		/* if(j == 1000){
			typename list<T_mz>::iterator itr_mz_p;
			typename list<T_intst>::iterator itr_intst_p;
				// = roi_MT_list.begin();

			cout << "Output spectrum (ROI)" << endl;
			for (itr_mz_p    = roi_mzs_list.begin(),
				 itr_intst_p = roi_intsts_list.begin();
				 itr_mz_p != roi_mzs_list.end() && itr_intst_p != roi_intsts_list.end();
				 itr_mz_p ++, itr_intst_p++) {

				cout << *itr_mz_p << '\t' << *itr_intst_p << endl;

			}
		} */


	}


	template class ROI_Detect_simple1<float, float, double>;
	template class ROI_Detect_simple1<float, float, int>;

} /* namespace rsMassSpec */
