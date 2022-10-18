//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: scan_spectrum_gauss_fit1_4.h\n\nMATLAB Coder version : 5.4\nC/C++
// source code generated on  : 19-Jul-2022 12:31:39
//

#ifndef SCAN_SPECTRUM_GAUSS_FIT1_4_H
#define SCAN_SPECTRUM_GAUSS_FIT1_4_H

// Include Files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
extern void scan_spectrum_gauss_fit1_4(const coder::array<double, 2U> &imzs,
                                       const coder::array<double, 2U> &iintsts,
                                       coder::array<double, 2U> &omzs,
                                       coder::array<double, 2U> &ointsts,
                                       double *dat_length,
                                       double *not_peak_top_flag);

#endif
// File trailer for scan_spectrum_gauss_fit1_4.h\n\n[EOF]
