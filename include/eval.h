#ifndef __eval_h__
#define __eval_h__

typedef enum {
	OP_ADD,
	OP_SUB,
	OP_MUL,
	OP_DIV,
	OP_PREINC,
	OP_PREDEC,
	OP_POSTINC,
	OP_POSTDEC,
	OP_NEGATE,
	OP_NOT,
	OP_XOR,
	OP_AND,
	OP_OR,
	OP_BOOL_NOT,
	OP_BOOL_AND,
	OP_BOOL_OR,
	OP_LT,
	OP_GT,
	OP_GEQ,
	OP_LEQ,
	OP_EQ,
	OP_NEQ,
	OP_SHL,
	OP_SHR,
	OP_ADDROF,
	OP_DEREF,
	OP_MOD,
	OP_SIZEOF,
	OP_ARRAY
	OP_ASSIGN,
	OP_NUMNOP /* unary + operator, no op that does validate numeric type */
} Operation;

#endif
