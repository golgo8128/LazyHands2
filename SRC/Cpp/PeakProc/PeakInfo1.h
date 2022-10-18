/*
 * PeakInfo1.h
 *
 *  Created on: 2022/08/03
 *      Author: rsaito
 */

#ifndef PEAKPROC_PEAKINFO1_H_
#define PEAKPROC_PEAKINFO1_H_

#include <iostream>

// #define MAX_PEAK_ID_LEN 100


template <class T_val>
class PeakInfo {
public:
	PeakInfo(T_val *ivals, int istart_abs_idx, int iend_abs_idx, int itop_abs_idx);
	PeakInfo(T_val *ivals, int istart_abs_idx, int iend_abs_idx);


	PeakInfo(const PeakInfo &srcobj);
	/* Copy constructor
	 * If you need to overwrite existing instance,
	 * consider to use overload operator =
	 */


	virtual ~PeakInfo();

	int get_peak_len();
	T_val get_top_val();

	// char peak_id[MAX_PEAK_ID_LEN];

	T_val *vals;
	int start_abs_idx;
	int end_abs_idx;
	int top_abs_idx;

	int top_idx;
	T_val top_val;
	int len_peak;

	int *up_idxs = nullptr;
	int len_up_idxs;
	int *dn_idxs = nullptr;
	int len_dn_idxs;

	int *pk_vl_poss = nullptr;
	int *pk_or_vl = nullptr;
	int len_pk_vl_idxs;


	PeakInfo gen_subpeak(int istart_idx, int iend_idx);

	void display_info();


private:
	void mark_up_dn();
	void mark_pk_vl();

};

#endif /* PEAKPROC_PEAKINFO1_H_ */
