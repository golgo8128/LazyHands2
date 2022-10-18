
#include <list>

using namespace std;

template <class T>
T *list_to_allocated_array(list<T>ilist){

	T *oarray = new T[ ilist.size() ];
	int i = 0;
	for(T cval: ilist)
		oarray[i ++ ] = cval;

	return oarray;

}

template <class Tin, class Tout>
Tout *list_to_allocated_array_tconv(list<Tin>ilist){

	Tout *oarray = new Tout[ ilist.size() ];
	int i = 0;
	for(Tin cval: ilist)
		oarray[i ++ ] = (Tout)cval;

	return oarray;

}


template int *list_to_allocated_array(list<int>);
template float *list_to_allocated_array(list<float>);
template double *list_to_allocated_array(list<double>);

template double *list_to_allocated_array_tconv(list<float>);
template double *list_to_allocated_array_tconv(list<double>);
template double *list_to_allocated_array_tconv(list<int>);
//template list_to_allocated_array<float, double>;

