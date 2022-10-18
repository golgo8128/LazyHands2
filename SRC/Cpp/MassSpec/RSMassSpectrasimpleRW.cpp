/*
 * RSMassSpectrasimpleRW.cpp
 *
 *  Created on: 2022/05/08
 *      Author: rsaito
 */

#include <iostream>
#include <fstream>
#include <typeinfo>
#include <boost/filesystem.hpp>
#include "RSMassSpectrasimpleRW.h"
#include "RS_MassSpectra_simple.h"
#include "MassSpectrum_simple.h"

#include "Usefuls/rsBinaryDat1.h"
#include "Usefuls/vartype1.h"

#include "Exceptions/rsMHandsExcept1.h"

using namespace std;

namespace rsMassSpec {

	void write_foffset(
			ofstream &fw,
			int foffset_byte_size,
			char *vartypes, int vartypes_len){
		// ofstream fw (without "&") will probably not work probably because operator= is not defined.
		// https://yohhoy.hatenadiary.jp/entry/20130203/p1
		// fw should be opened with std::ios::out | std::ios::binary

		size_t head_size = 0;

		fw.write(reinterpret_cast<const char*>(&foffset_byte_size), sizeof(int));
		head_size += sizeof(int);
		fw.write(reinterpret_cast<const char*>(&rsBinaryDat::MAGIC_ENDIAN_CHECK), sizeof(int));
		head_size += sizeof(int);
		fw.write(vartypes, vartypes_len);
		head_size += vartypes_len;

		for(int i = (int)head_size;i < foffset_byte_size;i ++) {
			fw.write(&rsBinaryDat::MAGIC_ZERO, sizeof(char));;
		}

	}

	template <class T_mtime, class T_mz, class T_intst, class T_rpos>
	RS_MassSpectra_simple_RW<T_mtime, T_mz, T_intst, T_rpos>::RS_MassSpectra_simple_RW(
			RS_MassSpectra_simple<T_mtime, T_mz, T_intst>* irsmspectra) {
		// TODO Auto-generated constructor stub

		if(irsmspectra->get_num_spectra_registered() < irsmspectra->num_spectra){
			throw rsMHandsExcept("Incomplete registeration of spectra");
		}

		this->rsmspectra = irsmspectra;

		// CAUTION: Order matters.
		this->rposs_mzsstarts_allocarray    = this->relposs_mzs_starts_alloc();
		this->rposs_mzsends_allocarray      = this->relposs_mzs_ends_alloc();
		this->rposs_intstsstarts_allocarray = this->relposs_intsts_starts();
		this->rposs_intstsends_allocarray   = this->relposs_intsts_ends();

		this->sizes_mzs_allocarray    = this->sizes_mzs_alloc();
		this->sizes_intsts_allocarray = this->sizes_intsts_alloc();

		/*
		for(int i = 0;i < this->rsmspectra->num_spectra;i ++){
			cout << i << " -- " <<  this->rposs_mzsends_allocarray[i] << endl;
		}
		 */

	}

	template <class T_mtime, class T_mz, class T_intst, class T_rpos>
	RS_MassSpectra_simple_RW<T_mtime, T_mz, T_intst, T_rpos>::~RS_MassSpectra_simple_RW() {
		// TODO Auto-generated destructor stub

		delete[] this->rposs_mzsstarts_allocarray;
		delete[] this->rposs_mzsends_allocarray;
		delete[] this->rposs_intstsstarts_allocarray;
		delete[] this->rposs_intstsends_allocarray;

		delete[] this->sizes_mzs_allocarray;
		delete[] this->sizes_intsts_allocarray;

	}

	template <class T_mtime, class T_mz, class T_intst, class T_rpos>
	void RS_MassSpectra_simple_RW<T_mtime, T_mz, T_intst, T_rpos>::output_to_file(const char *opath, int foffset_byte_size){

			boost::filesystem::path parentdir = boost::filesystem::path(opath).parent_path();
			boost::filesystem::create_directory(parentdir);

			std::ofstream fw;
			fw.open(opath, ios::out | ios::binary);

			char vartypes[NUM_VARINFO_SYMBS];
			vartypes[VARINFO_MT_WITHIN_VARINFO_IDX] = get_vartype_from_typename(typeid(T_mtime).name());
			vartypes[VARINFO_MZ_WITHIN_VARINFO_IDX] = get_vartype_from_typename(typeid(T_mz).name());
			vartypes[VARINFO_INTST_WITHIN_VARINFO_IDX] = get_vartype_from_typename(typeid(T_intst).name());
			vartypes[VARINFO_RPOS_WITHIN_VARINFO_IDX] = get_vartype_from_typename(typeid(T_rpos).name());
			write_foffset(fw, foffset_byte_size, vartypes, 4); // namespace O.K?

			write_header_to_file(fw, foffset_byte_size);

			for(int i = 0;i < this->rsmspectra->num_spectra;i ++){
				MassSpectrum_simple<T_mz, T_intst> *mspec_p = this->rsmspectra->mspectra[i];
				mspec_p->output_to_file(fw);
			}

			fw.close();

	}
	

