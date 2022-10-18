#include <iostream>
#include "Tasks/mspectra_ROI1.h"

using namespace std;

template <class T_intst>
void mark_ephemat_roi_surround(
		T_intst *ephemat_intsts[],
		int num_mz, int num_mt,
		char **pre_alloc_marks_mat,
		T_intst signal_thres,
		T_intst ephe_base_thres,
		int num_mzs_extensions,
		int num_mts_extensions){

	for(int i = 0;i < num_mz;i ++){
		// cout << "Checking electropherogram " << i << endl;
		mark_ephe_roi_surround<T_intst>(
			ephemat_intsts[i],
			num_mt,
			pre_alloc_marks_mat[i],
			signal_thres,
			ephe_base_thres,
			num_mts_extensions);
	}
	// cout << "All electropherograms were checked." << endl;

	mark_ephemat_roi_mz_surround<T_intst>(
		ephemat_intsts,
		num_mz, num_mt,
		pre_alloc_marks_mat,
		signal_thres,
		num_mzs_extensions);

}


template <class T_intst>
void mark_ephemat_roi_mz_surround(
	T_intst *ephemat_intsts[],
	int num_mz, int num_mt,
	char **pre_alloc_marks_mat,
	T_intst signal_thres,
	int num_mzs_extensions
	) {

	/* Initialization by 0's
	for(int i = 0;i < num_mz;i ++)
		for(int j = 0;j < num_mt;j ++)
			pre_alloc_marks_mat[i][j] = 0;
	 */

	for(int i = 0;i < num_mz;i ++)
		for(int j = 0;j < num_mt;j ++){
			if(ephemat_intsts[i][j] >= signal_thres){
				for(int mark_i = (i - num_mzs_extensions >= 0) ? i - num_mzs_extensions : 0;
					mark_i <= ((i + num_mzs_extensions < num_mz - 1) ? i + num_mzs_extensions : num_mz - 1);
					mark_i ++){
					pre_alloc_marks_mat[mark_i][j] = 1;
				}
			}
		}

}


template <class T_intst>
void mark_ephe_roi_surround(
	T_intst ephe_intsts[],
	int len,
	char pre_alloc_marks[],
	T_intst signal_thres,
	T_intst ephe_base_thres,
	int num_mts_extensions
	) {

	/* Initialization by zero's
	for(int i = 0;i < len;i ++)
		pre_alloc_marks[i] = 0;
	 */

	for (int signal_check_i = 0;
		 signal_check_i < len;
		 signal_check_i++) {

		// cout << "Checking signal " << signal_check_i << " in electropherogram." << endl;

		if(ephe_intsts[signal_check_i] >= signal_thres){

			pre_alloc_marks[ signal_check_i ] = (char)3;

			int mark_i;

			for(mark_i = signal_check_i - 1;
				mark_i >= 0
					&& ephe_intsts[ mark_i ] > ephe_base_thres
					&& pre_alloc_marks[ mark_i ] == 0;
				mark_i --){
				pre_alloc_marks[ mark_i ] = (char)2;
			}

			if(mark_i >= 0 && pre_alloc_marks[ mark_i ] == 0){
				for(int extensions_ct = 0;
					mark_i >= 0
					  && extensions_ct < num_mts_extensions
					  && pre_alloc_marks[ mark_i ] == 0;
					mark_i --, extensions_ct ++){
					pre_alloc_marks[ mark_i ] = (char)1;
				}
			}

			for(mark_i = signal_check_i + 1;
				mark_i < len
					&& ephe_intsts[ mark_i ] > ephe_base_thres;
				mark_i ++){
				pre_alloc_marks[ mark_i ] = (char)2;
			}

			if(mark_i < len){
				for(int extensions_ct = 0;
					mark_i < len
					  && extensions_ct < num_mts_extensions;
					mark_i ++, extensions_ct ++){
					pre_alloc_marks[ mark_i ] = (char)1;
				}
			}

		}

	}

}


template void mark_ephemat_roi_surround(
		double *[],
		int, int,
		char **,
		double, double,
		int, int);

template void mark_ephemat_roi_mz_surround(
	double *[],
	int, int,
	char **,
	double,
	int);

template void mark_ephe_roi_surround(
	double[],
	int,
	char[],
	double,
	double,
	int);
