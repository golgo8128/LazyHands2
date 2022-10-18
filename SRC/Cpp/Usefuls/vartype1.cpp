
#include <iostream>
#include <typeinfo>
#include <string.h>
#include "Exceptions/rsMHandsExcept1.h"
#include "Usefuls/vartype1.h"

using namespace std;

static char vartype_errmsg[ VARTYPE_MAX_ERRMSG_LEN ];

char get_vartype_from_typename(const char *itypename){

	char oret;

	if(strcmp(itypename, "c") == 0 || strcmp(itypename, "char") == 0){
		oret = 'c';
	} else if (strcmp(itypename, "h") == 0 || strcmp(itypename, "unsigned char") == 0){
		oret = 'h';
	} else if (strcmp(itypename, "i") == 0 || strcmp(itypename, "int") == 0){
		oret = 'i';
	} else if (strcmp(itypename, "j") == 0 || strcmp(itypename, "unsigned int") == 0){
		oret = 'j';
	} else if (strcmp(itypename, "x") == 0 || strcmp(itypename, "__int64") == 0 ||
			strcmp(itypename, "long long") == 0){
		oret = 'x';
	} else if (strcmp(itypename, "y") == 0 || strcmp(itypename, "unsigned __int64") == 0 ||
			strcmp(itypename, "unsigned long long") == 0){
		oret = 'y';
	} else if (strcmp(itypename, "f") == 0 || strcmp(itypename, "float") == 0){
		oret = 'f';
	} else if (strcmp(itypename, "d") == 0 || strcmp(itypename, "double") == 0){
		oret = 'd';
	} else {

#ifdef _MSC_VER
		sprintf_s(vartype_errmsg, VARTYPE_MAX_ERRMSG_LEN, "Unrecognized data type: %s", itypename);
#else
		sprintf(vartype_errmsg, "Unrecognized data type: %s", itypename);
#endif

		throw rsMHandsExcept(vartype_errmsg);
	}

	return oret;


}
