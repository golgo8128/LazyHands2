/*
 * EPheMatrix1.h
 *
 *  Created on: 2022/06/23
 *      Author: rsaito
 */

#ifndef EPHEMATRIX1_H_
#define EPHEMATRIX1_H_

#include "MassSpec/RS_MassSpectra_simple.h"

namespace rsMassSpec {

    // #include "MassSpec/ROIDetectsimple1.h"
	template <class T_mtime, class T_mz, class T_intst>
	class ROI_Detect_simple1;

	template <class T_mtime, class T_mz, class T_intst>
	class EPheMatrix1 {
	public:
		EPheMatrix1(RS_MassSpectra_simple<T_mtime, T_mz, T_intst>*);
		EPheMatrix1(RS_MassSpectra_simple<T_mtime, T_mz, T_intst>*, T_mtime);
		EPheMatrix1(RS_MassSpectra_simple<T_mtime, T_mz, T_intst>*, T_mtime, double, int);
		virtual ~EPheMatrix1();
		int num_mts;
		int num_mzs;
		int ref_mt_idx;

		// MassSpectrum_simple<T_mz, T_intst> *ref_mspectrum_p;

		T_mtime *ref_mts;
		T_mz* ref_mzs;
		T_intst **ephe_mat;
		T_mz **matched_mz_mat;

		virtual void initialize_by_ref_spectrum(int);
		void output_ephe_mat(const char *);
		void output_matched_mz_mat(const char *);
		void output_ephe_mat_txt(const char*);
		void output_matched_mz_mat_txt(const char*);


		int get_closest_ref_mt_idx(T_mtime);
		int get_closest_ref_mz_idx(T_mz);

		virtual int get_ephe_mt_idx_from_mspec_mt_idx(int);

	protected:
		RS_MassSpectra_simple<T_mtime, T_mz, T_intst>* rsmspectra_p;
		virtual void gen_ephe_matrix();
		virtual void set_ref_mts();
		virtual void set_ref_mzs();

		double mz_diff_thres = -1; // If negative, no mz diff thres.
		int top_prefer_mode = 0;


		friend class ROI_Detect_simple1<T_mtime, T_mz, T_intst>;

	};


	template <class T_mtime, class T_mz, class T_intst>
	class EPheMatrix1_eq_intervals : public EPheMatrix1<T_mtime, T_mz, T_intst> {

	public:
		EPheMatrix1_eq_intervals(RS_MassSpectra_simple<T_mtime, T_mz, T_intst>*, T_mtime);
		EPheMatrix1_eq_intervals(RS_MassSpectra_simple<T_mtime, T_mz, T_intst>*, T_mtime, double, int);
		void initialize_by_ref_spectrum(int) override;
		~EPheMatrix1_eq_intervals() override;

		virtual int get_ephe_mt_idx_from_mspec_mt_idx(int) override;

	protected:
		void gen_ephe_matrix() override;
		void set_ref_mts() override;
		void set_ref_mzs() override;

	};


} /* namespace rsMassSpec */

#endif /* EPHEMATRIX1_H_ */
