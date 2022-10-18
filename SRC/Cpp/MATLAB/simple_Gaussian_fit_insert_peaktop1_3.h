//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: simple_Gaussian_fit_insert_peaktop1_3.h\n\nMATLAB Coder version
// : 5.4\nC/C++ source code generated on  : 19-Jul-2022 12:31:39
//

#ifndef SIMPLE_GAUSSIAN_FIT_INSERT_PEAKTOP1_3_H
#define SIMPLE_GAUSSIAN_FIT_INSERT_PEAKTOP1_3_H

// Include Files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
void simple_Gaussian_fit_insert_peaktop1_3(
    const coder::array<double, 2U> &ix, const coder::array<double, 2U> &iy,
    double coeffz_a[3], double *center_x, double *extrem_y,
    coder::array<double, 2U> &ox, coder::array<double, 2U> &oy,
    coder::array<double, 1U> &iz, double *centr, double *factr);

#endif
// File trailer for simple_Gaussian_fit_insert_peaktop1_3.h\n\n[EOF]
