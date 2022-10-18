/*
 * ROIEPheMatFindPeaks1.h
 *
 *  Created on: 2022/07/19
 *      Author: rsaito
 */

#ifndef ROIEPHEMATFINDPEAKS1_H_
#define ROIEPHEMATFINDPEAKS1_H_

namespace rsMassSpec {

	template <class T_mtime, class T_mz>
	class ROI_EPheMat_FindPeaks1 {
	public:
		ROI_EPheMat_FindPeaks1(double **, double **, T_mz *, int, T_mtime *, int);
		virtual ~ROI_EPheMat_FindPeaks1();

		void search_write_peak_info(double, double);

	private:
		double **zmat;
		double **zmat_smoothed;
		T_mz *mzs;
		T_mtime *mts;

		int m_len;
		int n_len;

	};

} /* namespace rsMassSpec */

#endif /* ROIEPHEMATFINDPEAKS1_H_ */
