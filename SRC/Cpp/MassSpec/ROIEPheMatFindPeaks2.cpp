#define _CRT_SECURE_NO_WARNINGS

/*
 * ROIEPheMatFindPeaks2.cpp
 *
 *  Created on: 2022/08/18
 *      Author: rsaito
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>
#include <fstream>
#include <boost/filesystem.hpp>


#include "MassSpec/MassSpectrum_simple.h"
#include "MassSpec/ROIEPheMatFindPeaks2.h"

#include "Exceptions/rsMHandsExcept1.h"

#include "Usefuls/array2d.h"
#include "Usefuls/calc_simple1.h"
#include "Tasks/find_signif_ranges1.h"
#include "Usefuls/closest_value_in_sorted1.h"
// #include "PeakProc/PeakInfo1.h"
// #include "PeakProc/SplitPeak1.h"


using namespace std;
using namespace boost::filesystem;

namespace rsMassSpec {

	template <class T_mtime, class T_mz, class T_intst>
	void write_picked_pks_infos(
			const char *ofilnam,
			list<picked_peak_info<T_mtime, T_mz, T_intst> > ipicked_peaks_infos){

		std::ofstream fcout;
		fcout.open(ofilnam);


		fcout
			<< '\t'
			<< "Start MT" << '\t'
			<< "End MT" << '\t'
			<< "Top MT" << '\t'
			<< "Top intensity" << '\t'
			<< "Top Z score" << '\t'
			<< "Top m/z" << '\t'
			<< "Investigating m/z" << '\t'
			<< "Mean m/z" << '\t'
			<< "S.D. of m/z" << '\t'
			<< "Area" << '\n';


		for(picked_peak_info<T_mtime, T_mz, T_intst> each_pkinfo : ipicked_peaks_infos){

			fcout
				<< each_pkinfo.picked_peak_id << '\t'
				<< each_pkinfo.start_mt << '\t'
				<< each_pkinfo.end_mt << '\t'
				<< each_pkinfo.top_mt << '\t'
				<< each_pkinfo.top_intensity << '\t'
				<< each_pkinfo.top_zscore << '\t'
				<< each_pkinfo.top_mz << '\t'
				<< each_pkinfo.investig_mz << '\t'
				<< each_pkinfo.mz_mean << '\t'
				<< each_pkinfo.mz_sd << '\t'
				<< each_pkinfo.area << '\n';

		}

	}


	template <class T_mtime, class T_mz, class T_intst>
	ROIEPheMatFindPeaks<T_mtime, T_mz, T_intst>::ROIEPheMatFindPeaks(
		RS_MassSpectra_simple<T_mtime, T_mz, T_intst> *imspectra_p, T_mtime iref_mt,
		double imz_diff_thres,
		T_mtime ibase_mt_start, T_mtime ibase_mt_end,
		double smooth_range_mz_cells,
		double smooth_range_mt_cells,
		double izscore_signal_thres,
		double izscore_base_thres,
		int num_mzs_extensions,
		int num_mts_extensions,
		double split_alt_peaktop_thres,
		double split_peak_drop_rate_thres,
		double split_peak_rerise_rate_thres,
		double split_peak_rerise_factor_thres){

		this->zscore_signal_thres = izscore_signal_thres;
		this->zscore_base_thres = izscore_base_thres;

		this->base_mt_start = ibase_mt_start;
		this->base_mt_end = ibase_mt_end;

		this->mspectra_p = imspectra_p;
		this->ephe_mat_p = new EPheMatrix1<T_mtime, T_mz, T_intst>(imspectra_p, iref_mt);
		this->roi_detect_p = new ROI_Detect_simple1<T_mtime, T_mz, T_intst>(this->ephe_mat_p);
		this->mark_ROIs(
			ibase_mt_start, ibase_mt_end,
			smooth_range_mz_cells, smooth_range_mt_cells,
			izscore_signal_thres, izscore_base_thres,
			num_mzs_extensions, num_mts_extensions);

		this->splitpeak_thres.split_alt_peaktop_thres = split_alt_peaktop_thres;
		this->splitpeak_thres.split_peak_drop_rate_thres = split_peak_drop_rate_thres;
		this->splitpeak_thres.split_peak_rerise_rate_thres = split_peak_rerise_rate_thres;
		this->splitpeak_thres.split_peak_rerise_factor_thres = split_peak_rerise_factor_thres;

		cout << "Gaussian fitting of ROI ..." << endl;
		this->roi_spectra_p
			= this->roi_detect_p->get_mspectra_roi_gaussfit(); // <--- !!! get_mspectra_roi();
		cout << "Gaussian fitting of ROI ... done." << endl;

		/*
		cout << "Z-score" << endl;
		display_array2d<double, T_mtime, T_mz>(
			this->roi_detect_p->zscore_mat,
			this->roi_detect_p->ephemat_p->num_mzs, this->roi_detect_p->ephemat_p->num_mts,
			this->roi_detect_p->ephemat_p->ref_mzs, this->roi_detect_p->ephemat_p->ref_mts);
		cout << endl;

		cout << "Z-score smoothed" << endl;
		display_array2d<double, T_mtime, T_mz>(
			this->roi_detect_p->zscore_smoothed_mat,
			this->roi_detect_p->ephemat_p->num_mzs, this->roi_detect_p->ephemat_p->num_mts,
			this->roi_detect_p->ephemat_p->ref_mzs, this->roi_detect_p->ephemat_p->ref_mts);
		cout << endl;
		 */

		if(this->roi_spectra_p->num_spectra == 0)
			throw rsMHandsExcept("ROI spectra empty");

		cout << "Mass Spectra for ROI generated." << endl;

		range_idx_simple base_mt_range_idx
			= this->mspectra_p->get_closest_mt_idx_range_from_mt_pair(ibase_mt_start, ibase_mt_end);
		cout << "Base range obtained." << endl;

		range_idx_simple roi_mt_range_idx
			= this->roi_spectra_p->get_closest_mt_idx_range_from_mt_pair(ibase_mt_end, 99999999.9);

		cout << "Base and ROI ranges obtained." << endl;

		this->hybrid_spectra_p = new RS_MassSpectra_simple<T_mtime, T_mz, T_intst>(
				base_mt_range_idx.end - base_mt_range_idx.start + 1 +
				roi_mt_range_idx.end - roi_mt_range_idx.start + 1
		);

		cout << "Trying to fill hybrid spectra ..." << endl;

		for(int i = base_mt_range_idx.start; i <= base_mt_range_idx.end; i++){
			// MassSpectrum_simple<T_mz, T_intst> cspectrum = *(this->mspectra_p->mspectra[i]);
			this->hybrid_spectra_p->add_spectrum(
					this->mspectra_p->mtimes[i],
					this->mspectra_p->mspectra[i]->gen_copy());
		}

		cout << "Base spectra filled in hybrid spectra." << endl;

		for(int i = roi_mt_range_idx.start;i <= roi_mt_range_idx.end;i ++){
			this->hybrid_spectra_p->add_spectrum(
					this->roi_spectra_p->mtimes[i],
					this->roi_spectra_p->mspectra[i]->gen_copy());
		}

		cout << "ROI spectra filled in hybrid spectra." << endl;

		this->ephe_mat_hybrid_p
			= new EPheMatrix1<T_mtime, T_mz, T_intst>(this->hybrid_spectra_p, iref_mt, imz_diff_thres, 1);

		this->calc_zscore(this->base_mt_start, this->base_mt_end);

		cout << "Calculated Z-score for hybrid matrix." << endl;

		this->picked_peaks_infos =  this->pick_peaks();
		/*
		for (picked_peak_info<T_mtime, T_mz, T_intst> pkinfo : this->picked_peaks_infos) {
			cout << "Peak: " << pkinfo.start_idx << " - " << pkinfo.end_idx << endl;
		}
		 */

	}

	template <class T_mtime, class T_mz, class T_intst>
	ROIEPheMatFindPeaks<T_mtime, T_mz, T_intst>::~ROIEPheMatFindPeaks() {

		cout << "---+++ Initiating deletions ..." << endl;

		delete this->hybrid_spectra_p;
		cout << "--- Hybrid spectra deleted." << endl;

		delete this->roi_spectra_p;
		cout << "--- ROI spectra deleted." << endl;

		delete this->roi_detect_p;
		cout << "--- ROI detection deleted." << endl;

		delete this->ephe_mat_p;
		cout << "--- Ephe matrix deleted." << endl;

		if (NULL != this->hybrid_zscore_mat) {
			del_array2d(this->hybrid_zscore_mat,
					this->ephe_mat_hybrid_p->num_mzs,
					this->ephe_mat_hybrid_p->num_mts);
			delete[] this->mean_each_mz;
			cout << "--- Hybrid Z-score matrix deleted." << endl;
		}

		// This class does NOT allocate mspectra_p, so mspectra_p should be released
		//    in the caller
		// delete this->mspectra_p;
		// cout << "--- MSpectra deleted." << endl;
	
	}


	template <class T_mtime, class T_mz, class T_intst>
	void ROIEPheMatFindPeaks<T_mtime, T_mz, T_intst>::write_picked_peaks_infos(
			const char *ofilnam){

		write_picked_pks_infos<T_mtime, T_mz, T_intst>(
				ofilnam, this->picked_peaks_infos);

	}

	template <class T_mtime, class T_mz, class T_intst>
	void ROIEPheMatFindPeaks<T_mtime, T_mz, T_intst>::mark_ROIs(
			T_mtime base_mt_start, T_mtime base_mt_end,
			double smooth_range_mz_cells,
			double smooth_range_mt_cells,
			double zscore_signal_thres,
			double zscore_base_thres,
			int num_mzs_extensions,
			int num_mts_extensions){

		this->roi_detect_p->mark_ROIs(
				base_mt_start, base_mt_end,
				smooth_range_mz_cells, smooth_range_mt_cells,
				zscore_signal_thres, zscore_base_thres,
				num_mzs_extensions, num_mts_extensions);

	}


	template <class T_mtime, class T_mz, class T_intst>
	void ROIEPheMatFindPeaks<T_mtime, T_mz, T_intst>::calc_zscore(
		T_mtime ibase_mt_start, T_mtime ibase_mt_end) {

		this->hybrid_zscore_mat = init_array2d<double>(
			this->ephe_mat_hybrid_p->num_mzs,
			this->ephe_mat_hybrid_p->num_mts,
			0);
		this->mean_each_mz = new double[ this->ephe_mat_hybrid_p->num_mzs ];

		range_idx_simple base_mt_range_idx
			= this->hybrid_spectra_p->get_closest_mt_idx_range_from_mt_pair(ibase_mt_start, ibase_mt_end);

		int base_mt_start_idx = base_mt_range_idx.start;
		int base_mt_end_idx = base_mt_range_idx.end;

		// cout << mt_start_idx << "---" << mt_end_idx << endl;

		for (int i = 0; i < this->ephe_mat_hybrid_p->num_mzs; i++) {
			double cmean =
				mean_simple<T_intst>(&this->ephe_mat_hybrid_p->ephe_mat[i][base_mt_start_idx], base_mt_end_idx - base_mt_start_idx + 1);
			double csd =
				sd_estim_simple(&this->ephe_mat_hybrid_p->ephe_mat[i][base_mt_start_idx], base_mt_end_idx - base_mt_start_idx + 1);
			this->mean_each_mz[i] = cmean;

			// cout << i << '\t' << this->ephe_mat_hybrid_p->ref_mzs[i] << '\t' << cmean << " - " << csd << endl;

			T_mz cmz = this->ephe_mat_hybrid_p->ref_mzs[i];
			int roi_idx_i = closest_value_in_sorted_get_idx(
					this->roi_detect_p->ephemat_p->ref_mzs,
					this->roi_detect_p->ephemat_p->num_mzs, cmz);

			for (int j = 0; j < this->ephe_mat_hybrid_p->num_mts; j++){
				// this->hybrid_zscore_mat[i][j] = (this->ephemat_p->ephe_mat[i][j] - cmean) / csd;

				T_mtime cmt = this->ephe_mat_hybrid_p->ref_mts[j];
				int roi_idx_j = closest_value_in_sorted_get_idx(
						this->roi_detect_p->ephemat_p->ref_mts,
						this->roi_detect_p->ephemat_p->num_mts, cmt);

				// ROI check needs to be checked.
				if (csd != 0 && this->roi_detect_p->roi_flag[ roi_idx_i ][ roi_idx_j ])
					this->hybrid_zscore_mat[i][j] = (this->ephe_mat_hybrid_p->ephe_mat[i][j] - cmean) / csd;
				else
					this->hybrid_zscore_mat[i][j] = 0;

			}
		}

	}


	template <class T_mtime, class T_mz, class T_intst>
	void ROIEPheMatFindPeaks<T_mtime, T_mz, T_intst>::write_hybrid_zscore_mat_txt(const char *ofilnam){

		write_array2d(
			ofilnam,
			this->hybrid_zscore_mat,
			this->ephe_mat_hybrid_p->num_mzs,
			this->ephe_mat_hybrid_p->num_mts,
			this->ephe_mat_hybrid_p->ref_mzs,
			this->ephe_mat_hybrid_p->ref_mts);

	}

	template <class T_mtime, class T_mz, class T_intst>
	void ROIEPheMatFindPeaks<T_mtime, T_mz, T_intst>::write_hybrid_zscore_mat(const char* ofilnam, int eq_interval_mode) {


		if(eq_interval_mode == 0){

			rsBinaryDat::write_2dmap(
				ofilnam,
				this->ephe_mat_hybrid_p->ref_mzs,
				(unsigned int)this->ephe_mat_hybrid_p->num_mzs,
				this->ephe_mat_hybrid_p->ref_mts,
				(unsigned int)this->ephe_mat_hybrid_p->num_mts,
				this->hybrid_zscore_mat, // roiephemat.roi_detect_p->roi_flag, // roiephemat.roi_detect_p->zscore_mat
				256);

		} else {
		
			rsarray2d<double, double, double> hybrid_zscore_eqinterval_mat_info
				= conv_to_eq_intervals_2d(
						this->hybrid_zscore_mat,
						this->ephe_mat_hybrid_p->num_mzs,
						this->ephe_mat_hybrid_p->num_mts,
						this->ephe_mat_hybrid_p->ref_mzs,
						this->ephe_mat_hybrid_p->ref_mts);

			rsBinaryDat::write_2dmap(
				ofilnam,
				hybrid_zscore_eqinterval_mat_info.labels_m,
				(unsigned int)hybrid_zscore_eqinterval_mat_info.len_m,
				hybrid_zscore_eqinterval_mat_info.labels_n,
				(unsigned int)hybrid_zscore_eqinterval_mat_info.len_n,
				hybrid_zscore_eqinterval_mat_info.array2d,
				256);

			del_array2d(hybrid_zscore_eqinterval_mat_info.array2d,
					hybrid_zscore_eqinterval_mat_info.len_m,
					hybrid_zscore_eqinterval_mat_info.len_n);

			delete[] hybrid_zscore_eqinterval_mat_info.labels_m;
			delete[] hybrid_zscore_eqinterval_mat_info.labels_n;

		}

	}


	template <class T_mtime, class T_mz, class T_intst>
	list<picked_peak_info<T_mtime, T_mz, T_intst> > ROIEPheMatFindPeaks<T_mtime, T_mz, T_intst>::pick_peaks() {

		list<picked_peak_info<T_mtime, T_mz, T_intst> > picked_peaks;

		double *ephe_minus_base = new double[ this->ephe_mat_hybrid_p->num_mts ];
		double *ephe_zscore_nozeros = new double[ this->ephe_mat_hybrid_p->num_mts ];

		for (int i = 0; i < this->ephe_mat_hybrid_p->num_mzs; i++) {
			for(int j = 0;j < this->ephe_mat_hybrid_p->num_mts; j++){
				ephe_minus_base[j] = this->ephe_mat_hybrid_p->ephe_mat[i][j] - this->mean_each_mz[i]; // this->hybrid_zscore_mat[i][j]
 				if (ephe_minus_base[j] < 0)ephe_minus_base[j] = 0; // Necessary?
				if (this->hybrid_zscore_mat[i][j] < 0)
					ephe_zscore_nozeros[j] = 0;
				else
					ephe_zscore_nozeros[j] = this->hybrid_zscore_mat[i][j];
				}
			list<each_range_info> peak_ranges_each_mz
				= find_signif_ranges_zscores(
					this->hybrid_zscore_mat[i],
					this->ephe_mat_hybrid_p->num_mts,
					this->zscore_signal_thres, this->zscore_base_thres);

			/*
			cout << "ephe_zscore_nozeros, mean_each_mz@" << this->ephe_mat_hybrid_p->ref_mzs[i] << ":" << endl;
			for(int j = 0;j < this->ephe_mat_hybrid_p->num_mts; j++)
				cout << j << ":" << this->ephe_mat_hybrid_p->ref_mts[j] << '\t'
					<< ephe_zscore_nozeros[j] << '\t' << ephe_minus_base[j] << endl;
			 */

			int ct_peak_range = 0;
			for (each_range_info pkrange : peak_ranges_each_mz) {
				PeakInfo<double> pkinfo(&ephe_zscore_nozeros[ pkrange.start_idx ],
						pkrange.start_idx, pkrange.end_idx);

				/*
				cout << "Before split ... "
					<< this->ephe_mat_hybrid_p->ref_mzs[i] << ": "
					<< this->ephe_mat_hybrid_p->ref_mts[ pkinfo.top_abs_idx ] << endl;
				 */

				SplitPeak<double> split_peak(pkinfo, this->splitpeak_thres);
				list<PeakInfo<double> > split_peak_list = split_peak.split_peak(pkinfo);

				int ct_peak_split = 0;
				for (PeakInfo<double> res_split_peak : split_peak_list) {

					picked_peak_info<T_mtime, T_mz, T_intst> each_picked_peak_info;
					each_picked_peak_info.start_idx = res_split_peak.start_abs_idx;
					each_picked_peak_info.end_idx = res_split_peak.end_abs_idx;
					each_picked_peak_info.top_idx = res_split_peak.top_abs_idx;

					each_picked_peak_info.start_mt = this->ephe_mat_hybrid_p->ref_mts[each_picked_peak_info.start_idx];
					each_picked_peak_info.end_mt = this->ephe_mat_hybrid_p->ref_mts[each_picked_peak_info.end_idx];
					each_picked_peak_info.top_mt = this->ephe_mat_hybrid_p->ref_mts[each_picked_peak_info.top_idx];
					each_picked_peak_info.top_mz = this->ephe_mat_hybrid_p->matched_mz_mat[i][each_picked_peak_info.top_idx];

					each_picked_peak_info.investig_mz = this->ephe_mat_hybrid_p->ref_mzs[i];

					each_picked_peak_info.top_intensity = this->ephe_mat_hybrid_p->ephe_mat[i][each_picked_peak_info.top_idx];
					each_picked_peak_info.top_zscore = this->hybrid_zscore_mat[i][each_picked_peak_info.top_idx];

					double mz_sum = 0;
					int mz_ct = 0;
					double area = 0;
					for(int k = each_picked_peak_info.start_idx;
						k <= each_picked_peak_info.end_idx; k++){
							area += ephe_minus_base[k];
							T_mz matched_mz = this->ephe_mat_hybrid_p->matched_mz_mat[i][k];
							if (matched_mz > 0){
								mz_sum += (double)matched_mz;
								mz_ct ++;
							}
						}

					if(mz_ct){
						each_picked_peak_info.mz_mean = mz_sum / mz_ct;

						double mz_mmean_sqr_sum = 0.0;
						for(int k = each_picked_peak_info.start_idx;
							k <= each_picked_peak_info.end_idx; k++){
								T_mz matched_mz = this->ephe_mat_hybrid_p->matched_mz_mat[i][k];
								if (matched_mz > 0){
									mz_mmean_sqr_sum += pow(matched_mz - each_picked_peak_info.mz_mean, 2);
								}
							}
						each_picked_peak_info.mz_sd = sqrt(mz_mmean_sqr_sum / mz_ct); // mz_ct - 1

					} else {
						each_picked_peak_info.mz_mean = -1;
						each_picked_peak_info.mz_sd = -1;
					}

					each_picked_peak_info.area = area;

#ifdef _MSC_VER
					sprintf_s(each_picked_peak_info.picked_peak_id, MAX_LEN_PICKED_PEAK_ID,
						"LH2PcPk%d-%dov%d-%dov%d\0", i,
						ct_peak_range, peak_ranges_each_mz.size(),
						ct_peak_split, split_peak_list.size()
					);
#else
					sprintf(each_picked_peak_info.picked_peak_id,
						"LH2PcPk%d-%dov%d-%dov%d\0", i,
						ct_peak_range, peak_ranges_each_mz.size(),
						ct_peak_split, split_peak_list.size()
					); /// Will '\0' be added at the end of each_picked_peak_info.picked_peak_id?
#endif
					// cout << each_picked_peak_info.picked_peak_id << endl;

					picked_peaks.push_back(each_picked_peak_info);

					/*
					cout << "Found peak ... "
					    << this->ephe_mat_hybrid_p->ref_mzs[i] << ": "
						<< this->ephe_mat_hybrid_p->ref_mts[res_split_peak.start_abs_idx ]
						<< " - "
						<< this->ephe_mat_hybrid_p->ref_mts[res_split_peak.end_abs_idx]
					    << " @ " << res_split_peak.top_abs_idx
						<< endl;
					*/

					ct_peak_split++;

				}

				/*
				cout << this->ephe_mat_hybrid_p->ref_mzs[i] << ": "
						<< this->ephe_mat_hybrid_p->ref_mts[ pkrange.start_idx ]
						<< " - "
						<< this->ephe_mat_hybrid_p->ref_mts[ pkrange.end_idx ]
						<< endl;
						*/

				ct_peak_range++;

			}

		}

		delete[] ephe_zscore_nozeros;
		delete[] ephe_minus_base;

		return picked_peaks;

	}


	template class ROIEPheMatFindPeaks<float, float, double>;
	template class ROIEPheMatFindPeaks<float, float, int>;

}
