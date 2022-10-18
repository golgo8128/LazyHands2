//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: svd.h\n\nMATLAB Coder version            : 5.4\nC/C++ source code
// generated on  : 19-Jul-2022 12:31:39
//

#ifndef SVD_H
#define SVD_H

// Include Files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
namespace internal {
void svd(const ::coder::array<double, 2U> &A, ::coder::array<double, 2U> &U,
         double s_data[], int *s_size, double V[9]);

}
} // namespace coder

#endif
// File trailer for svd.h\n\n[EOF]
