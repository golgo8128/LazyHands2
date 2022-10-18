/*
 * rsBinaryDat1.cpp
 *
 *  Created on: 2022/05/21
 *      Author: rsaito
 */


#include <iostream>
#include <fstream>
#include <typeinfo>
#include <boost/filesystem.hpp>

#include "Usefuls/rsBinaryDat1.h"
#include "Usefuls/vartype1.h"

using namespace std;

namespace rsBinaryDat {

	void write_foffset(
		ofstream& fw,
		int foffset_byte_size,
		const char vartype_symbs[NUM_VARTYPE_SYMBS]) {
		// ofstream fw (without "&") will probably not work probably because operator= is not defined.
		// https://yohhoy.hatenadiary.jp/entry/20130203/p1
		// fw should be opened with std::ios::out | std::ios::binary

		size_t head_size = 0;

		fw.write(reinterpret_cast<const char*>(&foffset_byte_size), sizeof(int));
		head_size += sizeof(int);
		fw.write(reinterpret_cast<const char*>(&MAGIC_ENDIAN_CHECK), sizeof(int));
		head_size += sizeof(int);
		fw.write(reinterpret_cast<const char*>(vartype_symbs), NUM_VARTYPE_SYMBS);
		head_size += NUM_VARTYPE_SYMBS;

		for (int i = (int)(head_size); i < foffset_byte_size; i++) {
			fw.write(&MAGIC_ZERO, sizeof(char));;
		}

	}

	template <class T_m, class T_n, class T_val, class T_2dsize>
	void write_2dmap(
		const char* opath,
		T_m m_range_ls[], T_2dsize len_m, // Number of assigned segments
		T_n n_range_ls[], T_2dsize len_n, // Number of assigned segments
		T_val *feat2d[],
		int foffset_byte_size) {

		char vartype_symbs[NUM_VARTYPE_SYMBS];
		vartype_symbs[VARTYPE_SYMB_RANGES_M_WITHIN_VARTYPE_IDX]
			= get_vartype_from_typename(typeid(T_m).name());
		vartype_symbs[VARTYPE_SYMB_RANGES_N_WITHIN_VARTYPE_IDX]
			= get_vartype_from_typename(typeid(T_n).name());
		vartype_symbs[VARTYPE_SYMB_VALS_WITHIN_VARTYPE_IDX]
			= get_vartype_from_typename(typeid(T_val).name());
		vartype_symbs[VARTYPE_SYMB_2DSIZES_WITHIN_VARTYPE_IDX]
			= get_vartype_from_typename(typeid(T_2dsize).name()); // len_m, len_n


		boost::filesystem::path parentdir = boost::filesystem::path(opath).parent_path();
		boost::filesystem::create_directory(parentdir);

		std::ofstream fw;
		fw.open(opath, ios::out | ios::binary);

		write_foffset(fw, foffset_byte_size, vartype_symbs); // namespace O.K?

		fw.write(reinterpret_cast<const char*>(&len_m), sizeof(T_2dsize));
		fw.write(reinterpret_cast<const char*>(&len_n), sizeof(T_2dsize));

		for (T_2dsize i = 0; i < len_m; i++) {
			fw.write(reinterpret_cast<const char*>(&m_range_ls[i]), sizeof(T_m));
		}
		for (T_2dsize j = 0; j < len_n; j++) {
			fw.write(reinterpret_cast<const char*>(&n_range_ls[j]), sizeof(T_n));
		}

		for (T_2dsize i = 0; i < len_m; i++)
			for (T_2dsize j = 0; j < len_n; j++) {
				fw.write(reinterpret_cast<const char*>(&feat2d[i][j]), sizeof(T_val));
			}

		fw.close();

	}


	template void write_2dmap<float, float, float, int>(
		const char*,
		float[], int, // Number of assigned segments
		float[], int, // Number of assigned segments
		float *[],
		int);

	template void write_2dmap<float, float, int, int>(
		const char*,
		float[], int, // Number of assigned segments
		float[], int, // Number of assigned segments
		int *[],
		int);

	template void write_2dmap<double, float, int, int>(
		const char*,
		double[], int, // Number of assigned segments
		float[], int, // Number of assigned segments
		int *[],
		int);

	template void write_2dmap<double, float, double, int>(
		const char*,
		double[], int, // Number of assigned segments
		float[], int, // Number of assigned segments
		double *[],
		int);

	template void write_2dmap<float, int, double, int>(
		const char*,
		float[], int, // Number of assigned segments
		int[], int, // Number of assigned segments
		double* [],
		int);

	template void write_2dmap<float, long long, double, int>(
		const char*,
		float[], int, // Number of assigned segments
		long long[], int, // Number of assigned segments
		double* [],
		int);

	template void write_2dmap<float, long long, float, int>(
		const char*,
		float[], int, // Number of assigned segments
		long long[], int, // Number of assigned segments
		float* [],
		int);

	template void write_2dmap<float, long long, float, unsigned long long>(
		const char*,
		float[], unsigned long long, // Number of assigned segments
		long long[], unsigned long long, // Number of assigned segments
		float* [],
		int);

	template void write_2dmap<double, long long, float, unsigned int>(
		const char*,
		double[], unsigned int, // Number of assigned segments
		long long[], unsigned int, // Number of assigned segments
		float* [],
		int);

	template void write_2dmap<float, float, int, unsigned int>(
		const char*,
		float[], unsigned int, // Number of assigned segments
		float[], unsigned int, // Number of assigned segments
		int* [],
		int);

	template void write_2dmap<double, float, int, unsigned int>(
		const char*,
		double[], unsigned int, // Number of assigned segments
		float[], unsigned int, // Number of assigned segments
		int* [],
		int);

	template void write_2dmap<float, float, float, unsigned int>(
		const char*,
		float[], unsigned int, // Number of assigned segments
		float[], unsigned int, // Number of assigned segments
		float* [],
		int);


	template void write_2dmap<double, float, double, unsigned int>(
		const char*,
		double[], unsigned int, // Number of assigned segments
		float[], unsigned int, // Number of assigned segments
		double* [],
		int);

	template void write_2dmap<float, float, double, unsigned int>(
		const char*,
		float[], unsigned int, // Number of assigned segments
		float[], unsigned int, // Number of assigned segments
		double* [],
		int);

	template void write_2dmap<float, float, char, unsigned int>(
		const char*,
		float[], unsigned int, // Number of assigned segments
		float[], unsigned int, // Number of assigned segments
		char* [],
		int);

	template void write_2dmap<double, double, double, unsigned int>(
		char const*,
		double* const, unsigned int,
		double* const, unsigned int,
		double** const,
		int);

	template void write_2dmap<double, double, char, int>(
		char const*,
		double* const, int,
		double* const, int,
		char** const, int);

}



