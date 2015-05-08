#ifndef __type_h__
#define __type_h__
#include <vector>
#include <string>
#include <stdint.h>
#ifndef nullptr
#define nullptr (0)
#endif

using namespace std;

typedef enum {
        TQ_CONST,
        TQ_VOLATILE
} TypeQualifier;

typedef vector<TypeQualifier>                   TypeQualifierList;

class Type {
public:
        TypeQualifierList       qualifiers;
        Type(TypeQualifierList &quals): qualifiers(quals) {};
        Type() {};
	virtual Type		*clone() =0;
	virtual int64_t          getStorageSize() =0;
        virtual string           toString()=0;
        virtual ~Type() {};
};

class BaseType : public Type {
public:
        virtual void             enlargen() =0;
        virtual void             shrink() =0;
        virtual void             makeSigned() =0;
        virtual void             makeUnsigned() =0;
        virtual string           toString() =0;
	virtual	Type		*clone() =0;
        BaseType(TypeQualifierList &qls): Type(qls) {};
        virtual ~BaseType() {};
};

class PointerType : public Type {//IMPL: symtype.cpp
public:
        Type			*targetType;
	virtual Type		*clone();
        PointerType(TypeQualifierList &qls, Type &trg):
                                Type(qls),
                                targetType(trg.clone()) {};
        virtual int64_t          getStorageSize();
        virtual string          toString();
	PointerType(const PointerType &Orig );
	PointerType & operator=(const PointerType & Orig);
        virtual ~PointerType() {
		delete targetType;
	};
};

class ArrayType : public Type {
public:
        Type			*memberType;
	virtual Type		*clone();
        int64_t                  memberCount;
        virtual int64_t          getStorageSize();
        virtual string           toString();
	ArrayType(const ArrayType &Orig);
	ArrayType & operator=(const ArrayType & Orig);
        ArrayType(Type &mt, int64_t mc):
		memberType(mt.clone()), memberCount(mc) {};
        virtual ~ArrayType() {
		delete memberType;
	};
};

class BuiltinType : public BaseType {
private:
        bool                     isLongInt;
        bool                     isShrunk;
        bool                     hasSignChanged;
public:
        int                      width;
        bool                     isFloat;
        bool                     isSigned;
        virtual string           toString();
	virtual Type		*clone();
        virtual ~BuiltinType() {};
        BuiltinType(TypeQualifierList &qls, int wd, bool flt, bool sgn):
                BaseType(qls),
                width(wd), isFloat(flt), isSigned(sgn),
                isLongInt(false), isShrunk(false),
                hasSignChanged(false) {};
        BuiltinType(TypeQualifierList &qls, int wd, bool flt):
                BaseType(qls),
                width(wd), isFloat(flt), isSigned(true),
                isLongInt(false), isShrunk(false),
	        hasSignChanged(false) {};
        virtual void            enlargen();
        virtual void            shrink();
        virtual void            makeSigned();
        virtual void            makeUnsigned();
        virtual int64_t         getStorageSize() { return width; };
};

#endif
