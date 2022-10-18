//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: div.cpp\n\nMATLAB Coder version            : 5.4\nC/C++ source code
// generated on  : 19-Jul-2022 12:31:39
//

// Include Files
#include "div.h"
#include "rt_nonfinite.h"
#include "coder_array.h"

// Function Definitions
// Arguments    : double in1_data[]\n               int *in1_size\n               const coder::array<double, 1U> &in2\n               int in3\n               const double in4_data[]\n               const int *in4_size\nReturn Type  : void
void binary_expand_op(double in1_data[], int *in1_size,
                      const coder::array<double, 1U> &in2, int in3,
                      const double in4_data[], const int *in4_size)
{
  int loop_ub;
  int stride_0_0;
  int stride_1_0;
  if (*in4_size == 1) {
    *in1_size = in3 + 1;
  } else {
    *in1_size = *in4_size;
  }
  stride_0_0 = (in3 + 1 != 1);
  stride_1_0 = (*in4_size != 1);
  if (*in4_size == 1) {
    loop_ub = in3 + 1;
  } else {
    loop_ub = *in4_size;
  }
  for (int i = 0; i < loop_ub; i++) {
    in1_data[i] = in2[i * stride_0_0] / in4_data[i * stride_1_0];
  }
}

// File trailer for div.cpp\n\n[EOF]
