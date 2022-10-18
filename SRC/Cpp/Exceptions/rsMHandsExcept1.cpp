#include "Exceptions/rsMHandsExcept1.h"
#include <string.h>


rsMHandsExcept::rsMHandsExcept(const char imsg[]) {

	this->msg = new char[strlen(imsg) + 1]; // +1 is for '\0'
#ifdef _MSC_VER
	strcpy_s(this->msg, strlen(imsg) + 1, imsg);
#else
	strcpy(this->msg, imsg);
#endif

}

char *rsMHandsExcept::get_msg() {

	return this->msg;

}
