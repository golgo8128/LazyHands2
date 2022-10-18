#pragma once

#include <iostream>

// #include "PeakProc/spectrum_proc1.h" // Results in reciprocal include
struct found_mz_idx;

using namespace std;


namespace rsMassSpec {

	template <class T_mz, class T_intst> class MassSpectrum_simple
	{
	public:
		int num_mzs;

		T_mz* mzs; // This should be sorted.
		T_intst* intsts;

		MassSpectrum_simple<T_mz, T_intst>();
		~MassSpectrum_simple<T_mz, T_intst>();

		MassSpectrum_simple(const MassSpectrum_simple& srcobj);

		MassSpectrum_simple<T_mz, T_intst> *gen_copy();

		void disable_delete_arrs_at_end_flag();

		void set_spectrum(int, T_mz*, T_intst*);
		/* If T_mz* and T_intst* are not allocated by "new",
		 * call disable_delete_arrs_at_end_flag() */

		void print_spectrum();

		void output_spectrum_to_txtfile(const char[]); // , ios_base::openmode);

		void output_to_file(ofstream &);

		int bytesize_ms();
		int bytesize_mzs();
		int bytesize_intsts();

		int find_closest_mz_idx_given_mz(T_mz imz);
		found_mz_idx find_peak_top_idx_given_mz(T_mz imz);

	private:
		int delete_arrs_at_end_flag;

	};

}
