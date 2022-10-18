/*
 * calc_simple1.cpp
 *
 *  Created on: 2022/07/05
 *      Author: rsaito
 */

#include <math.h>
#include "Exceptions/rsMHandsExcept1.h"

template <class Tin, class Tout>
Tout sum_simple(Tin *iarr, int len_arr){

	Tout osum = 0;
	for(int i = 0;i < len_arr;i ++)
		osum += iarr[i];

	return osum;

}

template <class T>
double mean_simple(T *iarr, int len_arr){

	return sum_simple<T, double>(iarr, len_arr) / len_arr;

}

template <class T>
double var_estim_simple(T *iarr, int len_arr){

	double diffsqsum = 0;
	double mean_arr = mean_simple(iarr, len_arr);
	for (int i = 0; i < len_arr; i++) {
		// T diff_from_mean = iarr[i] - mean_arr;
		// T diffsq_from_mean = diff_from_mean * diff_from_mean;
		// diffsqsum += diffsq_from_mean;

		diffsqsum += ((double)iarr[i] - mean_arr) * ((double)iarr[i] - mean_arr);
	}

	return diffsqsum / (len_arr - 1);

}

template <class T>
double sd_estim_simple(T *iarr, int len_arr){

	return sqrt(var_estim_simple(iarr, len_arr));

}

template <class T>
void zscores_simple(T *iarr, int len_arr, double calc_zscore_res[]){
// Memory for calc_zscore_res should be pre-allocated.

	double mean_arr = mean_simple(iarr, len_arr);
	double sd_arr   = sd_estim_simple(iarr, len_arr);

	for(int i = 0;i < len_arr;i ++)
		calc_zscore_res[i] = (iarr[i] - mean_arr) / sd_arr;

}


template <class T>
int argmax_simple(T iarr[], int len_arr){

	if (len_arr <= 0)
		throw rsMHandsExcept("In argmax_simple function - array empty.");

	T max_elem = iarr[0];
	int max_idx = 0;
	for(int i = 1;i < len_arr;i ++)
		if(iarr[i] > max_elem){
			max_elem = iarr[i];
			max_idx = i;
		}

	return max_idx;

}

double div0_x_eq_0(double numerator, double denominator) {

	if (numerator == 0.0) {
		return 0.0; // defined even if denominator == 0.0
	}
	else {
		return numerator / denominator;
	}


}


template int sum_simple(int *, int);
template float sum_simple(float *, int);
template double sum_simple(double *, int);
template int sum_simple(float *, int);

template double mean_simple(int *, int);
template double mean_simple(float *, int);
template double mean_simple(double *, int);

template double var_estim_simple(float *, int);
template double var_estim_simple(double *, int);

template double sd_estim_simple(float *, int);
template double sd_estim_simple(double *, int);
template double sd_estim_simple(int *, int);

template void zscores_simple(float *iarr, int len_arr, double calc_zscore_res[]);
template void zscores_simple(double *iarr, int len_arr, double calc_zscore_res[]);

template int argmax_simple(double[], int);
