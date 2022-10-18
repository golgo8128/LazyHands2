/*
 * ROIDetectsimple1.h
 *
 *  Created on: 2022/07/05
 *      Author: rsaito
 */

#ifndef ROIDETECTSIMPLE1_H_
#define ROIDETECTSIMPLE1_H_

#include <list>

#include "MassSpec/EPheMatrix1.h"
#include "MassSpec/RS_MassSpectra_simple.h"

#define GAUSSFIT_MIN_DAT_POINTS 4

namespace rsMassSpec {

	template <class T_mtime, class T_mz, class T_intst>
	class ROI_Detect_simple1 {
	public:
		ROI_Detect_simple1(EPheMatrix1<T_mtime, T_mz, T_intst> *);
		virtual ~ROI_Detect_simple1();

		EPheMatrix1<T_mtime, T_mz, T_intst> *ephemat_p;

		void mark_ROIs(T_mtime base_mt_start, T_mtime base_mt_end,
				double smooth_range_mz_cells,
				double smooth_range_mt_cells,
				double zscore_signal_thres,
				double zscore_base_thres,
				int num_mzs_extensions,
				int num_mts_extensions); // Parameter names shown

		void calc_zscore(T_mtime mt_start, T_mtime mt_end);
		RS_MassSpectra_simple<T_mtime, T_mz, T_intst>  *get_mspectra_roi();
		RS_MassSpectra_simple<T_mtime, T_mz, T_intst>  *get_mspectra_roi_gaussfit();

		double **zscore_mat = nullptr;
		double **zscore_smoothed_mat = nullptr;
		char **roi_flag = nullptr;

		void write_roi_flag_mat(const char*);
		void write_zscore_mat(const char*);
		void write_zscore_smoothed_mat(const char*);


	private:
		void get_mspectrum_roi_gaussfit(int, list<T_mz> &, list<T_intst> &);

	};

} /* namespace rsMassSpec */

#endif /* ROIDETECTSIMPLE1_H_ */
