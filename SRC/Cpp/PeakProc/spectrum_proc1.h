/*
 * spectrum_proc1.h
 *
 *  Created on: 2022/08/16
 *      Author: rsaito
 */

#ifndef PEAKPROC_SPECTRUM_PROC1_H_
#define PEAKPROC_SPECTRUM_PROC1_H_

#include "MassSpec/MassSpectrum_simple.h"
#include "Usefuls/closest_value_in_sorted1.h"

using namespace rsMassSpec;

struct found_mz_idx {
	int nearest_idx;
	int peak_top_idx;
};

template <class T_mz, class T_intst>
found_mz_idx find_peak_top_idx_from_spectrum_given_mz(
		MassSpectrum_simple<T_mz, T_intst> &ispectrum, T_mz imz);


#endif /* PEAKPROC_SPECTRUM_PROC1_H_ */
