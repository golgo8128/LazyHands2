/*
 * closest_value_in_sorted1.cpp
 *
 *  Created on: 2022/06/21
 *      Author: rsaito
 */

// #include <iostream>
#include <stdio.h>
#include <string.h>
#include "Exceptions/rsMHandsExcept1.h"

// using namespace std;

template <class T>
int closest_value_in_sorted_get_idx(T iarr_sorted[], int iarr_length, T itarget_val){
    // Array with redundant values not tested.

    if(iarr_length == 0)
    	throw rsMHandsExcept("Given array for finding closest value empty.");

    int l_idx = 0;
    int h_idx = iarr_length - 1;

    int m_idx = int((l_idx + h_idx) / 2);
    T m_val = iarr_sorted[m_idx];

    while(l_idx + 1 < h_idx){

    	/*
        printf("%lf(%d) %lf(%d) %lf(%d)\n",
        		(double)iarr_sorted[ l_idx ], l_idx,
				(double)iarr_sorted[ m_idx ], m_idx,
				(double)iarr_sorted[ h_idx ], h_idx);
    	*/

    	if(itarget_val == m_val)
    		break;
    	else if(itarget_val < m_val)
    		h_idx = m_idx;
    	else
    		l_idx = m_idx;

        m_idx = int((l_idx + h_idx) / 2);
        m_val = iarr_sorted[m_idx];

    }

    /*
    printf("%lf(%d) %lf(%d) %lf(%d)\n",
    		(double)iarr_sorted[ l_idx ], l_idx,
			(double)iarr_sorted[ m_idx ], m_idx,
			(double)iarr_sorted[ h_idx ], h_idx);
     */

    int oidx;
     if(itarget_val == m_val)
         oidx = m_idx;
     else if(iarr_sorted[ h_idx ] - itarget_val < itarget_val - iarr_sorted[ l_idx ])
         oidx = h_idx;
     else
         oidx = l_idx;

     return oidx;

}

template <class T>
int closest_limit_value_in_sorted_get_idx(T iarr_sorted[], int iarr_length, T itarget_val,
		char limit_type){
	/*
    limit_type = "high" ... Constraint: selected value <  itarget_val
    limit_type = "low"  ... Constraint: selected value >= itarget_val

    Array with redundant values not tested.
	*/

    int closest_idx = closest_value_in_sorted_get_idx<T>(iarr_sorted, iarr_length, itarget_val);
    T closest_val = iarr_sorted[ closest_idx ];

    if(limit_type == 'h'){
        if(closest_val >= itarget_val){
            if(closest_idx > 0)closest_idx -= 1;
            else closest_idx = -1;
        }
    }
    else if(limit_type == 'l'){
        if(closest_val < itarget_val){
            if(closest_idx < iarr_length - 1)closest_idx += 1;
            else closest_idx = -1;
        }
    }
    else {
    	static char errmes[30];
#ifdef _MSC_VER
    	sprintf_s(errmes, "Illegal limit_type: '%c'", limit_type);
#else
        sprintf(errmes, "Illegal limit_type: '%c'", limit_type);
#endif
        throw rsMHandsExcept(errmes);
    }

    // closest_val NOT updated

    return closest_idx;

}


template int closest_value_in_sorted_get_idx<double>(double[], int, double);
template int closest_value_in_sorted_get_idx<float>(float[], int, float);

template int closest_limit_value_in_sorted_get_idx<double>(double[], int, double, char);
template int closest_limit_value_in_sorted_get_idx<float>(float[], int, float, char);



