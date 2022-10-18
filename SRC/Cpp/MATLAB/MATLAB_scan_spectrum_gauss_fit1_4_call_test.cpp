//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// main.cpp
//
// Code generation for function 'main'
//

/*************************************************************************/
/* This automatically generated example C++ main file shows how to call  */
/* entry-point functions that MATLAB Coder generated. You must customize */
/* this file for your application. Do not modify this file directly.     */
/* Instead, make a copy of this file, modify it, and integrate it into   */
/* your development environment.                                         */
/*                                                                       */
/* This file initializes entry-point function arguments to a default     */
/* size and value before calling the entry-point functions. It does      */
/* not store or use any values returned from the entry-point functions.  */
/* If necessary, it does pre-allocate memory for returned values.        */
/* You can use this file as a starting point for a main function that    */
/* you can deploy in your application.                                   */
/*                                                                       */
/* After you copy the file, and before you deploy it, you must make the  */
/* following changes:                                                    */
/* * For variable-size function arguments, change the example sizes to   */
/* the sizes that your application requires.                             */
/* * Change the example values of function arguments to the values that  */
/* your application requires.                                            */
/* * If the entry-point functions return values, store these values or   */
/* otherwise use them as required by your application.                   */
/*                                                                       */
/*************************************************************************/

// Include files
#include "MATLAB_scan_spectrum_gauss_fit1_4.h"
#include <iostream>

using namespace std;

int main(int, char **)
{

	double test_mzs1_prim[] =
		{ 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
		  21, 22, 23, 24, 25, 26, 27, 28, 29, 30 };
		//   31, 32, 33, 34, 35, 36, 37, 38, 39, 40 };
	double test_intsts1_prim[] =
		{ 15, 10, 15, 15, 10, 10, 20, 10, 10, 10,
		  12, 15, 16, 17, 18, 19, 18, 20, 21, 11 };
		//  12, 15, 16, 17, 18, 19, 18, 20, 21, 11 };

	double *test_mzs1_post_alloc;
	double *test_intsts1_post_alloc;

	int test_res_dat_length = MATLAB_scan_spectrum_gauss_fit1_4(
		  test_mzs1_prim, test_intsts1_prim, sizeof(test_mzs1_prim) / sizeof(test_mzs1_prim[0]),
		  &test_mzs1_post_alloc, &test_intsts1_post_alloc
	);

	cout << "Number of iput  data points : " << sizeof(test_mzs1_prim) / sizeof(test_mzs1_prim[0]) << endl;
	cout << "Number of output data points: " << test_res_dat_length << endl;

	for(int i = 0;i < test_res_dat_length;i ++){
		cout << i << '\t' << test_mzs1_post_alloc[i] << '\t' << test_intsts1_post_alloc[i] << endl;
	}

	MATLAB_scan_spectrum_gauss_fit1_4_terminate();
	delete[] test_mzs1_post_alloc;
	delete[] test_intsts1_post_alloc;

	cout << "See you later." << endl;
	return 0;

}

// End of code generation (main.cpp)
