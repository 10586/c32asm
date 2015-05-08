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

class TypeNode {
public:
        TypeQualifierList       qualifiers;
        TypeNode(TypeQualifierList &quals): qualifiers(quals) {};
        TypeNode() {};
        virtual int64_t         getStorageSize() =0;
        virtual string          toString()=0;
        virtual ~TypeNode() {};
};

class BaseTypeNode : public TypeNode {
public:
        virtual void            enlargen() =0;
        virtual void            shrink() =0;
        virtual void            makeSigned() =0;
        virtual void            makeUnsigned() =0;
        virtual string          toString()=0;
        BaseTypeNode(TypeQualifierList &qls): TypeNode(qls) {};
        virtual ~BaseTypeNode() {};
};

class PointerTypeNode : public TypeNode {//IMPL: symtype.cpp
public:
        TypeNode                *targetType;
        PointerTypeNode(TypeQualifierList &qls, TypeNode *trg):
                                TypeNode(qls),
                                targetType(trg) {};
        virtual int64_t          getStorageSize();
        virtual string          toString();
        virtual ~PointerTypeNode() {
                delete targetType;
        };
};

class ArrayTypeNode : public TypeNode {
public:
        TypeNode                *memberType;
        int64_t                  memberCount;
        virtual int64_t          getStorageSize();
        virtual string          toString();
        ArrayTypeNode(TypeNode *mt, int64_t mc):
                                memberType(mt), memberCount(mc) {};
        virtual ~ArrayTypeNode() {
                delete memberType;
        }
};

class BuiltinTypeNode : public BaseTypeNode {
private:
        bool                    isLongInt;
        bool                    isShrunk;
        bool                    hasSignChanged;
public:
        int                     width;
        bool                    isFloat;
        bool                    isSigned;
        virtual string          toString();

        virtual ~BuiltinTypeNode() {};
        BuiltinTypeNode(TypeQualifierList &qls, int wd, bool flt, bool sgn):
                BaseTypeNode(qls),
                width(wd), isFloat(flt), isSigned(sgn),
                isLongInt(false), isShrunk(false),
                hasSignChanged(false) {};
        BuiltinTypeNode(TypeQualifierList &qls, int wd, bool flt):
                BaseTypeNode(qls),
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
