//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: xaxpy.h\n\nMATLAB Coder version            : 5.4\nC/C++ source code
// generated on  : 19-Jul-2022 12:31:39
//

#ifndef XAXPY_H
#define XAXPY_H

// Include Files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
namespace internal {
namespace blas {
void xaxpy(int n, double a, int ix0, ::coder::array<double, 2U> &y, int iy0);

void xaxpy(double a, double y[9], int iy0);

} // namespace blas
} // namespace internal
} // namespace coder

#endif
// File trailer for xaxpy.h\n\n[EOF]
