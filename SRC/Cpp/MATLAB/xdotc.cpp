//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: xdotc.cpp\n\nMATLAB Coder version            : 5.4\nC/C++ source code
// generated on  : 19-Jul-2022 12:31:39
//

// Include Files
#include "xdotc.h"
#include "rt_nonfinite.h"

// Function Definitions
// Arguments    : const double x[9]\n               const double y[9]\n               int iy0\nReturn Type  : double
namespace coder {
namespace internal {
namespace blas {
double xdotc(const double x[9], const double y[9], int iy0)
{
  return x[1] * y[iy0 - 1] + x[2] * y[iy0];
}

} // namespace blas
} // namespace internal
} // namespace coder

// File trailer for xdotc.cpp\n\n[EOF]
