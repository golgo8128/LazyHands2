/*
 * Feat2DSpace1.cpp
 *
 *  Created on: 2022/05/19
 *      Author: rsaito
 */

#include <iostream>
#include <fstream>
#include <boost/filesystem.hpp>
#include <Usefuls/Feat2DSpace1.h>
#include <Usefuls/Binned1.h>

#include "Usefuls/rsBinaryDat1.h"

using namespace std;


template <class T_m, class T_n, class T_val>
Feat2DSpace_EqSegmsLen<T_m, T_n, T_val>::Feat2DSpace_EqSegmsLen(
	T_m irange_l_m, T_m irange_h_m, int inum_segms_m, int iout_range_mode_m,
	T_n irange_l_n, T_n irange_h_n, int inum_segms_n, int iout_range_mode_n,
	T_val iinit_val) {
	// TODO Auto-generated constructor stub

	this->binned_m =
		new Binned_EqSegmsLen<T_m>(irange_l_m, irange_h_m, inum_segms_m, iout_range_mode_m);
	this->binned_n =
		new Binned_EqSegmsLen<T_n>(irange_l_n, irange_h_n, inum_segms_n, iout_range_mode_n);

	this->feat2d = new T_val *[ this->binned_m->num_assigned_segms() ];
	for (int i = 0; i < this->binned_m->num_assigned_segms(); i++) {

		this->feat2d[i] = new T_val[this->binned_n->num_assigned_segms()];
		fill_n(this->feat2d[i], this->binned_n->num_assigned_segms(), iinit_val);

	}

}

template <class T_m, class T_n, class T_val>
Feat2DSpace_EqSegmsLen<T_m, T_n, T_val>::~Feat2DSpace_EqSegmsLen() {
	// TODO Auto-generated destructor stub

	for (int i = 0; i < this->binned_m->num_assigned_segms(); i++)
		delete[] this->feat2d[i];
	delete[] this->feat2d;

	cout << "2D feature space released." << endl;

}


template <class T_m, class T_n, class T_val>
int Feat2DSpace_EqSegmsLen<T_m, T_n, T_val>::map_to_2d_evalmax(T_m ixval, T_n iyval, T_val ival) {

	int ret_val;

	ret_segm_info x_segm_info = this->binned_m->assign_segm_num(ixval);
	ret_segm_info y_segm_info = this->binned_n->assign_segm_num(iyval);

	if (x_segm_info.out_range_discard_flag ||
		y_segm_info.out_range_discard_flag) {
		ret_val = 0;
	}
	else {

		T_val reg_val = this->feat2d[ x_segm_info.segm_num ][ y_segm_info.segm_num ];

		if (reg_val < ival) {
			this->feat2d[x_segm_info.segm_num][y_segm_info.segm_num] = ival;
			ret_val = 1;
		}
		else {
			ret_val = 0;
		}
	}

	return ret_val;

}

template <class T_m, class T_n, class T_val>
void Feat2DSpace_EqSegmsLen<T_m, T_n, T_val>::output_2dmap(){

	cout << "\t";

	for(int j = 0;j < this->binned_n->num_assigned_segms();j ++){

		ret_range_info<T_n> rinfo = this->binned_n->range_given_segm_num(j);

		if (rinfo.out_range_flag < 0)
			cout << "<";
		else if(rinfo.out_range_flag > 0)
			cout << ">=";

		cout << this->binned_n->range_given_segm_num(j).range_l_disp;
		if(j < this->binned_n->num_assigned_segms() - 1)
			cout << '\t';
	}
	cout << endl;

	for(int i = 0;i < this->binned_m->num_assigned_segms();i ++){

		ret_range_info<T_m> rinfo = this->binned_m->range_given_segm_num(i);

		if (rinfo.out_range_flag < 0)
			cout << "<";
		else if(rinfo.out_range_flag > 0)
			cout << ">=";

		cout << this->binned_m->range_given_segm_num(i).range_l_disp << '\t';

		for(int j = 0;j < this->binned_n->num_assigned_segms();j ++){
			cout << this->feat2d[ i ][ j ];
			if(j < this->binned_n->num_assigned_segms() - 1)
				cout << '\t';
		}
		cout << endl;
	}

}

template <class T_m, class T_n, class T_val>
void Feat2DSpace_EqSegmsLen<T_m, T_n, T_val>::write_2dmap(
		const char *opath,
		int foffset_byte_size){

	int len_m = this->binned_m->num_assigned_segms();
	int len_n = this->binned_n->num_assigned_segms();

	T_m *range_ls_m = new T_m[len_m];
	for (int i = 0; i < len_m; i++) {
		T_m range_l = this->binned_m->range_given_segm_num(i).range_l;
		range_ls_m[i] = range_l;
	}

	T_n *range_ls_n = new T_n[len_n];
	for (int j = 0; j < len_n; j++) {
		T_n range_l = this->binned_n->range_given_segm_num(j).range_l;
		range_ls_n[j] = range_l;
	}

	rsBinaryDat::write_2dmap<T_m, T_n, T_val, unsigned int>(
		opath,
		range_ls_m, len_m, // Number of assigned segments
		range_ls_n, len_n, // Number of assigned segments
		this->feat2d,
		foffset_byte_size);

	delete[] range_ls_m;
	delete[] range_ls_n;

	/*

	boost::filesystem::path parentdir = boost::filesystem::path(opath).parent_path();
	boost::filesystem::create_directory(parentdir);

	std::ofstream fw;
	fw.open(opath, ios::out | ios::binary);

	write_foffset(fw, foffset_byte_size); // namespace O.K?

	fw.write(reinterpret_cast<const char*>(&len_m), sizeof(int));
	fw.write(reinterpret_cast<const char*>(&len_n), sizeof(int));

	for(int i = 0;i < len_m;i ++){
		T_m range_l = this->binned_m->range_given_segm_num(i).range_l;
		fw.write(reinterpret_cast<const char*>(&range_l), sizeof(T_m));
	}
	for(int j = 0;j < len_n;j ++){
		T_n range_l = this->binned_n->range_given_segm_num(j).range_l;
		fw.write(reinterpret_cast<const char*>(&range_l), sizeof(T_n));
	}

	for(int i = 0;i < len_m;i ++)
		for(int j = 0;j < len_n;j ++){
			T_val val = this->feat2d[ i ][ j ];
			fw.write(reinterpret_cast<const char*>(&val), sizeof(T_val));
		}

	fw.close();

	*/

}


template class Feat2DSpace_EqSegmsLen<float, float, float>;
template class Feat2DSpace_EqSegmsLen<float, float, int>;
template class Feat2DSpace_EqSegmsLen<double, float, int>;
template class Feat2DSpace_EqSegmsLen<float, float, double>;
