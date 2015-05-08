#ifndef __value_h__
#define __value_h__

#include "eval.h"
#include "type.h"
#include <vector>
#include <string>

class Value {
public:
	Type			*type;
	virtual bool		 isConstant() =0;
	virtual int64_t		 toInteger()  =0;
	virtual string		 toString()   =0;
	virtual Value		 evaluate(Operation op, Value &a, Value &b) =0;
	virtual Value		 evaluate(Operation op, Value &a) =0;
	virtual Value		 generate(Operation op, Value &a, Value &b) =0;
	virtual Value		 generate(Operation op, Value &a) =0;
}

#endif
