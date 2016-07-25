
#ifndef _LXZALLOC_H
#define _LXZALLOC_H

#include "ICGui.h"

struct DLL_CLASS ILXZAlloc
{
	virtual char* buf() = 0;
	virtual char* grow(unsigned int len) = 0;
	virtual int   size() = 0;
	virtual void  release() = 0;		
	virtual void  destroy() = 0;
};
typedef void(*fnCallSystemAPI)(const char* param, ILXZAlloc* ret);
#endif

