/*
 * rsBinaryDat1.h
 *
 *  Created on: 2022/05/21
 *      Author: rsaito
 */

#ifndef RSBINARYDAT1_H_
#define RSBINARYDAT1_H_

#include <fstream>

#define NUM_VARTYPE_SYMBS 4
// OFFSET_BYTES_IDXS = 1:4;
// MAGIC_ENDIAN_CHECK_IDXS = 5:8;
#define VARTYPE_SYMB_RANGES_M_WITHIN_VARTYPE_IDX 0
#define VARTYPE_SYMB_RANGES_N_WITHIN_VARTYPE_IDX 1
#define VARTYPE_SYMB_VALS_WITHIN_VARTYPE_IDX 2
#define VARTYPE_SYMB_2DSIZES_WITHIN_VARTYPE_IDX 3


using namespace std;

namespace rsBinaryDat {

	const static int MAGIC_ENDIAN_CHECK = 0x01020304;
	const static char MAGIC_ZERO = 0x00;

	void write_foffset(ofstream&, int, const char[4]);

	template <class T_m, class T_n, class T_val, class T_2dsize>
	void write_2dmap(
		const char*,
		T_m[], T_2dsize, // Number of assigned segments
		T_n[], T_2dsize, // Number of assigned segments
		T_val *[],
		int);

}

#endif /* RSBINARYDAT1_H_ */
