
#include <string.h>
#include "Binned1.h"
#include "closest_value_in_sorted1.h"

#include "Exceptions/rsMHandsExcept1.h"


template <class T_val>
Binned_Boundaries<T_val>::Binned_Boundaries(
		T_val iboundaries[], int inum_boundaries, int iout_range_mode){

    if(inum_boundaries < 2 && iout_range_mode == 0){
    	throw rsMHandsExcept("Insufficient number of boundaries.");
    }

	this->boundaries = new T_val[ inum_boundaries ];
	memcpy(this->boundaries, iboundaries, sizeof(T_val) * inum_boundaries);
	this->num_boundaries = inum_boundaries;
	this->num_regular_segms = inum_boundaries - 1;
	this->out_range_mode = iout_range_mode;

}

template <class T_val>
Binned_Boundaries<T_val>::~Binned_Boundaries(){

	delete[] this->boundaries;

}

template <class T_val>
int Binned_Boundaries<T_val>::num_assigned_segms() {

	int extra = 0;

	if (this->out_range_mode) {
		extra = 2;
	}

	return this->num_regular_segms + extra;

}


template <class T_val>
ret_segm_info Binned_Boundaries<T_val>::assign_segm_num(T_val ival) {

	ret_segm_info ret;

	ret.segm_num =
			closest_limit_value_in_sorted_get_idx<T_val>(
					this->boundaries, this->num_boundaries, ival, 'h');

	if (ret.segm_num < 0){
		ret.out_range_flag = -1;

		if (this->out_range_mode) {
			ret.out_range_discard_flag = 0;
			ret.segm_num = -1; // +1 later
		} else {
			ret.out_range_discard_flag = -1;
		}

	} else if (ret.segm_num >= this->num_regular_segms){
		ret.out_range_flag = 1;

		if (this->out_range_mode) {
			ret.out_range_discard_flag = 0;
			ret.segm_num = this->num_regular_segms;
		}
		else {
			ret.out_range_discard_flag = 1;
		}

	}
	else {
		ret.out_range_flag = 0;
		ret.out_range_discard_flag = 0;
	}

	if(this->out_range_mode)
		ret.segm_num += 1; // <-- Shifts segment numbers


	return ret;

}


template <class T_val>
ret_range_info<T_val> Binned_Boundaries<T_val>::range_given_segm_num(int isegm_num){

	ret_range_info<T_val> ret;

	ret.segm_num = isegm_num;

	if(this->out_range_mode){
		if(isegm_num <= 0){
			ret.range_l = this->boundaries[ 0 ];
			ret.range_h = this->boundaries[ 0 ];
			ret.range_l_disp = ret.range_l;
			ret.out_range_flag = -1;
			if(isegm_num < 0)
				ret.out_range_discard_flag = -1;
			else
				ret.out_range_discard_flag = 0;
		}
		else if (isegm_num >= this->num_regular_segms + 1){
			ret.range_l = this->boundaries[ this->num_boundaries - 1 ];
			ret.range_h = this->boundaries[ this->num_boundaries - 1 ];
			ret.range_l_disp = ret.range_h;
			ret.out_range_flag = 1;
			if(isegm_num >= this->num_assigned_segms())
				ret.out_range_discard_flag = 1;
			else
				ret.out_range_discard_flag = 0;
		}
		else {
			ret.range_l = this->boundaries[ isegm_num - 1 ];
			ret.range_h = this->boundaries[ isegm_num ];
			ret.range_l_disp = ret.range_l;
			ret.out_range_flag = 0;
			ret.out_range_discard_flag = 0;
		}

	} else {
		if (isegm_num < 0){
			ret.range_l = this->boundaries[ 0 ];
			ret.range_h = this->boundaries[ 0 ];
			ret.range_l_disp = ret.range_l;
			ret.out_range_flag = -1;
			ret.out_range_discard_flag = -1;

		} else if(isegm_num >= this->num_regular_segms){
			ret.range_l = this->boundaries[ this->num_boundaries - 1 ];
			ret.range_h = this->boundaries[ this->num_boundaries - 1 ];
			ret.range_l_disp = ret.range_h;
			ret.out_range_flag = 1;
			ret.out_range_discard_flag = 1;

		} else {
			ret.range_l = this->boundaries[ isegm_num ];
			ret.range_h = this->boundaries[ isegm_num + 1 ];
			ret.range_l_disp = ret.range_l;
			ret.out_range_flag = 0;
			ret.out_range_discard_flag = 0;

		}

	}

	return ret;

}


