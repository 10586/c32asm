#include <string>
#include <vector>
#include <iostream>
#include <cstdlib>
#include "ast.h"
#include "config.h"

char* itoa(int val, int base=10){
	
	static char buf[32] = {0};
	
	int i = 30;
	
	for(; val && i ; --i, val /= base)
	
		buf[i] = "0123456789abcdef"[val % base];
	
	return &buf[i+1];
	
}

string PointerTypeNode::toString()
{
	return "pointer to " + targetType->toString();
}

int64_t PointerTypeNode::getStorageSize()
{
	return MACH_PTR_SIZE;
}

string ArrayTypeNode::toString()
{
	return string("array[") + string(itoa(memberCount)) + string("] of ") + 
		memberType->toString();
}

int64_t ArrayTypeNode::getStorageSize()
{
	return memberCount * memberType->getStorageSize();
}

string BuiltinTypeNode::toString()
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

void BuiltinTypeNode::enlargen()
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

void BuiltinTypeNode::shrink()
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

void BuiltinTypeNode::makeSigned()
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

void BuiltinTypeNode::makeUnsigned()
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
