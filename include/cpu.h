#include <stdint.h>

#ifndef __cpu_h__
#define __cpu_h__
#define nullptr (0)
#define IMM_MASK	(0x3FFF)
#define IS_BRANCH	(0x2)
#define IS_LS		(0x1)
#define IS_ARITH	(0x0)
#define FLAG_SLR	(0x80)
#define RPL_OFFSET	(8)
#define REG_COUNT	(16)
#define FLAG_IMM	(0x20)
#define FLAG_SPEC	(0x40)
#define FLAG_SRC	(0x80)
#define FLAG_DST	(0x100)
#define FLAG_UCARRY	(0x80)
#define FLAG_SSR	(0x100)
#define FLAG_RSH	(0x200)// this one
#define TYPE_WORD	(0x000)
#define TYPE_HWORD	(0x100)
#define TYPE_BYTE	(0x200)// this one
#define FLAG_STORE	(0x80)
#define RA_OFFSET	(10)
#define RC_OFFSET	(14)
#define RB_OFFSET	(18)
#define IMM_OFFSET	(18)
#define RS_PC		(0x0)
#define RS_SR		(0x4)
#define RS_LR		(0x8)
#define RS_ILR		(0xC)
#define CC_ALWAYS	(0x0)
#define CC_EQ		(0x1<<2)
#define CC_LT		(0x2<<2)
#define CC_LEQ		(0x3<<2)
#define CC_NEQ		(0x5<<2)
#define CC_GEQ		(0x6<<2)
#define CC_GT		(0x7<<2)
#define AO_ZERO		(0x0<<2)
#define AO_ISUB		(0x1<<2)
#define AO_SUB		(0x2<<2)
#define AO_ADD		(0x3<<2)
#define AO_XOR		(0x4<<2)
#define AO_OR		(0x5<<2)
#define AO_AND		(0x6<<2)
#define AO_ONES		(0x7<<2)
typedef uint32_t	instr_type;
typedef instr_type	regspec_type;

#endif
