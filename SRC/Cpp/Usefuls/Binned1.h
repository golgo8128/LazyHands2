#pragma once

struct ret_segm_info {
	int segm_num;
	int out_range_flag;
	int out_range_discard_flag;
};

template <class T_val>
struct ret_range_info {
	int segm_num;
	T_val range_l;
	T_val range_l_disp;
	T_val range_h;
	int out_range_flag;
	int out_range_discard_flag;
};



template <class T_val>
class Binned_Boundaries
{

public:
	Binned_Boundaries<T_val>(T_val *, int, int);
	~Binned_Boundaries<T_val>();
	T_val *boundaries;
	int num_boundaries;
	int num_regular_segms;

	ret_segm_info assign_segm_num(T_val);
	ret_range_info<T_val> range_given_segm_num(int);
	ret_range_info<T_val> range_assigned_segm(T_val);

	int num_assigned_segms();

private:
	int out_range_mode;

};




template <class T_val>
class Binned_EqSegmsLen
{
public:
	Binned_EqSegmsLen<T_val>(T_val, T_val, int, int);
	// ~Binned<T_val>();

	ret_segm_info assign_segm_num(T_val);

	T_val segm_width();
	ret_range_info<T_val> range_given_segm_num(int);
	int num_assigned_segms();

private:
	T_val range_l;
	T_val range_h;
	int num_segms;

	int out_range_mode;

};

