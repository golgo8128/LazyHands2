#include <iostream>
#include <fstream>
#include <iomanip>
#include "MassSpectrum_simple.h"
#include "PeakProc/spectrum_proc1.h"

/*
 * https://stackoverflow.com/questions/15199833/how-to-do-an-if-else-depending-type-of-type-in-c-template
 * https://docs.oracle.com/cd/E19205-01/820-1213/bkafv/index.html
 */

using namespace std;

namespace rsMassSpec {

	template <class T_mz, class T_intst>
		MassSpectrum_simple<T_mz, T_intst>::MassSpectrum_simple(){

		this->num_mzs = 0;
		this->mzs     = nullptr;
		this->intsts  = nullptr;
		this->delete_arrs_at_end_flag = 1;

	}


	/* Copy constructor
	 * If you need to overwrite existing instance,
	 * consider to use overload operator =
	 */
	template <class T_mz, class T_intst>
		MassSpectrum_simple<T_mz, T_intst>::MassSpectrum_simple(
			const MassSpectrum_simple<T_mz, T_intst> &srcobj) {

		this->num_mzs = srcobj.num_mzs;

		this->mzs = new T_mz[this->num_mzs];
		this->intsts = new T_intst[this->num_mzs];

		for (int i = 0; i < this->num_mzs; i++) {
			this->mzs[i] = srcobj.mzs[i];
			this->intsts[i] = srcobj.intsts[i];
		}
		
		this->delete_arrs_at_end_flag = 1;

	}

	template <class T_mz, class T_intst>
	MassSpectrum_simple<T_mz, T_intst> *MassSpectrum_simple<T_mz, T_intst>::gen_copy() {

		MassSpectrum_simple<T_mz, T_intst> *ospectrum = new MassSpectrum_simple<T_mz, T_intst>();
		ospectrum->num_mzs = this->num_mzs;

		ospectrum->mzs    = new T_mz[ ospectrum->num_mzs ];
		ospectrum->intsts = new T_intst[ ospectrum->num_mzs ];

		for(int i = 0;i < ospectrum->num_mzs;i ++){
			ospectrum->mzs[i]    = this->mzs[i];
			ospectrum->intsts[i] = this->intsts[i];
		}

		ospectrum->delete_arrs_at_end_flag = 1;

		return ospectrum;

	}



	template <class T_mz, class T_intst>
		void MassSpectrum_simple<T_mz, T_intst>::disable_delete_arrs_at_end_flag(){

			this->delete_arrs_at_end_flag = 0;

		}


	template <class T_mz, class T_intst>
		void MassSpectrum_simple<T_mz, T_intst>::set_spectrum(
			int inum_mzs, T_mz* i_allocated_mzs, T_intst* i_allocated_intsts) {
			// Warning: i_allocated_mzs and i_allocated_intsts are subject to
			//   "delete" by destructor.

			this->num_mzs = inum_mzs;
			this->mzs = i_allocated_mzs;
			this->intsts = i_allocated_intsts;

	}

	template <class T_mz, class T_intst>
		void MassSpectrum_simple<T_mz, T_intst>::print_spectrum(){

		for(int i = 0;i < this->num_mzs; i ++){
			cout << i << "\t" << this->mzs[ i ] << "\t" << this->intsts[ i ] << endl;
		}

	}

	template <class T_mz, class T_intst>
		void MassSpectrum_simple<T_mz, T_intst>::output_spectrum_to_txtfile(
				const char otxtfile[]){
				// ios_base::openmode imode){ //  = ios_base::out

		ofstream fw;
		fw.open(otxtfile, ios_base::out);
		fw << setprecision(15);

		for(int i = 0;i < this->num_mzs; i ++){
			fw << i << "\t" << this->mzs[ i ] << "\t" << this->intsts[ i ] << endl;
		}

		fw.close();

	}


	template <class T_mz, class T_intst>
		MassSpectrum_simple<T_mz, T_intst>::~MassSpectrum_simple(){

		this->num_mzs = 0;

		if(nullptr != this->mzs){
			if(this->delete_arrs_at_end_flag)
				delete[] this->mzs;
			this->mzs = nullptr;
		}
		if(nullptr != this->intsts){
			if (this->delete_arrs_at_end_flag)
				delete[] this->intsts;
			this->intsts = nullptr;
		}

		// cout << "MassSpectrum_simple destructor called." << endl;

	}


	template <class T_mz, class T_intst>
		void MassSpectrum_simple<T_mz, T_intst>::output_to_file(ofstream &fw){
		// ofstream fw (without "&") will probably not work probably because operator= is not defined.
		// https://yohhoy.hatenadiary.jp/entry/20130203/p1
		// fw should be opened with std::ios::out | std::ios::binary

		fw.write(reinterpret_cast<const char*>(this->mzs), this->bytesize_mzs());
		fw.write(reinterpret_cast<const char*>(this->intsts), this->bytesize_intsts());

	}


	template <class T_mz, class T_intst>
		int MassSpectrum_simple<T_mz, T_intst>::bytesize_ms(){

		return this->bytesize_mzs() + this->bytesize_intsts();

	}

	template <class T_mz, class T_intst>
		int MassSpectrum_simple<T_mz, T_intst>::bytesize_mzs(){

		return (int)(sizeof(T_mz) * this->num_mzs);

	}

	template <class T_mz, class T_intst>
		int MassSpectrum_simple<T_mz, T_intst>::bytesize_intsts(){

		return (int)(sizeof(T_intst) * this->num_mzs);

	}


	template <class T_mz, class T_intst>
	int MassSpectrum_simple<T_mz, T_intst>::find_closest_mz_idx_given_mz(T_mz imz){

		return closest_value_in_sorted_get_idx<T_mz>(this->mzs, this->num_mzs, imz);


	}



	template <class T_mz, class T_intst>
	found_mz_idx MassSpectrum_simple<T_mz, T_intst>::find_peak_top_idx_given_mz(T_mz imz){

		return find_peak_top_idx_from_spectrum_given_mz(*this, imz);


	}


	template class MassSpectrum_simple<float, int>;
	template class MassSpectrum_simple<double, int>;
	template class MassSpectrum_simple<float, double>;

	/*

	* https://teratail.com/questions/123776
	* https://zenn.dev/nanbokku/articles/cpp-template-file-division

	*/

}

