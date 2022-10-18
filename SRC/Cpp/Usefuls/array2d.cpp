
#include <algorithm>
#include <iostream>
#include <fstream>
#include <math.h>

#include <stdio.h>

#include "array2d.h"
#include "Usefuls/calc_simple1.h"
#include "Usefuls/closest_value_in_sorted1.h"

using namespace std;

template <class T>
T **init_array2d(int len_m, int len_n, T iinit_val) {
	
	T** array2d_rowstarts_p = new T * [len_m];
	T* array2d_main_p = new T[len_m * len_n];
	fill_n(array2d_main_p, len_m * len_n, iinit_val);

	for (int i = 0; i < len_m; i++) {
		array2d_rowstarts_p[i] = &array2d_main_p[len_n * i];
	}

	return array2d_rowstarts_p;

	/*
		T** array2d = new T * [len_m];
		for (int i = 0; i < len_m; i++) {
			array2d[i] = new T[len_n];
			fill_n(array2d[i], len_n, iinit_val);
		}

		return array2d;
	*/

}

template <class T>
void del_array2d(T *array2d[], int len_m, int len_n) {

	delete[] & array2d[0][0];
	delete[] array2d;


	/*
		for (int i = 0; i < len_m; i++)
			delete[] array2d[i];
		delete[] array2d;
	*/
}


template <class T_val>
void display_array2d(T_val *array2d[], int len_m, int len_n) {

	for(int i = 0;i < len_m;i ++){
		for(int j = 0;j < len_n;j ++){
			if(sizeof(T_val) == 1)
				cout << (int)array2d[ i ][ j ];
			else
				cout << array2d[ i ][ j ];
			if(j < len_n - 1)cout << '\t';
			else cout << endl;
		}
	}
}


template <class T_val, class T_label_m, class T_label_n>
void display_array2d(T_val *array2d[], int len_m, int len_n,
		T_label_m label_m[], T_label_n label_n[]) {

	for(int j = 0;j < len_n;j ++)
		cout << "\t" << label_n[j];
	cout << '\n';
	for(int i = 0;i < len_m;i ++){
		cout << label_m[i];
		for(int j = 0;j < len_n;j ++)
			if(sizeof(T_val) == 1)
				cout << "\t" << (int)array2d[ i ][ j ];
			else
				cout << "\t" << array2d[ i ][ j ];
		cout << endl;
	}

}


template <class T_val>
void write_array2d(
	const char *ofilnam,
	T_val* array2d[], int len_m, int len_n) {

	ofstream fcout;
	fcout.open(ofilnam);

	for (int i = 0; i < len_m; i++) {
		for (int j = 0; j < len_n; j++) {
			if (sizeof(T_val) == 1)
				fcout << (int)array2d[i][j];
			else
				fcout << array2d[i][j];
			if (j < len_n - 1)fcout << '\t';
			else fcout << endl;
		}
	}
}


template <class T_val, class T_label_m, class T_label_n>
void write_array2d(
	const char *ofilnam,
	T_val* array2d[], int len_m, int len_n,
	T_label_m label_m[], T_label_n label_n[]) {

	ofstream fcout;
	fcout.open(ofilnam);

	for (int j = 0; j < len_n; j++)
		fcout << "\t" << label_n[j];
	fcout << '\n';
	for (int i = 0; i < len_m; i++) {
		fcout << label_m[i];
		for (int j = 0; j < len_n; j++)
			if (sizeof(T_val) == 1)
				fcout << "\t" << (int)array2d[i][j];
			else
				fcout << "\t" << array2d[i][j];
		fcout << endl;
	}

}

