#include <vector>
#include <string>
#include <stdint.h>

#ifndef __ast_h__
#define __ast_h__
#define nullptr (0)

#include "type.h"

using namespace std;

typedef enum {
	ident_sym,	//_foo_
	num_const,	// number constant (123,0123,0x123,'a')
	str_const,	// string constant ("string string string")
	vunary_op,	//<foo><op> , <op><foo> , <op>(<foo>)
	tunary_op,	//<op>(<type>)
	index_op,	//<foo>[<bar>]
	vmember_sym,	//<foo>._bar_
	pmember_sym,	//<foo>->_bar_
	fcall,		//<foo>(argumentlist)
	arg_list,	//no parameters, wraps a list	
	cast_op,	//(<type>)<foo>
	binary_op,	//<foo><op><bar>
	assignment_op,	//<foo><ass.op><bar>
	declaration,	//<specifiers><declarators>
	decl_name,	//_foo_
	ptr_decl,	//*<declarator>
	dir_decl,	//<declarator>
	func_decl,	//<declarator>( <argtypelist>  ) or <declarator>( <argnamelist> )
	array_decl,	//<declarator>[<const>] or <declarator>[]
	ptr_spec,	//*[const][volatile][<ptr_spec>]
} ast_type;

typedef enum {
	SC_TYPEDEF,
	SC_EXTERN,
	SC_STATIC,
	SC_AUTO,
	SC_REGISTER
} StorageClassSpecifier;

typedef enum {
	TS_VOID,
	TS_CHAR,
	TS_SHORT,
	TS_INT,
	TS_LONG,
	TS_FLOAT,
	TS_DOUBLE,
	TS_SIGNED,
	TS_UNSIGNED,
} TypeSpecifier;

class DeclarationSpecASTNode;
class DeclaratorASTNode;
class TypeSpecNode;

typedef vector<TypeSpecNode *>			TypeSpecList;
typedef vector<StorageClassSpecifier>		StorageClassList;
typedef vector<DeclarationSpecASTNode *>	DeclarationSpecList;
typedef vector<DeclaratorASTNode *>		DeclaratorList;

class Symbol {};

class ASTNode {
public:
	virtual ~ASTNode() {};
};

class ExpressionASTNode : public ASTNode {
public:
	virtual 		~ExpressionASTNode(){};
	virtual Value		*evaluate() =0;
	virtual Value		*generate() =0;
};

class ReferenceASTNode : public ExpressionASTNode {
public:
	Symbol referencedSymbol;
	virtual ~ReferenceASTNode(){};
	ReferenceASTNode(string &name){};
	virtual Value		*evaluate();//IMPL: astcore.cpp
	virtual	Value		*generate();
};

class IntegerASTNode : public ExpressionASTNode {
public:
	string value;
	virtual Value		*evaluate();//IMPL: asteval.cpp
	virtual Value		*generate();
	IntegerASTNode(string val):
		value(val) {};
	virtual ~IntegerASTNode() {};
};

class StringASTNode : public ExpressionASTNode {
public:
	string value;
	StringASTNode(string &val): value(val){}
	virtual Value		*evaluate();
	virtual Value		*generate();
	virtual ~StringASTNode() {};
};

class UnaryExpression : public ExpressionASTNode {
public:
	ExpressionASTNode	*inner;
	Operation		 operation;
	virtual Value		*generate();
	virtual Value		*evaluate();
	UnaryExpression(Operation op, ExpressionASTNode *in):
		operation(op), inner(in) {};
	virtual ~UnaryExpression() {
		delete inner;
	};
}

class MemberReferenceExpression : public ExpressionASTNode {
public:
	bool			 pointer;
	ExpressionASTNode	*parent;
	string			 name;
	MemberReferenceExpression(bool ptr, ExpressionASTNode *par, string &nm):
		pointer(ptr), parent(par), name(nm) {};
}

class InfixExpression : public ExpressionASTNode {
public:
	ExpressionASTNode	*lefthand;
	ExpressionASTNode	*righthand;
	Operation		 operation;
	virtual Value		*generate();
	virtual Value		*evaluate();
	InfixExpression(Operation op, ExpressionASTNode *lhs, ExpressionASTNode *rhs):
		operation(op), lefthand(lhs), righthand(rhs) {};
	virtual ~InfixExpression() {
		delete lefthand;
		delete righthand;
	};
}

class DeclarationASTNode : public ASTNode {
private:
	bool			 declSpecAdded;
	BaseType		*baseType;
	void			 addDeclarationSpecifiers( void );
public:
	DeclarationSpecList	*specifiers;
	DeclaratorList		*declarators;
	TypeSpecList		 typeSpecifiers;
	TypeQualifierList	 typeQualifiers;
	StorageClassList	 storageClasses;
	BaseType		*getBaseType( void );
	void			 declareSymbols();
	virtual ~DeclarationASTNode();
	DeclarationASTNode(DeclarationSpecList *sp, DeclaratorList *dc):
		specifiers(sp), declarators(dc),
		baseType(nullptr), declSpecAdded(false) {};
};

