//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: simple_Gaussian_fit_insert_peaktop1_3.cpp\n\nMATLAB Coder version
// : 5.4\nC/C++ source code generated on  : 19-Jul-2022 12:31:39
//

// Include Files
#include "simple_Gaussian_fit_insert_peaktop1_3.h"
#include "div.h"
#include "median.h"
#include "rt_nonfinite.h"
#include "svd.h"
#include "coder_array.h"
#include "rt_nonfinite.h"
#include <algorithm>
#include <cmath>

// Function Definitions
//
// , varargin)
// \nArguments    : const coder::array<double, 2U> &ix\n               const
// coder::array<double, 2U> &iy\n               double coeffz_a[3]\n double
// *center_x\n               double *extrem_y\n coder::array<double, 2U> &ox\n
// coder::array<double, 2U> &oy\n               coder::array<double, 1U> &iz\n
// double *centr\n               double *factr\nReturn Type  : void
//
void simple_Gaussian_fit_insert_peaktop1_3(
    const coder::array<double, 2U> &ix, const coder::array<double, 2U> &iy,
    double coeffz_a[3], double *center_x, double *extrem_y,
    coder::array<double, 2U> &ox, coder::array<double, 2U> &oy,
    coder::array<double, 1U> &iz, double *centr, double *factr)
{
  coder::array<double, 2U> S;
  coder::array<double, 2U> U1;
  coder::array<double, 2U> oy_cell_f1;
  coder::array<double, 2U> x;
  coder::array<double, 1U> b_ix;
  coder::array<double, 1U> d;
  coder::array<double, 1U> ln_y;
  coder::array<double, 1U> r;
  double V1[9];
  double s_data[3];
  double z_pre_data[3];
  double b_ex;
  double ex;
  double idx_l;
  int i;
  int idx;
  int k;
  int last;
  int s_size;
  boolean_T almost_zero_bool_data[3];
  boolean_T exitg1;
  boolean_T p;
  last = ix.size(1);
  if (ix.size(1) <= 2) {
    if (ix.size(1) == 1) {
      ex = ix[0];
    } else if ((ix[0] < ix[ix.size(1) - 1]) ||
               (rtIsNaN(ix[0]) && (!rtIsNaN(ix[ix.size(1) - 1])))) {
      ex = ix[ix.size(1) - 1];
    } else {
      ex = ix[0];
    }
  } else {
    if (!rtIsNaN(ix[0])) {
      idx = 1;
    } else {
      idx = 0;
      k = 2;
      exitg1 = false;
      while ((!exitg1) && (k <= last)) {
        if (!rtIsNaN(ix[k - 1])) {
          idx = k;
          exitg1 = true;
        } else {
          k++;
        }
      }
    }
    if (idx == 0) {
      ex = ix[0];
    } else {
      ex = ix[idx - 1];
      i = idx + 1;
      for (k = i; k <= last; k++) {
        idx_l = ix[k - 1];
        if (ex < idx_l) {
          ex = idx_l;
        }
      }
    }
  }
  last = ix.size(1);
  if (ix.size(1) <= 2) {
    if (ix.size(1) == 1) {
      b_ex = ix[0];
    } else if ((ix[0] > ix[ix.size(1) - 1]) ||
               (rtIsNaN(ix[0]) && (!rtIsNaN(ix[ix.size(1) - 1])))) {
      b_ex = ix[ix.size(1) - 1];
    } else {
      b_ex = ix[0];
    }
  } else {
    if (!rtIsNaN(ix[0])) {
      idx = 1;
    } else {
      idx = 0;
      k = 2;
      exitg1 = false;
      while ((!exitg1) && (k <= last)) {
        if (!rtIsNaN(ix[k - 1])) {
          idx = k;
          exitg1 = true;
        } else {
          k++;
        }
      }
    }
    if (idx == 0) {
      b_ex = ix[0];
    } else {
      b_ex = ix[idx - 1];
      i = idx + 1;
      for (k = i; k <= last; k++) {
        idx_l = ix[k - 1];
        if (b_ex > idx_l) {
          b_ex = idx_l;
        }
      }
    }
  }
  *factr = ex - b_ex;
  idx = ix.size(1);
  b_ix = ix.reshape(idx);
  *centr = coder::median(b_ix);
  iz.set_size(ix.size(1));
  last = ix.size(1);
  for (i = 0; i < last; i++) {
    iz[i] = (ix[i] - *centr) / *factr;
  }
  //  iarr = scaled * factr + centr
  //  iy = transpose([ 4, 9, 12, 5 ]);
  //  ix = transpose([ 0.5, 1, 5.5, 6 ]);
  ln_y.set_size(iy.size(1));
  last = iy.size(1);
  for (i = 0; i < last; i++) {
    ln_y[i] = iy[i];
  }
  idx = iy.size(1);
  for (k = 0; k < idx; k++) {
    ln_y[k] = std::log(ln_y[k]);
  }
  d.set_size(iz.size(0));
  if (iz.size(0) != 0) {
    idx = iz.size(0);
    for (k = 0; k < idx; k++) {
      d[k] = 1.0;
    }
  }
  r.set_size(iz.size(0));
  last = iz.size(0);
  for (i = 0; i < last; i++) {
    ex = iz[i];
    r[i] = ex * ex;
  }
  x.set_size(r.size(0), 3);
  last = r.size(0);
  for (i = 0; i < last; i++) {
    x[i] = r[i];
  }
  last = iz.size(0);
  for (i = 0; i < last; i++) {
    x[i + x.size(0)] = iz[i];
  }
  last = d.size(0);
  for (i = 0; i < last; i++) {
    x[i + x.size(0) * 2] = 1.0;
  }
  //  disp('LLS_SVD_simple1_1');
  //  Solving linear least squares problem with singular value decomposition
  //  https://www2.math.uconn.edu/~leykekhman/courses/MATH3795/Lectures/Lecture_9_Linear_least_squares_SVD.pdf
  //  http://www.misojiro.t.u-tokyo.ac.jp/~murota/lect-kisosuri/singularvalue050129.pdf
  //  https://www2.math.ethz.ch/education/bachelor/lectures/hs2014/other/linalg_INFK/svdneu.pdf
  //  compute the SVD:
  idx = x.size(0) * 3;
  p = true;
  for (k = 0; k < idx; k++) {
    if ((!p) || (rtIsInf(x[k]) || rtIsNaN(x[k]))) {
      p = false;
    }
  }
  if (p) {
    coder::internal::svd(x, U1, s_data, &s_size, V1);
  } else {
    S.set_size(x.size(0), 3);
    last = x.size(0) * 3;
    for (i = 0; i < last; i++) {
      S[i] = 0.0;
    }
    coder::internal::svd(S, U1, s_data, &s_size, V1);
    idx = U1.size(0);
    last = U1.size(1);
    U1.set_size(idx, last);
    last *= idx;
    for (i = 0; i < last; i++) {
      U1[i] = rtNaN;
    }
    for (i = 0; i < s_size; i++) {
      s_data[i] = rtNaN;
    }
    for (i = 0; i < 9; i++) {
      V1[i] = rtNaN;
    }
  }
  S.set_size(U1.size(1), 3);
  last = U1.size(1) * 3;
  for (i = 0; i < last; i++) {
    S[i] = 0.0;
  }
  i = s_size - 1;
  for (k = 0; k <= i; k++) {
    S[k + S.size(0) * k] = s_data[k];
  }
  s_size = S.size(0);
  if (s_size > 3) {
    s_size = 3;
  }
  i = s_size - 1;
  for (k = 0; k <= i; k++) {
    s_data[k] = S[k + S.size(0) * k];
  }
  idx = U1.size(1) - 1;
  last = U1.size(0);
  d.set_size(U1.size(1));
  for (i = 0; i <= idx; i++) {
    d[i] = 0.0;
  }
  for (k = 0; k < last; k++) {
    for (i = 0; i <= idx; i++) {
      d[i] = d[i] + U1[i * U1.size(0) + k] * ln_y[k];
    }
  }
  if (s_size < 1) {
    last = 0;
  } else {
    last = s_size;
  }
  if (last == s_size) {
    idx = last;
    for (i = 0; i < last; i++) {
      z_pre_data[i] = d[i] / s_data[i];
    }
  } else {
    binary_expand_op(z_pre_data, &idx, d, last - 1, s_data, &s_size);
  }
  ex = static_cast<double>(x.size(0)) * 2.2204460492503131E-16 * s_data[0];
  b_ex = 6.6613381477509392E-16 * s_data[0];
  if ((ex < b_ex) || (rtIsNaN(ex) && (!rtIsNaN(b_ex)))) {
    ex = b_ex;
  }
  for (i = 0; i < s_size; i++) {
    almost_zero_bool_data[i] = (s_data[i] < ex);
  }
  almost_zero_bool_data[0] = false;
  for (i = 0; i < s_size; i++) {
    if (almost_zero_bool_data[i]) {
      z_pre_data[i] = 0.0;
    }
  }
  s_data[0] = 0.0;
  s_data[1] = 0.0;
  s_data[2] = 0.0;
  if (idx < 1) {
    last = 0;
  } else {
    last = idx;
  }
  if (last - 1 >= 0) {
    std::copy(&z_pre_data[0], &z_pre_data[last], &s_data[0]);
  }
  idx_l = s_data[0];
  ex = s_data[1];
  b_ex = s_data[2];
  for (i = 0; i < 3; i++) {
    coeffz_a[i] = (V1[i] * idx_l + V1[i + 3] * ex) + V1[i + 6] * b_ex;
  }
  *extrem_y =
      std::exp(coeffz_a[2] - 0.25 * (coeffz_a[1] * coeffz_a[1]) / coeffz_a[0]);
  //  fitted_x = -1:0.1:8;
  //  fitted_y = exp(a(1)*fitted_x.^2 + a(2)*fitted_x + a(3));
  //  cfit_gauss = fit(ix, iy, 'gauss1');
  //  cfit_gauss_y = cfit_gauss(fitted_x);
  //
  //  plot(fitted_x, fitted_y);
  //  hold on;
  //  plot(fitted_x, cfit_gauss_y);
  //  hold on;
  //  scatter(ix, iy);
  //  hold off;
  //  tmpf = @()lsqr(x, ln_y)
  //  timeit(tmpf)
  //  tmpf_gaussian = @()fit(ix, iy,'gauss1')
  //  timeit(tmpf_gaussian)
  *center_x = -0.5 * coeffz_a[1] / coeffz_a[0] * *factr + *centr;
  //  closest_ix, closest_idx
  //  Returns value and index of arr that is closest to val. If several entries
  //  are equally close, return the first. Works fine up to machine error (e.g.
  //  [v, i] = closest_value([4.8, 5], 4.9) will return [5, 2], since in float
  //  representation 4.9 is strictly closer to 5 than 4.8).
  //  ===============
  //  Parameter list:
  //  ===============
  //  arr : increasingly ordered array (shoud NOT contain any NaN)
  //  val : scalar in R
  //  https://jp.mathworks.com/matlabcentral/fileexchange/37915-binary-search-for-closest-value-in-an-array
  if (rtIsNaN(*center_x)) {
    b_ex = rtNaN;
    ex = rtNaN;
  } else {
    last = ix.size(1);
    //  Binary search for index
    ex = 1.0;
    int exitg2;
    do {
      exitg2 = 0;
      i = last - static_cast<int>(ex);
      if (i > 1) {
        idx = static_cast<int>(
            std::floor((static_cast<double>(last) + ex) / 2.0));
        //  Replace >= here with > to obtain the last index instead of the
        //  first.
        if (ix[idx - 1] >= *center_x) {
          last = idx;
        } else {
          ex = idx;
        }
      } else {
        exitg2 = 1;
      }
    } while (exitg2 == 0);
    //  Replace < here with <= to obtain the last index instead of the first.
    if ((i == 1) && (std::abs(ix[last - 1] - *center_x) <
                     std::abs(ix[static_cast<int>(ex) - 1] - *center_x))) {
      ex = last;
    }
    b_ex = ix[static_cast<int>(ex) - 1];
  }
  idx_l = ex;
  if (b_ex > *center_x) {
    idx_l = ex - 1.0;
    if (ex - 1.0 > 0.0) {
      b_ex = ix[static_cast<int>(ex - 1.0) - 1];
    } else {
      b_ex = rtNaN;
    }
  }
  if (idx_l == 0.0) {
    ox.set_size(1, ix.size(1) + 1);
    ox[0] = *center_x;
    last = ix.size(1);
    for (i = 0; i < last; i++) {
      ox[i + 1] = ix[i];
    }
    oy_cell_f1.set_size(1, iy.size(1) + 1);
    oy_cell_f1[0] = *extrem_y;
    last = iy.size(1);
    for (i = 0; i < last; i++) {
      oy_cell_f1[i + 1] = iy[i];
    }
  } else if (b_ex == *center_x) {
    ox.set_size(1, ix.size(1));
    last = ix.size(1);
    for (i = 0; i < last; i++) {
      ox[i] = ix[i];
    }
    oy_cell_f1.set_size(1, iy.size(1));
    last = iy.size(1);
    for (i = 0; i < last; i++) {
      oy_cell_f1[i] = iy[i];
    }
  } else if (idx_l == ix.size(1)) {
    ox.set_size(1, ix.size(1) + 1);
    last = ix.size(1);
    for (i = 0; i < last; i++) {
      ox[i] = ix[i];
    }
    ox[ix.size(1)] = *center_x;
    oy_cell_f1.set_size(1, iy.size(1) + 1);
    last = iy.size(1);
    for (i = 0; i < last; i++) {
      oy_cell_f1[i] = iy[i];
    }
    oy_cell_f1[iy.size(1)] = *extrem_y;
  } else {
    if (static_cast<unsigned int>(idx_l) + 1U >
        static_cast<unsigned int>(ix.size(1))) {
      i = 0;
      s_size = 0;
    } else {
      i = static_cast<int>(static_cast<unsigned int>(idx_l));
      s_size = ix.size(1);
    }
    idx = static_cast<int>(idx_l);
    ox.set_size(1, ((static_cast<int>(idx_l) + s_size) - i) + 1);
    for (last = 0; last < idx; last++) {
      ox[last] = ix[last];
    }
    ox[static_cast<int>(idx_l)] = *center_x;
    last = s_size - i;
    for (s_size = 0; s_size < last; s_size++) {
      ox[(s_size + static_cast<int>(idx_l)) + 1] = ix[i + s_size];
    }
    if (static_cast<unsigned int>(idx_l) + 1U >
        static_cast<unsigned int>(iy.size(1))) {
      i = 0;
      s_size = 0;
    } else {
      i = static_cast<int>(static_cast<unsigned int>(idx_l));
      s_size = iy.size(1);
    }
    oy_cell_f1.set_size(1, ((static_cast<int>(idx_l) + s_size) - i) + 1);
    for (last = 0; last < idx; last++) {
      oy_cell_f1[last] = iy[last];
    }
    oy_cell_f1[static_cast<int>(idx_l)] = *extrem_y;
    last = s_size - i;
    for (s_size = 0; s_size < last; s_size++) {
      oy_cell_f1[(s_size + static_cast<int>(idx_l)) + 1] = iy[i + s_size];
    }
  }
  //  varargin{:});
  oy.set_size(1, oy_cell_f1.size(1));
  last = oy_cell_f1.size(1);
  for (i = 0; i < last; i++) {
    oy[i] = oy_cell_f1[i];
  }
}

// File trailer for simple_Gaussian_fit_insert_peaktop1_3.cpp\n\n[EOF]
