/*
 * Feat2DSpace1.h
 *
 *  Created on: 2022/05/19
 *      Author: rsaito
 */

#ifndef FEAT2DSPACE1_H_
#define FEAT2DSPACE1_H_

using namespace std;

template <class T_binning_val> class Binned_EqSegmsLen;

// void write_foffset(ofstream &, int);

template <class T_m, class T_n, class T_val>
class Feat2DSpace_EqSegmsLen {
public:
	Feat2DSpace_EqSegmsLen(T_m, T_m, int, int, T_n, T_n, int, int, T_val);
	virtual ~Feat2DSpace_EqSegmsLen();

	Binned_EqSegmsLen<T_m> *binned_m;
	Binned_EqSegmsLen<T_n> *binned_n;

	T_val **feat2d;

	int map_to_2d_evalmax(T_m, T_n, T_val);

	void output_2dmap();
	void write_2dmap(const char *, int);

};

#endif /* FEAT2DSPACE1_H_ */
