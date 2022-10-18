#pragma once

#include <list>

struct each_range_info {

	int start_idx;
	int end_idx;
	int top_idx;
	double top_val;
	double range_val_sum;

};

std::list<each_range_info> find_signif_ranges_zscores(double[], int, double, double);
std::list<each_range_info> find_signif_ranges_zscores(double[], double[], int, double, double);


