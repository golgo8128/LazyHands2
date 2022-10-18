/*
 * spectrum_proc1.cpp
 *
 *  Created on: 2022/08/16
 *      Author: rsaito
 */

#include "spectrum_proc1.h"
#include "Exceptions/rsMHandsExcept1.h"


using namespace rsMassSpec;

template <class T_mz, class T_intst>
found_mz_idx find_peak_top_idx_from_spectrum_given_mz(
		MassSpectrum_simple<T_mz, T_intst> &ispectrum, T_mz imz){
	// Warning: Searching may jump over non-ROI region

	found_mz_idx ret;

	if(ispectrum.num_mzs == 0)
		throw rsMHandsExcept("Spectrum length zero.");

	else if(ispectrum.num_mzs == 1){
		ret.nearest_idx = 0;
		ret.peak_top_idx = 0;
	} else {

		int hit_mz_idx = closest_value_in_sorted_get_idx(
				ispectrum.mzs, ispectrum.num_mzs, imz);

		T_mz hit_mz = ispectrum.mzs[ hit_mz_idx ];
		// T_intst hit_intst = ispectrum.intsts[ hit_mz_idx ];

		int prev_mz_idx;
		int next_mz_idx;

		if(hit_mz < imz){
			prev_mz_idx = hit_mz_idx;
			if (hit_mz_idx == ispectrum.num_mzs - 1)next_mz_idx = ispectrum.num_mzs - 1;
			else next_mz_idx = prev_mz_idx + 1;
		} else {
			next_mz_idx = hit_mz_idx;
			if (hit_mz_idx == 0)prev_mz_idx = 0;
			else prev_mz_idx = next_mz_idx - 1;
		}

	/*
		cout << "Prev m/z idx: " << prev_mz_idx << endl;
		cout << "Hit m/z idx: " << hit_mz_idx << endl;
		cout << "Next m/z idx: " << next_mz_idx << endl;
	*/

		T_intst prev_val = ispectrum.intsts[ prev_mz_idx ];
		T_intst next_val = ispectrum.intsts[ next_mz_idx ];

		int peak_top_mz_idx = hit_mz_idx;
		if(prev_val < next_val)
			for(;
				peak_top_mz_idx < ispectrum.num_mzs - 1 &&
					ispectrum.intsts[ peak_top_mz_idx ] < ispectrum.intsts[ peak_top_mz_idx + 1 ];
				peak_top_mz_idx ++);
		else if (prev_val > next_val)
			for(;
				peak_top_mz_idx > 0 &&
					ispectrum.intsts[ peak_top_mz_idx - 1 ] > ispectrum.intsts[ peak_top_mz_idx ];
				peak_top_mz_idx --);
		// else just leave peak_top_mz_idx as is.

		ret.nearest_idx = hit_mz_idx;
		ret.peak_top_idx = peak_top_mz_idx;

	}

	return ret;

}

template found_mz_idx find_peak_top_idx_from_spectrum_given_mz(MassSpectrum_simple<float, int>&, float);
template found_mz_idx find_peak_top_idx_from_spectrum_given_mz(MassSpectrum_simple<double, int>&, double);
template found_mz_idx find_peak_top_idx_from_spectrum_given_mz(MassSpectrum_simple<float, double>&, float);

