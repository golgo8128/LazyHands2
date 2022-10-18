//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: svd.cpp\n\nMATLAB Coder version            : 5.4\nC/C++ source code
// generated on  : 19-Jul-2022 12:31:39
//

// Include Files
#include "svd.h"
#include "rt_nonfinite.h"
#include "xaxpy.h"
#include "xdotc.h"
#include "xnrm2.h"
#include "xrot.h"
#include "xrotg.h"
#include "xswap.h"
#include "coder_array.h"
#include "rt_nonfinite.h"
#include <algorithm>
#include <cmath>
#include <cstring>

// Function Definitions
// Arguments    : const ::coder::array<double, 2U> &A\n               ::coder::array<double, 2U> &U\n               double s_data[]\n               int *s_size\n               double V[9]\nReturn Type  : void
namespace coder {
namespace internal {
void svd(const ::coder::array<double, 2U> &A, ::coder::array<double, 2U> &U,
         double s_data[], int *s_size, double V[9])
{
  array<double, 2U> b_A;
  array<double, 1U> work;
  double b_s_data[3];
  double e[3];
  double f;
  double rt;
  double scale;
  double sqds;
  int i;
  int minnp;
  int n;
  int ns;
  b_A.set_size(A.size(0), 3);
  ns = A.size(0) * 3;
  for (i = 0; i < ns; i++) {
    b_A[i] = A[i];
  }
  n = A.size(0);
  ns = A.size(0) + 1;
  if (ns > 3) {
    ns = 3;
  }
  minnp = A.size(0);
  if (minnp > 3) {
    minnp = 3;
  }
  if (ns - 1 >= 0) {
    std::memset(&b_s_data[0], 0, ns * sizeof(double));
  }
  e[0] = 0.0;
  e[1] = 0.0;
  e[2] = 0.0;
  work.set_size(A.size(0));
  ns = A.size(0);
  for (i = 0; i < ns; i++) {
    work[i] = 0.0;
  }
  U.set_size(A.size(0), A.size(0));
  ns = A.size(0) * A.size(0);
  for (i = 0; i < ns; i++) {
    U[i] = 0.0;
  }
  std::memset(&V[0], 0, 9U * sizeof(double));
  if (A.size(0) == 0) {
    V[0] = 1.0;
    V[4] = 1.0;
    V[8] = 1.0;
  } else {
    double nrm;
    double snorm;
    int ii;
    int m;
    int nct;
    int nctp1;
    int nmq;
    int qjj;
    int qp1;
    int qq;
    int temp_tmp;
    nct = A.size(0) - 1;
    if (nct > 3) {
      nct = 3;
    }
    nctp1 = nct + 1;
    if (nct >= 1) {
      i = nct;
    } else {
      i = 1;
    }
    for (int q = 0; q < i; q++) {
      boolean_T apply_transform;
      qp1 = q + 2;
      qq = (q + n * q) + 1;
      nmq = (n - q) - 1;
      apply_transform = false;
      if (q + 1 <= nct) {
        nrm = blas::xnrm2(nmq + 1, b_A, qq);
        if (nrm > 0.0) {
          apply_transform = true;
          if (b_A[qq - 1] < 0.0) {
            nrm = -nrm;
          }
          b_s_data[q] = nrm;
          if (std::abs(nrm) >= 1.0020841800044864E-292) {
            nrm = 1.0 / nrm;
            temp_tmp = qq + nmq;
            for (int k = qq; k <= temp_tmp; k++) {
              b_A[k - 1] = nrm * b_A[k - 1];
            }
          } else {
            temp_tmp = qq + nmq;
            for (int k = qq; k <= temp_tmp; k++) {
              b_A[k - 1] = b_A[k - 1] / b_s_data[q];
            }
          }
          b_A[qq - 1] = b_A[qq - 1] + 1.0;
          b_s_data[q] = -b_s_data[q];
        } else {
          b_s_data[q] = 0.0;
        }
      }
      for (int jj = qp1; jj < 4; jj++) {
        qjj = q + n * (jj - 1);
        if (apply_transform) {
          nrm = 0.0;
          if (nmq + 1 >= 1) {
            for (int k = 0; k <= nmq; k++) {
              nrm += b_A[(qq + k) - 1] * b_A[qjj + k];
            }
          }
          nrm = -(nrm / b_A[q + b_A.size(0) * q]);
          if ((nmq + 1 >= 1) && (!(nrm == 0.0))) {
            for (int k = 0; k <= nmq; k++) {
              temp_tmp = qjj + k;
              b_A[temp_tmp] = b_A[temp_tmp] + nrm * b_A[(qq + k) - 1];
            }
          }
        }
        e[jj - 1] = b_A[qjj];
      }
      if (q + 1 <= nct) {
        for (ii = q + 1; ii <= n; ii++) {
          U[(ii + U.size(0) * q) - 1] = b_A[(ii + b_A.size(0) * q) - 1];
        }
      }
      if (q + 1 <= 1) {
        nrm = blas::xnrm2(e);
        if (nrm == 0.0) {
          e[0] = 0.0;
        } else {
          if (e[1] < 0.0) {
            e[0] = -nrm;
          } else {
            e[0] = nrm;
          }
          nrm = e[0];
          if (std::abs(e[0]) >= 1.0020841800044864E-292) {
            nrm = 1.0 / e[0];
            for (int k = qp1; k < 4; k++) {
              e[k - 1] *= nrm;
            }
          } else {
            for (int k = qp1; k < 4; k++) {
              e[k - 1] /= nrm;
            }
          }
          e[1]++;
          e[0] = -e[0];
          if (n >= 2) {
            for (ii = qp1; ii <= n; ii++) {
              work[ii - 1] = 0.0;
            }
            for (int jj = qp1; jj < 4; jj++) {
              nrm = e[jj - 1];
              ns = n * (jj - 1) + 2;
              if ((nmq >= 1) && (!(nrm == 0.0))) {
                temp_tmp = nmq - 1;
                for (int k = 0; k <= temp_tmp; k++) {
                  qjj = k + 1;
                  work[qjj] = work[qjj] + nrm * b_A[(ns + k) - 1];
                }
              }
            }
            for (int jj = qp1; jj < 4; jj++) {
              nrm = -e[jj - 1] / e[1];
              ns = n * (jj - 1) + 2;
              if ((nmq >= 1) && (!(nrm == 0.0))) {
                temp_tmp = nmq - 1;
                for (int k = 0; k <= temp_tmp; k++) {
                  qjj = (ns + k) - 1;
                  b_A[qjj] = b_A[qjj] + nrm * work[k + 1];
                }
              }
            }
          }
        }
        for (ii = qp1; ii < 4; ii++) {
          V[ii - 1] = e[ii - 1];
        }
      }
    }
    if (A.size(0) + 1 >= 3) {
      m = 2;
    } else {
      m = A.size(0);
    }
    if (nct < 3) {
      b_s_data[nct] = b_A[nct + b_A.size(0) * nct];
    }
    if (A.size(0) < m + 1) {
      b_s_data[m] = 0.0;
    }
    if (m + 1 > 2) {
      e[1] = b_A[b_A.size(0) * m + 1];
    }
    e[m] = 0.0;
    if (nct + 1 <= A.size(0)) {
      for (int jj = nctp1; jj <= n; jj++) {
        for (ii = 0; ii < n; ii++) {
          U[ii + U.size(0) * (jj - 1)] = 0.0;
        }
        U[(jj + U.size(0) * (jj - 1)) - 1] = 1.0;
      }
    }
    for (int q = nct; q >= 1; q--) {
      qp1 = q + 1;
      ns = n - q;
      qq = (q + n * (q - 1)) - 1;
      if (b_s_data[q - 1] != 0.0) {
        for (int jj = qp1; jj <= n; jj++) {
          qjj = q + n * (jj - 1);
          nrm = 0.0;
          if (ns + 1 >= 1) {
            for (int k = 0; k <= ns; k++) {
              nrm += U[qq + k] * U[(qjj + k) - 1];
            }
          }
          nrm = -(nrm / U[qq]);
          blas::xaxpy(ns + 1, nrm, qq + 1, U, qjj);
        }
        for (ii = q; ii <= n; ii++) {
          U[(ii + U.size(0) * (q - 1)) - 1] =
              -U[(ii + U.size(0) * (q - 1)) - 1];
        }
        U[qq] = U[qq] + 1.0;
        for (ii = 0; ii <= q - 2; ii++) {
          U[ii + U.size(0) * (q - 1)] = 0.0;
        }
      } else {
        for (ii = 0; ii < n; ii++) {
          U[ii + U.size(0) * (q - 1)] = 0.0;
        }
        U[qq] = 1.0;
      }
    }
    for (int q = 2; q >= 0; q--) {
      if ((q + 1 <= 1) && (e[0] != 0.0)) {
        blas::xaxpy(-(blas::xdotc(V, V, 5) / V[1]), V, 5);
        blas::xaxpy(-(blas::xdotc(V, V, 8) / V[1]), V, 8);
      }
      V[3 * q] = 0.0;
      V[3 * q + 1] = 0.0;
      V[3 * q + 2] = 0.0;
      V[q + 3 * q] = 1.0;
    }
    nct = m;
    nctp1 = 0;
    snorm = 0.0;
    for (int q = 0; q <= m; q++) {
      nrm = b_s_data[q];
      if (nrm != 0.0) {
        rt = std::abs(nrm);
        nrm /= rt;
        b_s_data[q] = rt;
        if (q + 1 < m + 1) {
          e[q] /= nrm;
        }
        if (q + 1 <= n) {
          ns = n * q;
          i = ns + n;
          for (int k = ns + 1; k <= i; k++) {
            U[k - 1] = nrm * U[k - 1];
          }
        }
      }
      if (q + 1 < m + 1) {
        nrm = e[q];
        if (nrm != 0.0) {
          rt = std::abs(nrm);
          nrm = rt / nrm;
          e[q] = rt;
          b_s_data[q + 1] *= nrm;
          ns = 3 * (q + 1);
          i = ns + 3;
          for (int k = ns + 1; k <= i; k++) {
            V[k - 1] *= nrm;
          }
        }
      }
      nrm = std::abs(b_s_data[q]);
      rt = std::abs(e[q]);
      if ((nrm >= rt) || rtIsNaN(rt)) {
        rt = nrm;
      }
      if ((!(snorm >= rt)) && (!rtIsNaN(rt))) {
        snorm = rt;
      }
    }
    while ((m + 1 > 0) && (nctp1 < 75)) {
      boolean_T exitg1;
      ii = m;
      exitg1 = false;
      while (!(exitg1 || (ii == 0))) {
        nrm = std::abs(e[ii - 1]);
        if ((nrm <= 2.2204460492503131E-16 * (std::abs(b_s_data[ii - 1]) +
                                              std::abs(b_s_data[ii]))) ||
            (nrm <= 1.0020841800044864E-292) ||
            ((nctp1 > 20) && (nrm <= 2.2204460492503131E-16 * snorm))) {
          e[ii - 1] = 0.0;
          exitg1 = true;
        } else {
          ii--;
        }
      }
      if (ii == m) {
        ns = 4;
      } else {
        qjj = m + 1;
        ns = m + 1;
        exitg1 = false;
        while ((!exitg1) && (ns >= ii)) {
          qjj = ns;
          if (ns == ii) {
            exitg1 = true;
          } else {
            nrm = 0.0;
            if (ns < m + 1) {
              nrm = std::abs(e[ns - 1]);
            }
            if (ns > ii + 1) {
              nrm += std::abs(e[ns - 2]);
            }
            rt = std::abs(b_s_data[ns - 1]);
            if ((rt <= 2.2204460492503131E-16 * nrm) ||
                (rt <= 1.0020841800044864E-292)) {
              b_s_data[ns - 1] = 0.0;
              exitg1 = true;
            } else {
              ns--;
            }
          }
        }
        if (qjj == ii) {
          ns = 3;
        } else if (qjj == m + 1) {
          ns = 1;
        } else {
          ns = 2;
          ii = qjj;
        }
      }
      switch (ns) {
      case 1:
        f = e[m - 1];
        e[m - 1] = 0.0;
        for (int k = m; k >= ii + 1; k--) {
          blas::xrotg(&b_s_data[k - 1], &f, &sqds, &scale);
          if (k > ii + 1) {
            f = -scale * e[0];
            e[0] *= sqds;
          }
          blas::xrot(V, 3 * (k - 1) + 1, 3 * m + 1, sqds, scale);
        }
        break;
      case 2: {
        f = e[ii - 1];
        e[ii - 1] = 0.0;
        for (int k = ii + 1; k <= m + 1; k++) {
          double b;
          blas::xrotg(&b_s_data[k - 1], &f, &sqds, &scale);
          b = e[k - 1];
          f = -scale * b;
          e[k - 1] = b * sqds;
          if (n >= 1) {
            qjj = n * (k - 1);
            qq = n * (ii - 1);
            for (nmq = 0; nmq < n; nmq++) {
              temp_tmp = qq + nmq;
              ns = qjj + nmq;
              nrm = sqds * U[ns] + scale * U[temp_tmp];
              U[temp_tmp] = sqds * U[temp_tmp] - scale * U[ns];
              U[ns] = nrm;
            }
          }
        }
      } break;
      case 3: {
        double b;
        scale = std::abs(b_s_data[m]);
        nrm = b_s_data[m - 1];
        rt = std::abs(nrm);
        if ((!(scale >= rt)) && (!rtIsNaN(rt))) {
          scale = rt;
        }
        b = e[m - 1];
        rt = std::abs(b);
        if ((!(scale >= rt)) && (!rtIsNaN(rt))) {
          scale = rt;
        }
        rt = std::abs(b_s_data[ii]);
        if ((!(scale >= rt)) && (!rtIsNaN(rt))) {
          scale = rt;
        }
        rt = std::abs(e[ii]);
        if ((!(scale >= rt)) && (!rtIsNaN(rt))) {
          scale = rt;
        }
        f = b_s_data[m] / scale;
        nrm /= scale;
        rt = b / scale;
        sqds = b_s_data[ii] / scale;
        b = ((nrm + f) * (nrm - f) + rt * rt) / 2.0;
        nrm = f * rt;
        nrm *= nrm;
        if ((b != 0.0) || (nrm != 0.0)) {
          rt = std::sqrt(b * b + nrm);
          if (b < 0.0) {
            rt = -rt;
          }
          rt = nrm / (b + rt);
        } else {
          rt = 0.0;
        }
        f = (sqds + f) * (sqds - f) + rt;
        rt = sqds * (e[ii] / scale);
        for (int k = ii + 1; k <= m; k++) {
          blas::xrotg(&f, &rt, &sqds, &scale);
          if (k > ii + 1) {
            e[0] = f;
          }
          nrm = e[k - 1];
          b = b_s_data[k - 1];
          e[k - 1] = sqds * nrm - scale * b;
          rt = scale * b_s_data[k];
          b_s_data[k] *= sqds;
          blas::xrot(V, 3 * (k - 1) + 1, 3 * k + 1, sqds, scale);
          b_s_data[k - 1] = sqds * b + scale * nrm;
          blas::xrotg(&b_s_data[k - 1], &rt, &sqds, &scale);
          f = sqds * e[k - 1] + scale * b_s_data[k];
          b_s_data[k] = -scale * e[k - 1] + sqds * b_s_data[k];
          rt = scale * e[k];
          e[k] *= sqds;
          if (k < n) {
            qjj = n * (k - 1);
            qq = n * k;
            for (nmq = 0; nmq < n; nmq++) {
              temp_tmp = qq + nmq;
              ns = qjj + nmq;
              nrm = sqds * U[ns] + scale * U[temp_tmp];
              U[temp_tmp] = sqds * U[temp_tmp] - scale * U[ns];
              U[ns] = nrm;
            }
          }
        }
        e[m - 1] = f;
        nctp1++;
      } break;
      default:
        if (b_s_data[ii] < 0.0) {
          b_s_data[ii] = -b_s_data[ii];
          ns = 3 * ii;
          i = ns + 3;
          for (int k = ns + 1; k <= i; k++) {
            V[k - 1] = -V[k - 1];
          }
        }
        qp1 = ii + 1;
        while ((ii + 1 < nct + 1) && (b_s_data[ii] < b_s_data[qp1])) {
          rt = b_s_data[ii];
          b_s_data[ii] = b_s_data[qp1];
          b_s_data[qp1] = rt;
          blas::xswap(V, 3 * ii + 1, 3 * (ii + 1) + 1);
          if (ii + 1 < n) {
            qjj = n * ii;
            qq = n * (ii + 1);
            for (int k = 0; k < n; k++) {
              temp_tmp = qjj + k;
              nrm = U[temp_tmp];
              i = qq + k;
              U[temp_tmp] = U[i];
              U[i] = nrm;
            }
          }
          ii = qp1;
          qp1++;
        }
        nctp1 = 0;
        m--;
        break;
      }
    }
  }
  *s_size = minnp;
  if (minnp - 1 >= 0) {
    std::copy(&b_s_data[0], &b_s_data[minnp], &s_data[0]);
  }
}

} // namespace internal
} // namespace coder

// File trailer for svd.cpp\n\n[EOF]