class DeclarationSpecASTNode : public ASTNode {
public:
	virtual void		addToDeclaration(DeclarationASTNode &decl) =0;
	virtual ~DeclarationSpecASTNode() {};
};

class StorageClassNode : public DeclarationSpecASTNode {
public:
	StorageClassSpecifier	storageClass;
	virtual void		addToDeclaration(DeclarationASTNode &decl);
	virtual ~StorageClassNode() {};
	StorageClassNode(StorageClassSpecifier sc):
		storageClass(sc) {};
};

class TypeQualifierNode : public DeclarationSpecASTNode {
public:
	TypeQualifier		typeQualifier;
	virtual void		addToDeclaration(DeclarationASTNode &decl);
	virtual ~TypeQualifierNode() {};
	TypeQualifierNode(TypeQualifier tq):
		typeQualifier(tq) {};
};

class TypeSpecNode : public DeclarationSpecASTNode {//IMPL: astdecl.cpp
public:
	virtual TypeSpecNode	*clone ( void ) =0;
	virtual	bool		 isRootType( void ) =0;
	virtual void		 addToDeclaration(DeclarationASTNode &decl);
	virtual BaseType	*getType( BaseType* OldType, 
					  TypeQualifierList &Quals ) =0;
	virtual ~TypeSpecNode()  {};
};

class NamedTypeSpecNode : public TypeSpecNode {//IMPL: astdecl.cpp
public:
	string			typeName;
	virtual TypeSpecNode	*clone ( void );
	virtual	bool		isRootType( void ) { return true; }
	virtual BaseType	*getType( BaseType* OldType, 
					  TypeQualifierList &Quals );
	virtual			~NamedTypeSpecNode() {};
				 NamedTypeSpecNode(string name): 
					typeName(name) {};		
};

class BuiltinTypeSpecNode : public TypeSpecNode {//IMPL: astdecl.cpp
public:
	TypeSpecifier		specifier;
	virtual TypeSpecNode	*clone ( void );
	virtual	bool		isRootType( void );
	virtual BaseType	*getType( BaseType* OldType, 
					  TypeQualifierList &Quals );
	virtual 		~BuiltinTypeSpecNode() {};
				 BuiltinTypeSpecNode(TypeSpecifier spec):
					 specifier(spec) {};		
};

class PointerSpecASTNode;

class PointerSpecASTNode : public ASTNode {//IMPL: astdecl.cpp
public:
	TypeQualifierList	*qualifiers;
	PointerSpecASTNode	*pointerFrom;

	Type			*generateType( Type &targetType );

	PointerSpecASTNode(TypeQualifierList* qls, PointerSpecASTNode *from): 
		qualifiers(qls), pointerFrom(from) { };
	PointerSpecASTNode(PointerSpecASTNode *from):
		pointerFrom(from) {
		qualifiers = new TypeQualifierList;
	};

	virtual ~PointerSpecASTNode() {
		delete qualifiers;
		delete pointerFrom;
	};	
};

class DeclaratorASTNode : public ASTNode {//IMPL: astdecl.cpp
public:
	virtual Symbol		*makeSymbol( Type &outerType ) =0;
	virtual ~DeclaratorASTNode() {};
};

class SymbolDeclaratorNode : public DeclaratorASTNode {
public:
	string			name;
	virtual Symbol		*makeSymbol( Type &outerType );
	virtual ~SymbolDeclaratorNode() {};
	SymbolDeclaratorNode(string nm): name(nm){};
};

class PointerDeclaratorNode : public DeclaratorASTNode {
public:
	DeclaratorASTNode	*inner;
	PointerSpecASTNode	*pointer;
	virtual Symbol		*makeSymbol( Type &outerType );
	virtual ~PointerDeclaratorNode() {
		delete inner;
		delete pointer;
	};
	PointerDeclaratorNode(DeclaratorASTNode *inr, PointerSpecASTNode *ptr):
		 inner(inr), pointer(ptr){};
};

class ArrayDeclaratorNode : public DeclaratorASTNode {
public:
	DeclaratorASTNode	*inner;
	ExpressionASTNode	*sizeExpression;	
	virtual Symbol		*makeSymbol( Type &outerType );
	virtual ~ArrayDeclaratorNode() {
		delete inner;
		delete sizeExpression;
	};
	ArrayDeclaratorNode(DeclaratorASTNode *inr, ExpressionASTNode *sz):
		 inner(inr), sizeExpression(sz){};
};
/*
class FunctionDeclaratorNode : DeclaratorASTNode {
public:
	DeclaratorASTNode	*inner;
	ParameterDeclList	*parameters;	
	virtual Symbol		*makeSymbol( TypeNode &outerType );
	virtual ~FunctionDeclaratorNode() {
		delete inner;
		delete parameters;
	};

	FunctionDeclaratorNode(DeclaratorNode *inr, ParameterList *pr):
		 inner(inr), parameters(pr) {};
	
	FunctionDeclaratorNode(DeclaratorNode *inr):
		 inner(inr) {
		parameters = new ParameterDeclList;
	};
};
*/
#endif
