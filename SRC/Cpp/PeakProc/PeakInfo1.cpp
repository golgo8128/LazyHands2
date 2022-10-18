/*
 * PeakInfo1.cpp
 *
 *  Created on: 2022/08/03
 *      Author: rsaito
 */

#include <iostream>
#include <stdio.h>

#include "PeakProc/PeakInfo1.h"
#include "Usefuls/calc_simple1.h"

using namespace std;

template <class T_val>
PeakInfo<T_val>::PeakInfo(
		T_val *ivals, int istart_abs_idx, int iend_abs_idx, int itop_abs_idx) {

	this->vals = ivals;
	this->start_abs_idx = istart_abs_idx;
	this->end_abs_idx = iend_abs_idx;

	this->top_idx = itop_abs_idx - this->start_abs_idx;
	this->top_abs_idx = itop_abs_idx;

	this->len_peak = this->get_peak_len();
	this->top_val = this->get_top_val();

	this->mark_up_dn();
	this->mark_pk_vl();

	// this->peak_id[0] = '\0';

}

template <class T_val>
PeakInfo<T_val>::PeakInfo(
		T_val *ivals, int istart_abs_idx, int iend_abs_idx) {

	this->vals = ivals;
	this->start_abs_idx = istart_abs_idx;
	this->end_abs_idx = iend_abs_idx;

	this->top_idx = argmax_simple<T_val>(this->vals, this->get_peak_len());
	this->top_abs_idx =  this->top_idx + this->start_abs_idx;

	this->len_peak = this->get_peak_len();
	this->top_val = this->get_top_val();

	this->mark_up_dn();
	this->mark_pk_vl();

	// this->peak_id[0] = '\0';

}

template <class T_val>
void PeakInfo<T_val>::display_info(){

	printf("####### Peak range abs idx: %d - %d (top: %d) #######\n",
			this->start_abs_idx, this->end_abs_idx, this->top_abs_idx);


}


template <class T_val>
void PeakInfo<T_val>::mark_up_dn(){

	this->len_up_idxs = 0;
	this->up_idxs = new int[ this->len_peak - 1]; // Consumes extra memory
	for(int i = 0; i < this->len_peak - 1;i ++)
		if(this->vals[i] < this->vals[i + 1])
			this->up_idxs[ this->len_up_idxs ++ ] = i;

	this->len_dn_idxs = 0;
	this->dn_idxs = new int[ this->len_peak - 1]; // Consumes extra memory
	for(int i = 0; i < this->len_peak - 1;i ++)
		if(this->vals[i] > this->vals[i + 1])
			this->dn_idxs[ this->len_dn_idxs ++ ] = i;

}

template <class T_val>
void PeakInfo<T_val>::mark_pk_vl(){

	this->len_pk_vl_idxs = 0;
	this->pk_vl_poss = new int[ this->len_peak*2 ]; // Consumes extra memory
	this->pk_or_vl   = new int[ this->len_peak*2 ]; // Consumes extra memory

	/* Warning: Peak and valley can theoretically be the same position
	 * as we use >= and <=
	 */
	for(int i = 0; i < this->len_peak;i ++){
		if((i == 0 || this->vals[i-1] <= this->vals[i]) &&
  		   (i == this->len_peak - 1 || this->vals[i] >= this->vals[i+1])){

			this->pk_vl_poss[ this->len_pk_vl_idxs ] = i;
			this->pk_or_vl[ this->len_pk_vl_idxs ] = +1;
			this->len_pk_vl_idxs ++;

		} else if((i == 0 || this->vals[i-1] >= this->vals[i]) &&
		          (i == this->len_peak - 1 || this->vals[i] <= this->vals[i+1])){

			this->pk_vl_poss[ this->len_pk_vl_idxs ] = i;
			this->pk_or_vl[ this->len_pk_vl_idxs ] = -1;
			this->len_pk_vl_idxs ++;

		}

	}

}




template <class T_val>
PeakInfo<T_val>::~PeakInfo() {
	// TODO Auto-generated destructor stub

	if (nullptr != this->up_idxs)delete[] this->up_idxs;
	if (nullptr != this->dn_idxs)delete[] this->dn_idxs;

	if (nullptr != this->pk_vl_poss)delete[] this->pk_vl_poss;
	if (nullptr != this->pk_or_vl)delete[] this->pk_or_vl;

}

/* Copy constructor
 * If you need to overwrite existing instance,
 * consider to use overload operator =
 */
template <class T_val>
PeakInfo<T_val>::PeakInfo(const PeakInfo<T_val> &srcobj){

	this->vals = srcobj.vals;
	this->start_abs_idx = srcobj.start_abs_idx;
	this->end_abs_idx = srcobj.end_abs_idx;

	this->top_idx = srcobj.top_idx;
	this->top_abs_idx = srcobj.top_abs_idx;

	this->len_peak = srcobj.len_peak;
	this->top_val = srcobj.top_val;

	this->mark_up_dn();

	/*
#ifdef _MSC_VER
	strcpy_s(this->peak_id, MAX_PEAK_ID_LEN, srcobj.peak_id);
#else
	strcpy(this->peak_id, srcobj.peak_id);
#endif
	*/
	// cout << "Copy constructor called." << endl;

}


template <class T_val>
int PeakInfo<T_val>::get_peak_len(){

	return this->end_abs_idx - this->start_abs_idx + 1;

}

template <class T_val>
T_val PeakInfo<T_val>::get_top_val(){

	return this->vals[ this->top_idx ];

}


template <class T_val>
PeakInfo<T_val> PeakInfo<T_val>::gen_subpeak(int istart_idx, int iend_idx){

	return PeakInfo<T_val>(
			&(this->vals[ istart_idx ]),
			this->start_abs_idx + istart_idx,
			this->start_abs_idx + iend_idx);

}


template class PeakInfo<double>;

