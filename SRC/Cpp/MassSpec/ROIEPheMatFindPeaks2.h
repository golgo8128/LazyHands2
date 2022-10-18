/*
 * ROIEPheMatFindPeaks2.h
 *
 *  Created on: 2022/08/18
 *      Author: rsaito
 */

#ifndef MASSSPEC_ROIEPHEMATFINDPEAKS2_H_
#define MASSSPEC_ROIEPHEMATFINDPEAKS2_H_

#include "MassSpec/RS_MassSpectra_simple.h"
#include "MassSpec/EPheMatrix1.h"
#include "MassSpec/ROIDetectsimple1.h"

#include "PeakProc/SplitPeak1.h"

#include "Usefuls/rsBinaryDat1.h"

#define MAX_LEN_PICKED_PEAK_ID 100

namespace rsMassSpec {

	template <class T_mtime, class T_mz, class T_intst>
	struct picked_peak_info {

		char picked_peak_id[MAX_LEN_PICKED_PEAK_ID];

		int start_idx;
		int end_idx;
		int top_idx;

		T_mtime start_mt;
		T_mtime end_mt;
		T_mtime top_mt;
		T_mz top_mz;
		T_intst top_intensity;

		double top_zscore;
		T_mz investig_mz;
		double mz_mean;
		double mz_sd;
		double area;
	
	};

	template <class T_mtime, class T_mz, class T_intst>
	void write_picked_pks_infos(
		const char *ofilnam,
		list<picked_peak_info<T_mtime, T_mz, T_intst> > ipicked_peaks_infos);


	template <class T_mtime, class T_mz, class T_intst>
	class ROIEPheMatFindPeaks {
	public:
		ROIEPheMatFindPeaks(RS_MassSpectra_simple<T_mtime, T_mz, T_intst>*, T_mtime,
				double imz_diff_thres,
				T_mtime base_mt_start, T_mtime base_mt_end,
				double smooth_range_mz_cells,
				double smooth_range_mt_cells,
				double zscore_signal_thres,
				double zscore_base_thres,
				int num_mzs_extensions,
				int num_mts_extensions,
				double split_alt_peaktop_thres,
				double split_peak_drop_rate_thres,
				double split_peak_rerise_rate_thres,
				double split_peak_rerise_factor_thres);

		virtual ~ROIEPheMatFindPeaks();

		RS_MassSpectra_simple<T_mtime, T_mz, T_intst>* mspectra_p;
		EPheMatrix1<T_mtime, T_mz, T_intst> *ephe_mat_p;
		EPheMatrix1<T_mtime, T_mz, T_intst> *ephe_mat_hybrid_p;
		ROI_Detect_simple1<T_mtime, T_mz, T_intst>* roi_detect_p;

		RS_MassSpectra_simple<T_mtime, T_mz, T_intst>* roi_spectra_p;
		RS_MassSpectra_simple<T_mtime, T_mz, T_intst>* hybrid_spectra_p;

		void mark_ROIs(
			T_mtime base_mt_start, T_mtime base_mt_end,
			double smooth_range_mz_cells,
			double smooth_range_mt_cells,
			double zscore_signal_thres,
			double zscore_base_thres,
			int num_mzs_extensions,
			int num_mts_extensions);

		void calc_zscore(T_mtime base_mt_start, T_mtime base_mt_end);
		void write_hybrid_zscore_mat(const char*, int);
		void write_hybrid_zscore_mat_txt(const char *);

		list<picked_peak_info<T_mtime, T_mz, T_intst> > pick_peaks();
		list<picked_peak_info<T_mtime, T_mz, T_intst> > picked_peaks_infos;

		void write_picked_peaks_infos(const char *ofilnam);

	private:
		double zscore_signal_thres;
		double zscore_base_thres;
		T_mtime base_mt_start;
		T_mtime base_mt_end;

		double** hybrid_zscore_mat = NULL;
		double *mean_each_mz = NULL;

		sp_threshold splitpeak_thres;

	};

}

#endif /* MASSSPEC_ROIEPHEMATFINDPEAKS2_H_ */
