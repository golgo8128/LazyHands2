/*
 * SplitPeak1.h
 *
 *  Created on: 2022/08/03
 *      Author: rsaito
 */

#ifndef PEAKPROC_SPLITPEAK1_H_
#define PEAKPROC_SPLITPEAK1_H_

#include "PeakInfo1.h"
#include <list>

using namespace std;

struct sp_eval {

	double split_peak_drop_rate;
	double split_peak_rerise_rate;
	double split_peak_rerise_factor;
	int split_peak_topupdate_ct;

};

struct sp_threshold {

	double split_alt_peaktop_thres;
	// double signal_thres;
	double split_peak_drop_rate_thres;
	double split_peak_rerise_rate_thres;
	double split_peak_rerise_factor_thres;
	int split_peak_topupdate_ct_thres;

};

template <class T_val>
class SplitPeak {
public:
	SplitPeak(PeakInfo<T_val> &ipkinfo_origin, sp_threshold isp_thres);
	virtual ~SplitPeak();

	PeakInfo<T_val> pkinfo_origin;
	// Warning: Avoid pkinfo_origin() being called. https://www.gocca.work/cpp-initialize-list
	sp_threshold sp_thres;

	list<PeakInfo<T_val> > split_peak(PeakInfo<T_val> &pkinfo);

	sp_eval eval_alt_peak(PeakInfo<T_val> &pkinfo, int alt_peak_idx, int valley_idx);
	int judge_thres_alt_peak(PeakInfo<T_val> &pkinfo, int alt_peak_idx, int valley_idx);

};

#endif /* PEAKPROC_SPLITPEAK1_H_ */
