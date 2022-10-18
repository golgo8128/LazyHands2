
#include <list>
#include "Usefuls/calc_simple1.h"
#include "find_signif_ranges1.h"

using namespace std;

list<each_range_info> find_signif_ranges_zscores(
		double izscores[], int inum, double izscore_thres, double izscore_base) {


	list<each_range_info> range_info_list;

	int j = 0;
	while (j < inum) {
		if (izscores[j] >= izscore_thres) {
			int j_left, j_right;
			for (j_left = j; j_left >= 0 && izscores[j_left] > izscore_base; j_left--);
			if(izscores[j_left] < izscore_base && j_left < inum - 1)j_left ++;
			for (j_right = j; j_right < inum && izscores[j_right] > izscore_base; j_right++);
			if(izscores[j_right] < izscore_base && j_right > 0)j_right --;

			struct each_range_info erange_info;
			erange_info.start_idx = j_left;
			erange_info.end_idx   = j_right;
			erange_info.top_idx   = argmax_simple<double>(&izscores[j_left], j_right - j_left + 1) + j_left;
			erange_info.top_val   = izscores[ erange_info.top_idx ];
			erange_info.range_val_sum = sum_simple<double, double>(&izscores[j_left], j_right - j_left + 1);

			range_info_list.push_back(erange_info);

			j = j_right + 1;

		} else {
			j ++;
		}

	}

	return range_info_list;

}

list<each_range_info> find_signif_ranges_zscores(
		double izscores[], double izscores_smoothed[], int inum, double izscore_thres, double izscore_base) {


	list<each_range_info> range_info_list;

	int j = 0;
	while (j < inum) {
		if (izscores[j] >= izscore_thres && izscores_smoothed[j] >= izscore_thres) {
			int j_left, j_right;
			for (j_left = j; j_left >= 0 && izscores[j_left] > izscore_base; j_left--);
			if(izscores[j_left] < izscore_base && j_left < inum - 1)j_left ++;
			for (j_right = j; j_right < inum && izscores[j_right] > izscore_base; j_right++);
			if(izscores[j_right] < izscore_base && j_right > 0)j_right --;

			struct each_range_info erange_info;
			erange_info.start_idx = j_left;
			erange_info.end_idx   = j_right;
			erange_info.top_idx   = argmax_simple<double>(&izscores[j_left], j_right - j_left + 1) + j_left;
			erange_info.top_val   = izscores[ erange_info.top_idx ];
			erange_info.range_val_sum = sum_simple<double, double>(&izscores[j_left], j_right - j_left + 1);

			range_info_list.push_back(erange_info);

			j = j_right + 1;

		} else {
			j ++;
		}

	}

	return range_info_list;

}
