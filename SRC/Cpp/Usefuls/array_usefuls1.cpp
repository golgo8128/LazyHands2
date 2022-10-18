/*
 * array_usefuls1.cpp
 *
 *  Created on: 2022/07/04
 *      Author: rsaito
 */

template <class T>
T *alloc_eq_intervals(T *iarr_sorted, int len_arr){
// Only the first and last element of iarr_sorted matter

	T *alloc_arr = new T[len_arr];

	for(int i = 0;i < len_arr;i ++)
		alloc_arr[i] = (iarr_sorted[ len_arr - 1 ] - iarr_sorted[ 0 ]) * i / (len_arr - 1) + iarr_sorted[0];

	return alloc_arr;

}

template <class T>
T *alloc_eq_intervals(T boundary_left_lowest, T boundary_left_highest, int num_left_boundaries){
// Only the first and last element of iarr_sorted matter

	T *alloc_arr = new T[num_left_boundaries];

	for(int i = 0;i < num_left_boundaries;i ++)
		alloc_arr[i] =
			(boundary_left_highest - boundary_left_lowest) * i / (num_left_boundaries-1) + boundary_left_lowest;

	return alloc_arr;

}



template float *alloc_eq_intervals<float>(float *, int);
template double *alloc_eq_intervals<double>(double *, int);

template float *alloc_eq_intervals(float, float, int);
template double *alloc_eq_intervals(double, double, int);
