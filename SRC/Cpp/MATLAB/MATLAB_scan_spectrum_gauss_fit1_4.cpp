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
#include "rt_nonfinite.h"
#include "scan_spectrum_gauss_fit1_4.h"
#include "scan_spectrum_gauss_fit1_4_terminate.h"
#include "coder_array.h"

// #include <iostream>
//
// using namespace std;

int MATLAB_scan_spectrum_gauss_fit1_4(
		double imzs_prim[],
		double iintsts1_prim[],
		int initial_data_length,
		double **omzs_post_alloc_p,
		double **ointsts_post_alloc_p
)
{
  coder::array<double, 2U> test_mzs1;
  coder::array<double, 2U> test_intsts1;
  coder::array<double, 2U> ointsts;
  coder::array<double, 2U> omzs;

  double dat_length;
  double not_peak_top_flag;

  test_mzs1.set_size(1, initial_data_length);
  test_intsts1.set_size(1, initial_data_length);

  for(int i = 0;i < initial_data_length;i ++){
	  test_mzs1[i] = imzs_prim[i];
	  test_intsts1[i] = iintsts1_prim[i];
  }

  // Invoke the entry-point functions.
  // You can call entry-point functions multiple times.
  scan_spectrum_gauss_fit1_4(
		  test_mzs1,
		  test_intsts1,
		  omzs, ointsts,
		  &dat_length,
         &not_peak_top_flag);

  *omzs_post_alloc_p    = new double[(int)dat_length];
  *ointsts_post_alloc_p = new double[(int)dat_length];

  for(int i = 0;i < dat_length;i ++){
	  (*omzs_post_alloc_p)[i]    = omzs[i];
	  (*ointsts_post_alloc_p)[i] = ointsts[i];
	  // cout << i << '\t' << omzs[i] << '\t' << ointsts[i] << endl;
  }

  return dat_length;

}

void MATLAB_scan_spectrum_gauss_fit1_4_terminate(){

	// Terminate the application.
	// You do not need to do this more than one time
	// even if you called entry-point functions multiple times.
	scan_spectrum_gauss_fit1_4_terminate();

}

// End of code generation (main.cpp)
