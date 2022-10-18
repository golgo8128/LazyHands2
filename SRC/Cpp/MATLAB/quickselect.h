//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: quickselect.h\n\nMATLAB Coder version            : 5.4\nC/C++ source
// code generated on  : 19-Jul-2022 12:31:39
//

#ifndef QUICKSELECT_H
#define QUICKSELECT_H

// Include Files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
namespace internal {
void quickselect(::coder::array<double, 1U> &v, int n, int vlen, double *vn,
                 int *nfirst, int *nlast);

}
} // namespace coder

#endif
// File trailer for quickselect.h\n\n[EOF]