template <class T_val>
ret_range_info<T_val> Binned_Boundaries<T_val>::range_assigned_segm(T_val ival){

	ret_segm_info segm_info = this->assign_segm_num(ival);
	return this->range_given_segm_num(segm_info.segm_num);

}


template <class T_val>
Binned_EqSegmsLen<T_val>::Binned_EqSegmsLen(T_val irange_l, T_val irange_h, int inum_segms, int iout_range_mode){

	this->range_l = irange_l;
	this->range_h = irange_h;
	this->num_segms = inum_segms;

	this->out_range_mode = iout_range_mode;

}


template <class T_val>
ret_segm_info Binned_EqSegmsLen<T_val>::assign_segm_num(T_val ival) {

	ret_segm_info ret;

	ret.segm_num = int((ival - this->range_l) / (this->range_h - this->range_l) * this->num_segms);

	if (ret.segm_num < 0){
		ret.out_range_flag = -1;

		if (this->out_range_mode) {
			ret.out_range_discard_flag = 0;
			ret.segm_num = -1; // +1 later
		} else {
			ret.out_range_discard_flag = -1;
		}

	} else if (ret.segm_num >= this->num_segms){
		ret.out_range_flag = 1;

		if (this->out_range_mode) {
			ret.out_range_discard_flag = 0;
			ret.segm_num = this->num_segms;
		}
		else {
			ret.out_range_discard_flag = 1;
		}

	}
	else {
		ret.out_range_flag = 0;
		ret.out_range_discard_flag = 0;
	}

	if(this->out_range_mode)
		ret.segm_num ++;

	return ret;

}

template <class T_val>
T_val Binned_EqSegmsLen<T_val>::segm_width(){

	return (this->range_h - this->range_l) / this->num_segms;

}


template <class T_val>
ret_range_info<T_val> Binned_EqSegmsLen<T_val>::range_given_segm_num(int isegm_num){

	ret_range_info<T_val> ret;

	if(this->out_range_mode){
		if(isegm_num <= 0){
			ret.out_range_flag = -1;
			ret.range_l = this->range_l + this->segm_width() * 0;
			ret.range_h = this->range_l + this->segm_width() * 1;
			ret.range_l_disp = ret.range_l;
		}
		else if (isegm_num >= this->num_segms + 1){
			ret.out_range_flag = 1;
			ret.range_l = this->range_h - this->segm_width();
			ret.range_h = this->range_h;
			ret.range_l_disp = this->range_h;
		}
		else {
			ret.out_range_flag = 0;
			ret.range_l = this->range_l + this->segm_width() * (isegm_num - 1);
			ret.range_h = this->range_l + this->segm_width() * isegm_num;
			ret.range_l_disp = ret.range_l;
		}

		if(isegm_num < 0)
			ret.out_range_discard_flag = -1;
		else if(isegm_num >= this->num_assigned_segms())
			ret.out_range_discard_flag = 1;

	} else {

		ret.range_l = this->range_l + this->segm_width() * isegm_num;
		ret.range_h = this->range_l + this->segm_width() * (isegm_num + 1);
		ret.range_l_disp = ret.range_l;

		if (isegm_num < 0){
			ret.out_range_flag = -1;
			ret.out_range_discard_flag = -1;
		} else if(isegm_num >= this->num_segms){
			ret.out_range_flag = 1;
			ret.out_range_discard_flag = 1;
		} else {
			ret.out_range_flag = 0;
			ret.out_range_discard_flag = 0;
		}

	}

	return ret;

}

template <class T_val>
int Binned_EqSegmsLen<T_val>::num_assigned_segms() {

	int extra = 0;

	if (this->out_range_mode) {
		extra = 2;
	}

	return this->num_segms + extra;

}

template class Binned_Boundaries<float>;
template class Binned_Boundaries<double>;

template class Binned_EqSegmsLen<float>;
template class Binned_EqSegmsLen<double>;

