/*
 * RSMassSpectrasimpleRW.h
 *
 *  Created on: 2022/05/08
 *      Author: rsaito
 */

#include <boost/filesystem.hpp>

#ifndef RSMASSSPECTRASIMPLERW_H_
#define RSMASSSPECTRASIMPLERW_H_

#define NUM_VARINFO_SYMBS 4
#define VARINFO_MT_WITHIN_VARINFO_IDX 0
#define VARINFO_MZ_WITHIN_VARINFO_IDX 1
#define VARINFO_INTST_WITHIN_VARINFO_IDX 2
#define VARINFO_RPOS_WITHIN_VARINFO_IDX 3


using namespace std;

namespace rsMassSpec {

	void write_foffset(ofstream &, int, char *, int);

	template <class T_mtime, class T_mz, class T_intst> class RS_MassSpectra_simple;

	template <class T_mtime, class T_mz, class T_intst, class T_rpos>
	class RS_MassSpectra_simple_RW {
	public:
		RS_MassSpectra_simple_RW<T_mtime, T_mz, T_intst, T_rpos>(RS_MassSpectra_simple<T_mtime, T_mz, T_intst>*);
		virtual ~RS_MassSpectra_simple_RW<T_mtime, T_mz, T_intst, T_rpos>();

		RS_MassSpectra_simple<T_mtime, T_mz, T_intst> *rsmspectra;

		int get_header_bytes(int);
		void write_header_to_file(ofstream &, int);
		void output_to_file(const char *, int);

		int *sizes_ms_alloc();
		int *sizes_mzs_alloc();
		int *sizes_intsts_alloc();

		T_rpos *relposs_mzs_starts_alloc();
		T_rpos *relposs_mzs_ends_alloc();
		T_rpos *relposs_intsts_starts();
		T_rpos *relposs_intsts_ends();


	private:
		T_rpos *rposs_mzsstarts_allocarray;
		T_rpos *rposs_mzsends_allocarray;
		T_rpos *rposs_intstsstarts_allocarray;
		T_rpos *rposs_intstsends_allocarray;

		int *sizes_mzs_allocarray;
		int *sizes_intsts_allocarray;

	};

}

#endif /* RSMASSSPECTRASIMPLERW_H_ */
