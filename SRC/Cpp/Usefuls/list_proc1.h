
#include <list>

using namespace std;

template <class T>T *list_to_allocated_array(list<T>);
template <class Tin, class Tout>Tout *list_to_allocated_array_tconv(list<Tin>);