	template <class T_mtime, class T_mz, class T_intst, class T_rpos>
	int RS_MassSpectra_simple_RW<T_mtime, T_mz, T_intst, T_rpos>::get_header_bytes(int foffset_byte_size){

		/*
		cout << foffset_byte_size << " " << sizeof(int) << " "
			<< this->rsmspectra->num_spectra * sizeof(T_mtime)
			<< " " << this->rsmspectra->num_spectra * sizeof(T_rpos) * 2
			<< " " << this->rsmspectra->num_spectra * sizeof(int) * 2 << endl;
		*/

		return foffset_byte_size
			+ sizeof(int) // <--- Number of spectra is represented by the type int.
			+ this->rsmspectra->num_spectra * sizeof(T_mtime)
			+ this->rsmspectra->num_spectra * sizeof(T_rpos) * 2 // rposs
			+ this->rsmspectra->num_spectra * sizeof(int) * 2; // sizes

	}


	/*
	template <class T_mtime, class T_mz, class T_intst, class T_rpos>
	void RS_MassSpectra_simple_RW<T_mtime, T_mz, T_intst, T_rpos>::write_foffset(
			ofstream &fw,
			int foffset_byte_size){
		// ofstream fw (without "&") will probably not work probably because operator= is not defined.
		// https://yohhoy.hatenadiary.jp/entry/20130203/p1
		// fw should be opened with std::ios::out | std::ios::binary

		int endian_check = 0x01020304;
		char zero = 0x00;
		fw.write(reinterpret_cast<const char*>(&foffset_byte_size), sizeof(int));
		fw.write(reinterpret_cast<const char*>(&endian_check), sizeof(int));

		for(int i = 0;i < foffset_byte_size - (int)(sizeof(int)*2);i ++) {
			fw.write(&zero, sizeof(char));;
		}

	}
	 */

	template <class T_mtime, class T_mz, class T_intst, class T_rpos>
	void RS_MassSpectra_simple_RW<T_mtime, T_mz, T_intst, T_rpos>::write_header_to_file(
			ofstream &fw,
			int foffset_byte_size){

		if(this->rsmspectra->num_spectra == 0)return;
				
		int header_bytes = this->get_header_bytes(foffset_byte_size);
		T_rpos* buf_rpos = new T_rpos[this->rsmspectra->num_spectra];

		fw.write(reinterpret_cast<const char*>(
					&this->rsmspectra->num_spectra),
					sizeof(int));		
				
		fw.write(reinterpret_cast<const char*>(this->rsmspectra->mtimes),
				  this->rsmspectra->num_spectra * sizeof(T_mtime));

		for (int i = 0; i < this->rsmspectra->num_spectra; i++)
			buf_rpos[i] = this->rposs_mzsstarts_allocarray[i] + header_bytes;
		fw.write(reinterpret_cast<const char*>(buf_rpos),
			this->rsmspectra->num_spectra * sizeof(T_rpos));

		fw.write(reinterpret_cast<const char*>(this->sizes_mzs_allocarray),
			this->rsmspectra->num_spectra * sizeof(int)); // Not sizeof(T_mz)

		for (int i = 0; i < this->rsmspectra->num_spectra; i++)
			buf_rpos[i] = this->rposs_intstsstarts_allocarray[ i ] + header_bytes;
		fw.write(reinterpret_cast<const char*>(buf_rpos),
			this->rsmspectra->num_spectra * sizeof(T_rpos));


		fw.write(reinterpret_cast<const char*>(this->sizes_intsts_allocarray),
			this->rsmspectra->num_spectra * sizeof(int));  // Not sizeof(T_intst)


		delete[] buf_rpos;

	}
	

	template <class T_mtime, class T_mz, class T_intst, class T_rpos>
	T_rpos *RS_MassSpectra_simple_RW<T_mtime, T_mz, T_intst, T_rpos>::relposs_mzs_starts_alloc(){
		// ofstream fw (without "&") will probably not work probably because operator= is not defined.
		// https://yohhoy.hatenadiary.jp/entry/20130203/p1
		// fw should be opened with std::ios::out | std::ios::binary

		T_rpos*relposs_alloc = new T_rpos[ this->rsmspectra->num_spectra ];

		relposs_alloc[ 0 ] = 0;
		for(int i = 0; i < this->rsmspectra->num_spectra - 1; i ++) {
			relposs_alloc[ i + 1 ] = relposs_alloc[ i ] + this->rsmspectra->mspectra[i]->bytesize_ms();
		}

		return(relposs_alloc);

	}