template <class T_val, class T_label_m, class T_label_n>
rsarray2d<T_val, double, double> conv_to_eq_intervals_2d(
	T_val* iarray2d[], int len_m, int len_n,
	T_label_m label_m[], T_label_n label_n[]) {

	T_val **oarray2d = init_array2d<T_val>(len_m, len_n, 0);
	double *olabel_m_postalloc = new double[ len_m ];
	double *olabel_n_postalloc = new double[ len_n ];
	// double m_eq_segmlen = (label_m[ len_m - 1 ] - label_m[ 0 ]) / len_m;
	// double n_eq_segmlen = (label_n[ len_n - 1 ] - label_n[ 0 ]) / len_n;

	// closest_limit_value_in_sorted_get_idx function may not work as expected
	// due to limited precision in floating point calculation.

	for(int i = 0;i < len_m;i ++){
		olabel_m_postalloc[i] = i * (label_m[ len_m - 1 ] - label_m[ 0 ]) / (len_m-1) + label_m[ 0 ];
		int closest_idx_i =
				closest_value_in_sorted_get_idx<T_label_m>(label_m, len_m, olabel_m_postalloc[i]);
		for(int j = 0;j < len_n;j ++){
			olabel_n_postalloc[j] = j * (label_n[ len_n - 1 ] - label_n[ 0 ]) / (len_n-1) + label_n[ 0 ];
			int closest_idx_j =
					closest_value_in_sorted_get_idx<T_label_n>(label_n, len_n, olabel_n_postalloc[j]);
			oarray2d[i][j] = iarray2d[closest_idx_i][closest_idx_j];

			/*
			printf("Output (%lf[%d], %lf[%d]) = %lf <-- (%lf[%d], %lf[%d])\n",
					olabel_m_postalloc[i], i,
					olabel_n_postalloc[j], j,
					(double)(oarray2d[i][j]),
					label_m[closest_idx_i], closest_idx_i,
					label_n[closest_idx_j], closest_idx_j);
			 */
		}

	}

	rsarray2d<T_val, double, double> oarray_info;
	oarray_info.array2d = oarray2d;
	oarray_info.len_m = len_m;
	oarray_info.len_n = len_n;
	oarray_info.labels_m = olabel_m_postalloc;
	oarray_info.labels_n = olabel_n_postalloc;

	return oarray_info;

}





template <class T>
void smooth_triang_simple(
		T *array2d[],
		int len_m, int len_n,
		double irange_m, double irange_n,
		double *pre_alloc_array2d[]) {

	double (*d0)(double, double) = div0_x_eq_0;
	

	for(int i = 0;i < len_m;i ++)
		for(int j = 0;j < len_n;j ++){
			int ct = 0;
			double csum = 0;
			for(int i2 = i; i2-i <= irange_m && i2 < len_m;i2 ++){

				for(int j2 = j;
					(j2-j)*(j2-j) <= irange_n * irange_n * (1-(*d0)((i2-i)*(i2-i), (irange_m*irange_m)))
						&& j2 < len_n;
					 j2 ++){
					csum += array2d[i2][j2];
					ct ++;
					/*
						if (i == 2 && j == 3){
							cout << i2 << ", " << j2 << "," << endl;

						}
					*/
				}
			}

			pre_alloc_array2d[i][j] = csum / ct;

		}

	/*
	 *
			for(int i2 = i;i2-i <= irange && i2 < len_m;i2 ++)
				for(int j2 = j; (j2 - j) + (i2 - i) <= irange && j2 < len_n;j2 ++){

					csum += array2d[i2][j2];
					ct ++;

				}
	 */

}


template char **init_array2d(int, int, char);
template int **init_array2d(int, int, int);
template float **init_array2d(int, int, float);
template double **init_array2d(int, int, double);
template void del_array2d(char *[], int, int);
template void del_array2d(int *[], int, int);
template void del_array2d(float *[], int, int);
template void del_array2d(double *[], int, int);

template void display_array2d(int *[], int, int, double[], float[]);
template void display_array2d(double *[], int, int, double[], float[]);
template void display_array2d(int *[], int, int, float[], float[]);
template void display_array2d(float *[], int, int, float[], float[]);

template void display_array2d(int* [], int, int, string[], string[]);
template void display_array2d(double* [], int, int, string[], string[]);
template void display_array2d(double** const, int, int, float* const, float* const);
template void display_array2d(char** const, int, int, float* const, float* const);

template void display_array2d(double*[], int, int);
template void display_array2d(int*[], int, int);
template void display_array2d(char*[], int, int);

template void write_array2d(const char*, double*[], int, int);
template void write_array2d(const char*, double*[], int, int, float[], float[]);
template void write_array2d(const char*, int*[], int, int, float[], float[]);
template void write_array2d(const char*, float* [], int, int, float[], float[]);
template void write_array2d(const char*, int*[], int, int, double[], float[]);
template void write_array2d(const char*, double* [], int, int, double[], float[]);
template void write_array2d(const char*, char*[], int, int, float[], float[]);
template void write_array2d(const char*, double* [], int, int, double[], double[]);

template rsarray2d<double, double, double> conv_to_eq_intervals_2d(double** const, int, int, float* const, float* const);
template rsarray2d<char, double, double> conv_to_eq_intervals_2d<char, float, float>(char** const, int, int, float* const, float* const);

template void smooth_triang_simple(double *[], int, int, double, double, double*[]);

