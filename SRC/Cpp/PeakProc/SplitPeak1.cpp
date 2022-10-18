/*
 * SplitPeak1.cpp
 *
 *  Created on: 2022/08/03
 *      Author: rsaito
 */

#include <iostream>
#include <stdio.h>
#include "SplitPeak1.h"

using namespace std;

template <class T_val>
SplitPeak<T_val>::SplitPeak(PeakInfo<T_val> &ipkinfo_origin, sp_threshold isp_thres)
: pkinfo_origin(ipkinfo_origin) { // : pkinfo_origin{ipkinfo_origin} is an initializer.

	// this->pkinfo_origin = ipkinfo_origin; pkinfo_origin may be called as initialization prior to assignment?
	this->sp_thres      = isp_thres;

}

template <class T_val>
SplitPeak<T_val>::~SplitPeak(){

}

template <class T_val>
list<PeakInfo<T_val> > SplitPeak<T_val>::split_peak(PeakInfo<T_val> &pkinfo){

	list<PeakInfo<T_val> > opeak_list;

	// pkinfo.display_info();

	double left_max_drop_rate = 0;
	int left_valley_idx = 0;

	// cout << "##### Left side #####" << endl;
	for(int i = 0;
		i < pkinfo.len_pk_vl_idxs - 1 && pkinfo.pk_vl_poss[i] < pkinfo.top_idx - 1;
		i ++){

		if(pkinfo.pk_or_vl[i] > 0)
			for(int j = i + 1;
				j < pkinfo.len_pk_vl_idxs && pkinfo.pk_vl_poss[j] < pkinfo.top_idx;
				j ++){

				if(pkinfo.pk_or_vl[j] < 0){
					sp_eval eval_res =
						this->eval_alt_peak(pkinfo, pkinfo.pk_vl_poss[i], pkinfo.pk_vl_poss[j]);
					if (this->judge_thres_alt_peak(pkinfo, pkinfo.pk_vl_poss[i], pkinfo.pk_vl_poss[j]) &&
						eval_res.split_peak_drop_rate > left_max_drop_rate){
						left_max_drop_rate = eval_res.split_peak_drop_rate;
						left_valley_idx = pkinfo.pk_vl_poss[j];
						// cout << "Left update!!" << endl;
					}
				}
			}
		}

	double right_max_drop_rate = 0;
	int right_valley_idx = pkinfo.len_peak - 1;

	// cout << "##### Right side #####" << endl;
	for(int i = pkinfo.len_pk_vl_idxs - 1;
		i > 0 && pkinfo.pk_vl_poss[i] > pkinfo.top_idx + 1;
		i --){

		if(pkinfo.pk_or_vl[i] > 0)
			for(int j = i - 1;j >= 0 &&  pkinfo.pk_vl_poss[j] > pkinfo.top_idx;j --){

				if(pkinfo.pk_or_vl[j] < 0){

					sp_eval eval_res =
						this->eval_alt_peak(pkinfo, pkinfo.pk_vl_poss[i], pkinfo.pk_vl_poss[j]);
					if (this->judge_thres_alt_peak(pkinfo, pkinfo.pk_vl_poss[i], pkinfo.pk_vl_poss[j]) &&
						eval_res.split_peak_drop_rate > right_max_drop_rate){
						right_max_drop_rate = eval_res.split_peak_drop_rate;
						right_valley_idx = pkinfo.pk_vl_poss[j];
						// cout << "Right update!!" << endl;
					}
				}
			}
		}

	// cout << "Split decision ... " << left_valley_idx << " ----- " << right_valley_idx << endl << endl;

	if (left_valley_idx > 0){
		PeakInfo<T_val> left_peak = pkinfo.gen_subpeak(0, left_valley_idx);
		list<PeakInfo<T_val> > left_peak_list = this->split_peak(left_peak);
		for(PeakInfo<T_val> cpeak : left_peak_list)opeak_list.push_back(cpeak);
	}

	if (left_valley_idx > 0 || right_valley_idx < pkinfo.len_peak - 1){
		PeakInfo<T_val> middle_peak = pkinfo.gen_subpeak(left_valley_idx, right_valley_idx);
		list<PeakInfo<T_val> > middle_peak_list = this->split_peak(middle_peak);
		for(PeakInfo<T_val> cpeak : middle_peak_list)opeak_list.push_back(cpeak);
		// cout << "Split!" << endl;
	}

	if (right_valley_idx < pkinfo.len_peak - 1){
		PeakInfo<T_val> right_peak = pkinfo.gen_subpeak(right_valley_idx, pkinfo.len_peak - 1);
		list<PeakInfo<T_val> > right_peak_list = this->split_peak(right_peak);
		for(PeakInfo<T_val> cpeak : right_peak_list)opeak_list.push_back(cpeak);
	}

	if (left_valley_idx == 0 && right_valley_idx == pkinfo.len_peak - 1){
		opeak_list.push_back(pkinfo);
	}

	return (opeak_list);

}


template <class T_val>
sp_eval SplitPeak<T_val>::eval_alt_peak(
		PeakInfo<T_val> &pkinfo, int alt_peak_idx, int valley_idx){

	sp_eval oeval;

	T_val peak_top_val = pkinfo.vals[ pkinfo.top_idx ];
	T_val peak_alt_val = pkinfo.vals[ alt_peak_idx ];
	T_val valley_val   = pkinfo.vals[ valley_idx ];

	oeval.split_peak_drop_rate     = (peak_alt_val - valley_val) / peak_alt_val;
	oeval.split_peak_rerise_rate   = (peak_alt_val - valley_val) / (peak_top_val - valley_val);
	oeval.split_peak_rerise_factor = peak_alt_val / valley_val;

	return oeval;

}

template <class T_val>
int SplitPeak<T_val>::judge_thres_alt_peak(
		PeakInfo<T_val> &pkinfo, int alt_peak_idx, int valley_idx){

	sp_eval eval_res = this->eval_alt_peak(pkinfo, alt_peak_idx, valley_idx);

	// T_val peak_top_val = pkinfo.vals[ pkinfo.top_idx ];
	T_val peak_alt_val = pkinfo.vals[ alt_peak_idx ]; // Required variable
	T_val valley_val   = pkinfo.vals[ valley_idx ];

	int ret_flag = 0;

	if (peak_alt_val >= this->sp_thres.split_alt_peaktop_thres &&
		eval_res.split_peak_drop_rate >= this->sp_thres.split_peak_drop_rate_thres &&
		eval_res.split_peak_rerise_rate >= this->sp_thres.split_peak_rerise_rate_thres &&
		eval_res.split_peak_rerise_factor >= this->sp_thres.split_peak_rerise_factor_thres){

		ret_flag = 1;

	} else {

		ret_flag = 0;

	}

	/*

	printf("Alt peak idx: %d (val: %lf) Valley idx: %d (val: %lf)\n",
			alt_peak_idx, peak_alt_val, valley_idx, valley_val);
	cout << "Drop rate: " << eval_res.split_peak_drop_rate << endl;
	cout << "Rerise rate: " << eval_res.split_peak_rerise_rate << endl;
	cout << "Rerise factor: " << eval_res.split_peak_rerise_factor << endl;
	 */

	return ret_flag;

}


template class SplitPeak<double>;