	template <class T_mtime, class T_mz, class T_intst, class T_rpos>
	T_rpos *RS_MassSpectra_simple_RW<T_mtime, T_mz, T_intst, T_rpos>::relposs_mzs_ends_alloc(){
		// ofstream fw (without "&") will probably not work probably because operator= is not defined.
		// https://yohhoy.hatenadiary.jp/entry/20130203/p1
		// fw should be opened with std::ios::out | std::ios::binary

		T_rpos *relposs_alloc = new T_rpos[ this->rsmspectra->num_spectra ];

		relposs_alloc[ 0 ] = 0;
		for(int i = 0; i < this->rsmspectra->num_spectra; i ++) {
			relposs_alloc[ i ] =
					this->rposs_mzsstarts_allocarray[ i ] + this->rsmspectra->mspectra[i]->bytesize_mzs() - 1;
		}

		return(relposs_alloc);

	}


	template <class T_mtime, class T_mz, class T_intst, class T_rpos>
	T_rpos *RS_MassSpectra_simple_RW<T_mtime, T_mz, T_intst, T_rpos>::relposs_intsts_starts(){
		// ofstream fw (without "&") will probably not work probably because operator= is not defined.
		// https://yohhoy.hatenadiary.jp/entry/20130203/p1
		// fw should be opened with std::ios::out | std::ios::binary

		T_rpos *relposs_alloc = new T_rpos[ this->rsmspectra->num_spectra ];

		for(int i = 0; i < this->rsmspectra->num_spectra; i ++) {
			relposs_alloc[ i ] = this->rposs_mzsends_allocarray[ i ] + 1;
		}

		return(relposs_alloc);

	}

	template <class T_mtime, class T_mz, class T_intst, class T_rpos>
	T_rpos *RS_MassSpectra_simple_RW<T_mtime, T_mz, T_intst, T_rpos>::relposs_intsts_ends(){
		// ofstream fw (without "&") will probably not work probably because operator= is not defined.
		// https://yohhoy.hatenadiary.jp/entry/20130203/p1
		// fw should be opened with std::ios::out | std::ios::binary

		T_rpos *relposs_alloc = new T_rpos[ this->rsmspectra->num_spectra ];

		for(int i = 0; i < this->rsmspectra->num_spectra; i ++) {
			relposs_alloc[ i ] = this->rposs_intstsstarts_allocarray[ i ] + this->rsmspectra->mspectra[i]->bytesize_intsts() - 1;
		}

		return(relposs_alloc);

	}



	template <class T_mtime, class T_mz, class T_intst, class T_rpos>
	int *RS_MassSpectra_simple_RW<T_mtime, T_mz, T_intst, T_rpos>::sizes_ms_alloc(){
		// ofstream fw (without "&") will probably not work probably because operator= is not defined.
		// https://yohhoy.hatenadiary.jp/entry/20130203/p1
		// fw should be opened with std::ios::out | std::ios::binary

		int *osizes_ms_alloc = new int[ this->rsmspectra->num_spectra ];
		for(int i = 0;i < this->rsmspectra->num_spectra; i++){
			osizes_ms_alloc[ i ] = this->rsmspectra->mspectra[i]->bytesize_ms();
		}

		return osizes_ms_alloc;

	}



	template <class T_mtime, class T_mz, class T_intst, class T_rpos>
	int *RS_MassSpectra_simple_RW<T_mtime, T_mz, T_intst, T_rpos>::sizes_mzs_alloc(){
		// ofstream fw (without "&") will probably not work probably because operator= is not defined.
		// https://yohhoy.hatenadiary.jp/entry/20130203/p1
		// fw should be opened with std::ios::out | std::ios::binary

		int *osizes_mzs_alloc = new int[ this->rsmspectra->num_spectra ];
		for(int i = 0;i < this->rsmspectra->num_spectra; i++){
			osizes_mzs_alloc[ i ] = this->rsmspectra->mspectra[i]->bytesize_mzs();
		}

		return osizes_mzs_alloc;

	}


	template <class T_mtime, class T_mz, class T_intst, class T_rpos>
	int *RS_MassSpectra_simple_RW<T_mtime, T_mz, T_intst, T_rpos>::sizes_intsts_alloc(){
		// ofstream fw (without "&") will probably not work probably because operator= is not defined.
		// https://yohhoy.hatenadiary.jp/entry/20130203/p1
		// fw should be opened with std::ios::out | std::ios::binary

		int *osizes_intsts_alloc = new int[ this->rsmspectra->num_spectra ];
		for(int i = 0;i < this->rsmspectra->num_spectra; i++){
			osizes_intsts_alloc[ i ] = this->rsmspectra->mspectra[i]->bytesize_intsts();
		}

		return osizes_intsts_alloc;

	}

	template class RS_MassSpectra_simple_RW<float, float, int, int>;
	template class RS_MassSpectra_simple_RW<float, double, int, long>;
	template class RS_MassSpectra_simple_RW<float, double, int, long long>;
	template class RS_MassSpectra_simple_RW<float, float, int, long long>;
	template class RS_MassSpectra_simple_RW<float, float, double, int>;

}




