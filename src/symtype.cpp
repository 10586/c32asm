#include <string>
#include <vector>
#include <iostream>
#include <cstdlib>
#include "type.h"
#include "config.h"

char* itoa(int val, int base=10){
	
	static char buf[32] = {0};
	
	int i = 30;
	
	for(; val && i ; --i, val /= base)
	
		buf[i] = "0123456789abcdef"[val % base];
	
	return &buf[i+1];
	
}

PointerType::PointerType(const PointerType &Orig) {
	targetType = Orig.targetType->clone();
};

PointerType & PointerType::operator=(const PointerType &Orig) {
	if (this == &Orig)
        	return *this;
	delete targetType;
	targetType = Orig.targetType->clone();
	return *this;
};

Type *PointerType::clone()
{
	return new PointerType(*this);
}

string PointerType::toString()
{
	return "pointer to " + targetType->toString();
}

int64_t PointerType::getStorageSize()
{
	return MACH_PTR_SIZE;
}

ArrayType::ArrayType(const ArrayType &Orig) {
	memberType = Orig.memberType->clone();
};

ArrayType & ArrayType::operator=(const ArrayType &Orig) {
	if (this == &Orig)
        	return *this;
	delete memberType;
	memberType = Orig.memberType->clone();
	memberCount = Orig.memberCount;
	return *this;
};

Type *ArrayType::clone()
{
	return new ArrayType(*this);
}

string ArrayType::toString()
{
	return string("array[") + string(itoa(memberCount)) + string("] of ") + 
		memberType->toString();
}

int64_t ArrayType::getStorageSize()
{
	return memberCount * memberType->getStorageSize();
}

Type *BuiltinType::clone()
{
	return new BuiltinType(*this);
}

string BuiltinType::toString()
{
	return string(isSigned ? "signed" : "unsigned") + 
		string(isFloat ? "float" : "integer") + 
		string(" type with width ") + string(itoa(width));
}

void ambiguousTypeSizeSpec()
{
	cerr << "ambiguous type size specified.\n";
	exit(EXIT_FAILURE);
}

void floatModifierSpec()
{
	cerr << "tried to modify a floating point type.\n";
	exit(EXIT_FAILURE);
}

void BuiltinType::enlargen()
{
	if (isShrunk) {
		ambiguousTypeSizeSpec();
		return;
	} else if (isFloat) {
		floatModifierSpec();
		return;
	} else if (isLongInt) {
		if (width == 32) {
			width *= 2;
			return;
		} else {
			ambiguousTypeSizeSpec();
			return;
		}
	} else if (width == 32) {
		isLongInt = true;
	} else {
		cerr << "long must only be applied to base type \"int\".\n";
		exit(EXIT_FAILURE);
	}
}

void BuiltinType::shrink()
{
	if (isShrunk || isLongInt) {
		ambiguousTypeSizeSpec();
	} else if (isFloat) {
		floatModifierSpec();
	} else if (width == 32) {
		width /= 2;
		isShrunk = true;
	} else {
		cerr << "short must only be applied to base type \"int\".\n";
		exit(EXIT_FAILURE);
	}
}

void ambiguousTypeSignSpec()
{
	cerr << "ambiguous type signedness specified.\n";
}

void BuiltinType::makeSigned()
{
	if (hasSignChanged) {
		ambiguousTypeSizeSpec();
	} else if (isFloat) {
		floatModifierSpec();
	} else {
		isSigned = true;
		hasSignChanged = true;
	}
}

void BuiltinType::makeUnsigned()
{
	if (hasSignChanged) {
		ambiguousTypeSizeSpec();
	} else if (isFloat) {
		floatModifierSpec();
	} else {
		isSigned = false;
		hasSignChanged = true;
	}
}
