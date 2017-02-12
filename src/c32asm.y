%{
	#include "cpu.h"
	extern int yylex();
	int yyerror(char *s);
	instr_type enc_imm(uint32_t l) {
		uint32_t max = IMM_MASK>>1;
		uint32_t hmin = ~max;
		if ( l <= max )
			return l;
		else if ( l >= hmin )
			return (l & IMM_MASK );
		yyerror("value not in immediate value range");
		return 0x0;
	}
%}

%union {
	instr_type	iword;
	char *		string;
	int			token;
}

%type	<iword>	regop_spec regop_reg right_operand immediate_val
%type	<iword>	left_ac left_au left_lsb dest_ls instr size_spec
%type	<iword> arith_mnem ls_mnem branch_mnem arith_instr ls_instr
%type	<iword> branch_instr cc_spec eqn_ac eqn_au alu_spec ls_addr
%type	<iword> dest_ac dest_au


%token <string> IDENTIFIER CONSTANT STRING_LITERAL TYPE_NAME LABEL
%token <string> REGSPEC IMM
%token <token>	NEWLINE COMMA PC LR SR ILR B BSR LD ST W H AND OR
%token <token>	INSTR LT GT LEQ GEQ NEQ EQ DOT BRL BRR SUB ADD XOR
%token <token>	ARU ARS ARC ARF
%start translation_unit
%%
/*test */

regop_reg
	: REGSPEC	{
		char *strin = $1 + 1;		/*skip the R*/
		int   rn = atoi( strin );	/*conv to int*/
		if ( rn >= REG_COUNT ) {
			yyerror("invalid register spec");
			YYERROR;
		}
		$$ = (instr_type) rn;
	};

regop_spec
	: PC { $$ = (instr_type) RS_PC; }
	| SR { $$ = (instr_type) RS_SR; }
	| LR { $$ = (instr_type) RS_LR; }
	| ILR { $$ = (instr_type) RS_ILR; }
	;

left_au
	: regop_reg {
		instr_type ra = $1;
		$$ = (ra << RA_OFFSET);
	}
	| regop_spec {
		instr_type ra = $1;
		instr_type out = (ra << RA_OFFSET) ;
		out |= FLAG_SPEC | FLAG_SRC;
		$$ = out;
	}
	;

dest_au
	: regop_reg {
		instr_type rc = $1;
		$$ = (rc << RC_OFFSET);
	}
	| regop_spec {
		instr_type rc = $1;
		instr_type out = (rc << RC_OFFSET) ;
		out |= FLAG_SPEC | FLAG_DST;
		$$ = out;
	}
	;

dest_ls
	: regop_reg {
		instr_type rc = $1;
		$$ = (rc << RC_OFFSET);
	}
	;

dest_ac
	: regop_reg {
		instr_type rc = $1;
		$$ = (rc << RC_OFFSET);
	}
	;

left_ac
	: regop_reg {
		instr_type ra = $1;
		$$ = (ra << RA_OFFSET);
	}
	;

left_lsb
	: regop_reg {
		instr_type ra = $1;
		$$ = (ra << RA_OFFSET);
	}
	| regop_spec {
		instr_type ra = $1;
		instr_type out = (ra << RA_OFFSET);
		out |= FLAG_SPEC;
		$$ = out;
	}
	;

alu_spec
	: ADD	{ $$ = AO_ADD; }
	| SUB	{ $$ = AO_SUB; }
	| AND	{ $$ = AO_AND; }
	| OR	{ $$ = AO_OR; }
	| XOR	{ $$ = AO_XOR; }
	;

immediate_val
	: IMM {
		long l;
		char *errp;
		l = strtoul($1, &errp, 0);
		//printf("ImmValue:%x %s\n",enc_imm(l),$1);
		$$ = enc_imm(l);
	}
	;

right_operand
	: regop_reg	{
		$$ = (instr_type) ($1) << RB_OFFSET;
	}
	| immediate_val	{
		$$ = (instr_type) (($1) << IMM_OFFSET) | FLAG_IMM;
	}
	;

arith_mnem
	: ARS { $$ = IS_ARITH | FLAG_SSR | FLAG_UCARRY; }
	| ARF { $$ = IS_ARITH | FLAG_SSR; }
	| ARC { $$ = IS_ARITH | FLAG_UCARRY; }
	;

ls_mnem
	: LD { $$ = IS_LS; }
	| ST { $$ = IS_LS | FLAG_STORE; }
	;

size_spec
	: B { $$ = TYPE_BYTE; }
	| H { $$ = TYPE_HWORD; }
	| W { $$ = TYPE_WORD; }
	;

cc_spec
	: EQ { $$ = CC_EQ; }
	| NEQ { $$ = CC_NEQ; }
	| GEQ { $$ = CC_GEQ; }
	| LEQ { $$ = CC_LEQ; }
	| GT { $$ = CC_GT; }
	| LT { $$ = CC_LT; }
	;

branch_mnem
	: B	{ $$ = IS_BRANCH; }
	| BSR { $$ = IS_BRANCH | FLAG_SLR; }
	;

ls_addr
	: BRL left_lsb alu_spec right_operand BRR {
		$$ = ( instr_type ) ( $2 | $3 | $4 );
	}
	| BRL left_lsb BRR {
		$$ = ( instr_type ) ( $2 | FLAG_IMM | AO_OR );
	}
	;

eqn_ac
	: left_ac alu_spec right_operand {
		$$ = ( instr_type ) ( $1 | $2 | $3 );
	}
	| left_ac {
		$$ = ( instr_type ) ( $1 | FLAG_IMM | AO_OR );
	}
	;

eqn_au
	: left_au alu_spec right_operand {
		$$ = ( instr_type ) ( $1 | $2 | $3 );
	}
	| left_au {
		$$ = ( instr_type ) ( $1 | FLAG_IMM | AO_OR );
	}
	;

arith_instr
	: arith_mnem dest_ac COMMA eqn_ac {
		$$ = ( instr_type ) ( $1 | $2 | $4 );
	} 
	| ARU dest_au COMMA eqn_au {
		$$ = ( instr_type ) ( $2 | $4 | IS_ARITH );
	}
	;

ls_instr
	: ls_mnem dest_ls COMMA ls_addr {
		$$ = ( instr_type ) ( $1 | $2 | $4 );
	}
	| ls_mnem DOT size_spec dest_ls COMMA ls_addr {
		$$ = ( instr_type ) ( $1 | $3 | $4 | $6 );
	}
	;
	

branch_instr
	: branch_mnem left_lsb COMMA right_operand {
		$$ = ( instr_type ) ( $1 | $2 | $4 | CC_ALWAYS );
	}
	| branch_mnem DOT cc_spec left_lsb COMMA right_operand {
		$$ = ( instr_type ) ( $1 | $3 | $4 | $6 );
	}
	| branch_mnem left_lsb {
		$$ = ( instr_type ) ( $1 | $2 | FLAG_IMM | CC_ALWAYS );
	}
	| branch_mnem DOT cc_spec left_lsb {
		$$ = ( instr_type ) ( $1 | $3 | $4 | FLAG_IMM );
	}
	;

instr
	: arith_instr
	| branch_instr
	| ls_instr
	;

line
	: LABEL instr NEWLINE { printf("%s\t0x%08X\n", $1, $2); }
	| instr NEWLINE { printf(" \t0x%08X\n", $1);}
	;

translation_unit
	: line
	| translation_unit line
	;

%%
#include <stdio.h>

extern char yytext[];
extern int column;

int yyerror(char *s)
{
	fflush(stdout);
	printf("\n%*s\n%*s\n", column, "^", column, s);
}
