/*
 * calc_simple1.h
 *
 *  Created on: 2022/07/05
 *      Author: rsaito
 */

template <class Tin, class Tout>Tout sum_simple(Tin *, int);
template <class T>double mean_simple(T *, int);
template <class T>double var_estim_simple(T *, int);
template <class T>double sd_estim_simple(T *, int);
template <class T>void zscores_simple(T *, int, double[]);
template <class T>int argmax_simple(T[], int);

double div0_x_eq_0(double, double);


