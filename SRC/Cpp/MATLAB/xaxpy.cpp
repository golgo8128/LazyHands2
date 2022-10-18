//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: xaxpy.cpp\n\nMATLAB Coder version            : 5.4\nC/C++ source code
// generated on  : 19-Jul-2022 12:31:39
//

// Include Files
#include "xaxpy.h"
#include "rt_nonfinite.h"
#include "coder_array.h"

// Function Definitions
// Arguments    : int n\n               double a\n               int ix0\n               ::coder::array<double, 2U> &y\n               int iy0\nReturn Type  : void
namespace coder {
namespace internal {
namespace blas {
void xaxpy(int n, double a, int ix0, ::coder::array<double, 2U> &y, int iy0)
{
  if ((n >= 1) && (!(a == 0.0))) {
    int i;
    i = n - 1;
    for (int k = 0; k <= i; k++) {
      int i1;
      i1 = (iy0 + k) - 1;
      y[i1] = y[i1] + a * y[(ix0 + k) - 1];
    }
  }
}

// Arguments    : double a\n               double y[9]\n               int iy0\nReturn Type  : void
void xaxpy(double a, double y[9], int iy0)
{
  if (!(a == 0.0)) {
    y[iy0 - 1] += a * y[1];
    y[iy0] += a * y[2];
  }
}

} // namespace blas
} // namespace internal
} // namespace coder

// File trailer for xaxpy.cpp\n\n[EOF]
