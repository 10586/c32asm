D			[0-9]
L			[a-zA-Z_]
H			[a-fA-F0-9]
HI			(0x|0X)
RI			[rR]
%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "cpu.h"
#include "c32asm_parse.h"
char *makestring(char *text, int len) {
	char *out = malloc( len + 1 );
	memcpy(out,text,len);	
	out[len] = 0;
	return out;
}
#define STRING_TOKEN yylval.string = makestring(yytext, yyleng)
#define TOKEN(t) (yylval.token=t)
void comment();
int check_type();
void count();
%}

%%
"/*"				{ comment(); }
{L}({L}|{D})*":"	{ count(); STRING_TOKEN; return LABEL; }
[rR]{D}({D}*)		{ count(); STRING_TOKEN; return REGSPEC; }
{D}{D}*				{ count(); STRING_TOKEN; return IMM; }
{HI}{H}{H}*			{ count(); STRING_TOKEN; return IMM; }
(sr|SR)				{ count(); return TOKEN(SR); }
(pc|PC)				{ count(); return TOKEN(PC); }
(lr|LR)				{ count(); return TOKEN(LR); }
(ilr|ILR)			{ count(); return TOKEN(ILR); }
"b"					{ count(); return TOKEN(B); }
"h"					{ count(); return TOKEN(H); }
"w"					{ count(); return TOKEN(W); }
"bsr"				{ count(); return TOKEN(BSR); }
"ld"				{ count(); return TOKEN(LD); }
"st"				{ count(); return TOKEN(ST); }
"aru"				{ count(); return TOKEN(ARU); }
"ars"				{ count(); return TOKEN(ARS); }
"arc"				{ count(); return TOKEN(ARC); }
"arf"				{ count(); return TOKEN(ARF); }
"\n"				{ count(); return TOKEN(NEWLINE); }
","					{ count(); return TOKEN(COMMA); }
"?"					{ count(); return TOKEN('?'); }
"eq"				{ count(); return TOKEN(EQ); }
"lt"				{ count(); return TOKEN(LT); }
"leq"				{ count(); return TOKEN(LEQ); }
"neq"				{ count(); return TOKEN(NEQ); }
"geq"				{ count(); return TOKEN(GEQ); }
"gt"				{ count(); return TOKEN(GT); }
"."					{ count(); return TOKEN(DOT); }
"["					{ count(); return TOKEN(BRL); }
"]"					{ count(); return TOKEN(BRR); }
"-"					{ count(); return TOKEN(SUB); }
"+"					{ count(); return TOKEN(ADD); }
"&"					{ count(); return TOKEN(AND); }
"|"					{ count(); return TOKEN(OR); }
"^"					{ count(); return TOKEN(XOR); }

[ \t\v\f]			{ count(); }
.					{ /* ignore bad characters */ }

%%

int yywrap()
{
	return TOKEN(1);
}


void comment()
{
	char c, c1;

loop:
	while ((c = input()) != '*' && c != 0)
		putchar(c);

	if ((c1 = input()) != '/' && c != 0)
	{
		unput(c1);
		goto loop;
	}

	if (c != 0)
		putchar(c1);
}


int column = 0;

void count()
{
	int i;

	for (i = 0; yytext[i] != '\0'; i++)
		if (yytext[i] == '\n')
			column = 0;
		else if (yytext[i] == '\t')
			column += 8 - (column % 8);
		else
			column++;

	ECHO;
}


int check_type()
{
/*
* pseudo code --- this is what it should check
*
*	if (yytext == type_name)
*		return TOKEN(TYPE_NAME);
*
*	return TOKEN(IDENTIFIER);
*/

/*
*	it actually will only return IDENTIFIER
*/

	return IDENTIFIER;
}

