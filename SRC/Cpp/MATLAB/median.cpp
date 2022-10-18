//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: median.cpp\n\nMATLAB Coder version            : 5.4\nC/C++ source code
// generated on  : 19-Jul-2022 12:31:39
//

// Include Files
#include "median.h"
#include "quickselect.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include "rt_nonfinite.h"

// Function Definitions
// Arguments    : const ::coder::array<double, 1U> &x\nReturn Type  : double
namespace coder {
double median(const ::coder::array<double, 1U> &x)
{
  array<double, 1U> a__4;
  double b;
  double y;
  int a__6;
  int k;
  int vlen;
  vlen = x.size(0);
  if (x.size(0) == 0) {
    y = rtNaN;
  } else {
    k = 0;
    int exitg1;
    do {
      exitg1 = 0;
      if (k <= vlen - 1) {
        if (rtIsNaN(x[k])) {
          y = rtNaN;
          exitg1 = 1;
        } else {
          k++;
        }
      } else {
        if (vlen <= 4) {
          if (vlen == 0) {
            y = rtNaN;
          } else if (vlen == 1) {
            y = x[0];
          } else if (vlen == 2) {
            if (((x[0] < 0.0) != (x[1] < 0.0)) || rtIsInf(x[0])) {
              y = (x[0] + x[1]) / 2.0;
            } else {
              y = x[0] + (x[1] - x[0]) / 2.0;
            }
          } else if (vlen == 3) {
            if (x[0] < x[1]) {
              if (x[1] < x[2]) {
                a__6 = 1;
              } else if (x[0] < x[2]) {
                a__6 = 2;
              } else {
                a__6 = 0;
              }
            } else if (x[0] < x[2]) {
              a__6 = 0;
            } else if (x[1] < x[2]) {
              a__6 = 2;
            } else {
              a__6 = 1;
            }
            y = x[a__6];
          } else {
            if (x[0] < x[1]) {
              if (x[1] < x[2]) {
                k = 0;
                a__6 = 1;
                vlen = 2;
              } else if (x[0] < x[2]) {
                k = 0;
                a__6 = 2;
                vlen = 1;
              } else {
                k = 2;
                a__6 = 0;
                vlen = 1;
              }
            } else if (x[0] < x[2]) {
              k = 1;
              a__6 = 0;
              vlen = 2;
            } else if (x[1] < x[2]) {
              k = 1;
              a__6 = 2;
              vlen = 0;
            } else {
              k = 2;
              a__6 = 1;
              vlen = 0;
            }
            if (x[k] < x[3]) {
              if (x[3] < x[vlen]) {
                if (((x[a__6] < 0.0) != (x[3] < 0.0)) || rtIsInf(x[a__6])) {
                  y = (x[a__6] + x[3]) / 2.0;
                } else {
                  y = x[a__6] + (x[3] - x[a__6]) / 2.0;
                }
              } else if (((x[a__6] < 0.0) != (x[vlen] < 0.0)) ||
                         rtIsInf(x[a__6])) {
                y = (x[a__6] + x[vlen]) / 2.0;
              } else {
                y = x[a__6] + (x[vlen] - x[a__6]) / 2.0;
              }
            } else if (((x[k] < 0.0) != (x[a__6] < 0.0)) || rtIsInf(x[k])) {
              y = (x[k] + x[a__6]) / 2.0;
            } else {
              y = x[k] + (x[a__6] - x[k]) / 2.0;
            }
          }
        } else {
          int midm1;
          midm1 = vlen >> 1;
          if ((vlen & 1) == 0) {
            a__4.set_size(x.size(0));
            k = x.size(0);
            for (a__6 = 0; a__6 < k; a__6++) {
              a__4[a__6] = x[a__6];
            }
            internal::quickselect(a__4, midm1 + 1, vlen, &y, &k, &a__6);
            if (midm1 < k) {
              internal::quickselect(a__4, midm1, a__6 - 1, &b, &k, &vlen);
              if (((y < 0.0) != (b < 0.0)) || rtIsInf(y)) {
                y = (y + b) / 2.0;
              } else {
                y += (b - y) / 2.0;
              }
            }
          } else {
            a__4.set_size(x.size(0));
            k = x.size(0);
            for (a__6 = 0; a__6 < k; a__6++) {
              a__4[a__6] = x[a__6];
            }
            internal::quickselect(a__4, midm1 + 1, vlen, &y, &k, &a__6);
          }
        }
        exitg1 = 1;
      }
    } while (exitg1 == 0);
  }
  return y;
}

} // namespace coder

// File trailer for median.cpp\n\n[EOF]
