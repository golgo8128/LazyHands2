/*
 * ROIEPheMatFindPeaks1.cpp
 *
 *  Created on: 2022/07/19
 *      Author: rsaito
 */

#include <list>
#include <iostream>
#include <MassSpec/ROIEPheMatFindPeaks1.h>
#include <Tasks/find_signif_ranges1.h>

using namespace std;

namespace rsMassSpec {

	template <class T_mtime, class T_mz>
	ROI_EPheMat_FindPeaks1<T_mtime, T_mz>::ROI_EPheMat_FindPeaks1(
			double **izmat, double **izmat_smoothed,
			T_mz *imzs, int im_len, T_mtime *imts, int in_len) {

		this->zmat = izmat;
		this->zmat_smoothed = izmat_smoothed;
		this->mzs = imzs;
		this->mts = imts;

		this->m_len = im_len;
		this->n_len = in_len;

	}

	template <class T_mtime, class T_mz>
	void ROI_EPheMat_FindPeaks1<T_mtime, T_mz>::search_write_peak_info(double zscore_thres, double zscore_base){

		for(int i = 0;i < this->m_len;i ++){

			list<each_range_info> range_info_list
				= find_signif_ranges_zscores(
						this->zmat[i], this->zmat_smoothed[i],
						this->n_len, zscore_thres, zscore_base);

			for(each_range_info erange_info: range_info_list){
				cout << this->mzs[i];
				cout << '\t' << this->mts[ erange_info.start_idx ] << '\t' << this->mts[ erange_info.end_idx ];
				cout << '\t' << this->mts[ erange_info.top_idx ] << '\t' << erange_info.top_val;
				cout << '\t' << erange_info.range_val_sum << endl;
			}

		}

	}

	template <class T_mtime, class T_mz>
	ROI_EPheMat_FindPeaks1<T_mtime, T_mz>::~ROI_EPheMat_FindPeaks1() {
		// TODO Auto-generated destructor stub
	}


	template class ROI_EPheMat_FindPeaks1<float, float>;

} /* namespace rsMassSpec */
