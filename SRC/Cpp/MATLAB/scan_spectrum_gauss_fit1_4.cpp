//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: scan_spectrum_gauss_fit1_4.cpp\n\nMATLAB Coder version : 5.4\nC/C++
// source code generated on  : 19-Jul-2022 12:31:39
//

// Include Files
#include "scan_spectrum_gauss_fit1_4.h"
#include "rt_nonfinite.h"
#include "simple_Gaussian_fit_insert_peaktop1_3.h"
#include "coder_array.h"
#include "rt_nonfinite.h"

// Function Definitions
// Arguments    : const coder::array<double, 2U> &imzs\n               const coder::array<double, 2U> &iintsts\n               coder::array<double, 2U> &omzs\n               coder::array<double, 2U> &ointsts\n               double *dat_length\n               double *not_peak_top_flag\nReturn Type  : void
void scan_spectrum_gauss_fit1_4(const coder::array<double, 2U> &imzs,
                                const coder::array<double, 2U> &iintsts,
                                coder::array<double, 2U> &omzs,
                                coder::array<double, 2U> &ointsts,
                                double *dat_length, double *not_peak_top_flag)
{
  coder::array<double, 2U> b_iintsts;
  coder::array<double, 2U> b_imzs;
  coder::array<double, 2U> ointsts_fragm;
  coder::array<double, 2U> omzs_fragm;
  coder::array<double, 1U> a__2;
  coder::array<boolean_T, 2U> x;
  double a__1[3];
  double a__3;
  double a__4;
  double center_x;
  double extrem_y;
  double oi;
  int b_not_peak_top_flag;
  int i;
  int i1;
  int idx;
  unsigned int ii;
  int last_tmp;
  //  imzs   =  [ 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, ...
  //              200, 210, 220, 230, 240, 250, 260, 270, 280, 290] * 100;
  //  iintsts = [   7,   8,   7,   8,  20,  40,  60,  20,   7,   9, ...
  //                7,   8,   7,   8,  20,  60,  60,  20,   7,   9 ];
  //  scatter(omzs, ointsts);
  //
  //  https://jp.mathworks.com/help/coder/gs/generating-c-code-from-matlab-code-at-the-command-line.html
  //  https://jp.mathworks.com/help/coder/ug/cpp-code-generation.html
  //  https://jp.mathworks.com/help/coder/ug/generate-and-modify-an-example-cc-main-function.html
  //  https://jp.mathworks.com/help/coder/ug/structure-of-example-cc-main-function.html
  //  Test with:
  //  codegen scan_spectrum_gauss_fit1_4 -args { coder.typeof(1,[ 1 Inf ]),
  //  coder.typeof(1,[ 1 Inf ]) } -test scan_spectrum_gauss_fit1_4_test1
  //  Generate C++ code with:
  //  codegen scan_spectrum_gauss_fit1_4 -args { coder.typeof(1,[ 1 Inf ]),
  //  coder.typeof(1,[ 1 Inf ]) } -lang:c++ -config:lib -report -package
  //  'scan_spectrum_gauss_fit1_4_Pack1'
  ii = 1U;
  oi = 1.0;
  omzs.set_size(1, imzs.size(1) * 2);
  idx = imzs.size(1) * 2;
  for (i = 0; i < idx; i++) {
    omzs[i] = rtNaN;
  }
  //  Enough size of output array
  ointsts.set_size(1, imzs.size(1) * 2);
  idx = imzs.size(1) * 2;
  for (i = 0; i < idx; i++) {
    ointsts[i] = rtNaN;
  }
  //  Enough size of output array
  b_not_peak_top_flag = 0;
  int exitg1;
  do {
    exitg1 = 0;
    if (ii <= (static_cast<double>(imzs.size(1)) - 4.0) + 1.0) {
      double d;
      boolean_T guard1 = false;
      d = iintsts[static_cast<int>(ii) - 1];
      guard1 = false;
      if ((d < iintsts[static_cast<int>(ii)]) &&
          (iintsts[static_cast<int>(ii) + 1] >
           iintsts[static_cast<int>(ii) + 2])) {
        boolean_T exitg2;
        boolean_T y;
        if (static_cast<int>(ii) > static_cast<int>(ii + 3U)) {
          i = 0;
          i1 = -3;
        } else {
          i = static_cast<int>(ii) - 1;
          i1 = static_cast<int>(ii);
        }
        idx = i1 - i;
        x.set_size(1, idx + 3);
        for (i1 = 0; i1 <= idx + 2; i1++) {
          x[i1] = (iintsts[i + i1] > 0.0);
        }
        y = true;
        idx = 1;
        exitg2 = false;
        while ((!exitg2) && (idx <= x.size(1))) {
          if (!x[idx - 1]) {
            y = false;
            exitg2 = true;
          } else {
            idx++;
          }
        }
        if (y) {
          int k;
          //  No zero's allowed
          if (static_cast<int>(ii) > static_cast<int>(ii + 3U)) {
            i = 0;
            i1 = -3;
            last_tmp = 0;
            k = -3;
          } else {
            i = static_cast<int>(ii) - 1;
            i1 = static_cast<int>(ii);
            last_tmp = static_cast<int>(ii) - 1;
            k = static_cast<int>(ii);
          }
          idx = i1 - i;
          b_imzs.set_size(1, idx + 3);
          for (i1 = 0; i1 <= idx + 2; i1++) {
            b_imzs[i1] = imzs[i + i1];
          }
          idx = k - last_tmp;
          b_iintsts.set_size(1, idx + 3);
          for (i = 0; i <= idx + 2; i++) {
            b_iintsts[i] = iintsts[last_tmp + i];
          }
          simple_Gaussian_fit_insert_peaktop1_3(
              b_imzs, b_iintsts, a__1, &center_x, &extrem_y, omzs_fragm,
              ointsts_fragm, a__2, &a__3, &a__4);
          if (static_cast<int>(ii) > static_cast<int>(ii + 3U)) {
            i = 0;
            i1 = -1;
          } else {
            i = static_cast<int>(ii) - 1;
            i1 = static_cast<int>(ii) + 2;
          }
          last_tmp = (i1 - i) + 1;
          if (last_tmp <= 2) {
            if (last_tmp == 1) {
              a__3 = iintsts[i];
            } else if ((iintsts[i] < iintsts[i1]) ||
                       (rtIsNaN(iintsts[i]) && (!rtIsNaN(iintsts[i1])))) {
              a__3 = iintsts[i1];
            } else {
              a__3 = iintsts[i];
            }
          } else {
            if (!rtIsNaN(iintsts[i])) {
              idx = 1;
            } else {
              idx = 0;
              k = 2;
              exitg2 = false;
              while ((!exitg2) && (k <= last_tmp)) {
                if (!rtIsNaN(iintsts[(i + k) - 1])) {
                  idx = k;
                  exitg2 = true;
                } else {
                  k++;
                }
              }
            }
            if (idx == 0) {
              a__3 = iintsts[i];
            } else {
              a__3 = iintsts[(i + idx) - 1];
              i1 = idx + 1;
              for (k = i1; k <= last_tmp; k++) {
                a__4 = iintsts[(i + k) - 1];
                if (a__3 < a__4) {
                  a__3 = a__4;
                }
              }
            }
          }
          if ((extrem_y >= a__3) && (imzs[static_cast<int>(ii)] < center_x) &&
              (center_x < imzs[static_cast<int>(ii) + 1])) {
            if (oi > (oi + static_cast<double>(omzs_fragm.size(1))) - 1.0) {
              i = 1;
            } else {
              i = static_cast<int>(oi);
            }
            idx = omzs_fragm.size(1);
            for (i1 = 0; i1 < idx; i1++) {
              omzs[(i + i1) - 1] = omzs_fragm[i1];
            }
            if (oi > (oi + static_cast<double>(omzs_fragm.size(1))) - 1.0) {
              i = 1;
            } else {
              i = static_cast<int>(oi);
            }
            idx = ointsts_fragm.size(1);
            for (i1 = 0; i1 < idx; i1++) {
              ointsts[(i + i1) - 1] = ointsts_fragm[i1];
            }
            ii += 4U;
            oi += static_cast<double>(omzs_fragm.size(1));
          } else {
            b_not_peak_top_flag = 1;
            guard1 = true;
          }
        } else {
          guard1 = true;
        }
      } else {
        guard1 = true;
      }
      if (guard1) {
        omzs[static_cast<int>(oi) - 1] = imzs[static_cast<int>(ii) - 1];
        ointsts[static_cast<int>(oi) - 1] = d;
        oi++;
        ii = static_cast<unsigned int>(static_cast<int>(ii) + 1);
      }
    } else {
      exitg1 = 1;
    }
  } while (exitg1 == 0);
  if (ii > static_cast<unsigned int>(imzs.size(1))) {
    i = 0;
    i1 = 0;
  } else {
    i = static_cast<int>(ii) - 1;
    i1 = imzs.size(1);
  }
  if (oi > (oi + static_cast<double>(imzs.size(1))) - static_cast<double>(ii)) {
    last_tmp = 1;
  } else {
    last_tmp = static_cast<int>(oi);
  }
  idx = i1 - i;
  for (i1 = 0; i1 < idx; i1++) {
    omzs[(last_tmp + i1) - 1] = imzs[i + i1];
  }
  if (ii > static_cast<unsigned int>(imzs.size(1))) {
    i = 0;
    i1 = 0;
  } else {
    i = static_cast<int>(ii) - 1;
    i1 = imzs.size(1);
  }
  if (oi > (oi + static_cast<double>(imzs.size(1))) - static_cast<double>(ii)) {
    last_tmp = 1;
  } else {
    last_tmp = static_cast<int>(oi);
  }
  idx = i1 - i;
  for (i1 = 0; i1 < idx; i1++) {
    ointsts[(last_tmp + i1) - 1] = iintsts[i + i1];
  }
  *dat_length =
      (oi + static_cast<double>(imzs.size(1))) - static_cast<double>(ii);
  *not_peak_top_flag = b_not_peak_top_flag;
}

// File trailer for scan_spectrum_gauss_fit1_4.cpp\n\n[EOF]
