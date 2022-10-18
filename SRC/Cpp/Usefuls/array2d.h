

template <class T_val, class T_label_m, class T_label_n>
struct rsarray2d {

	T_val **array2d;
	int len_m;
	int len_n;
	T_label_m *labels_m;
	T_label_n *labels_n;

};


template <class T> T **init_array2d(int, int, T);
template <class T> void del_array2d(T*[], int, int);

template <class T_val>
   void display_array2d(T_val *[], int, int);

template <class T_val, class T_label_m, class T_label_n>
   void display_array2d(T_val *[], int, int, T_label_m[], T_label_n[]);

template <class T_val>
   void write_array2d(const char*, T_val* [], int, int);

template <class T_val, class T_label_m, class T_label_n>
   void write_array2d(const char*, T_val* [], int, int, T_label_m[], T_label_n[]);

template <class T_val, class T_label_m, class T_label_n>
rsarray2d<T_val, double, double> conv_to_eq_intervals_2d(
	T_val* iarray2d[], int len_m, int len_n,
	T_label_m label_m[], T_label_n label_n[]);

template <class T>
	void smooth_triang_simple(T *[], int, int, double, double, double *[]);
