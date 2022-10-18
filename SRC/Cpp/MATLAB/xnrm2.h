//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: xnrm2.h\n\nMATLAB Coder version            : 5.4\nC/C++ source code
// generated on  : 19-Jul-2022 12:31:39
//

#ifndef XNRM2_H
#define XNRM2_H

// Include Files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
namespace internal {
namespace blas {
double xnrm2(int n, const ::coder::array<double, 2U> &x, int ix0);

double xnrm2(const double x[3]);

} // namespace blas
} // namespace internal
} // namespace coder

#endif
// File trailer for xnrm2.h\n\n[EOF]
