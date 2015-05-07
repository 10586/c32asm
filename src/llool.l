D			[0-9]
L			[a-zA-Z_]
H			[a-fA-F0-9]
E			[Ee][+-]?{D}+
FS			(f|F|l|L)
IS			(u|U|l|L)*

%{
#include <stdio.h>
#include <string>
#include "ast.h"
#include "llool_parse.h"
#define STRING_TOKEN yylval.string = new std::string(yytext, yyleng)
#define TOKEN(t) (yylval.token=t)
void comment();
int check_type();
void count();
//extern "C" int yyinput();
%}

%%
"/*"			{ comment(); }

"auto"			{ count(); return TOKEN(AUTO); }
"break"			{ count(); return TOKEN(BREAK); }
"case"			{ count(); return TOKEN(CASE); }
"char"			{ count(); return TOKEN(CHAR); }
"const"			{ count(); return TOKEN(CONST); }
"continue"		{ count(); return TOKEN(CONTINUE); }
"default"		{ count(); return TOKEN(DEFAULT); }
"do"			{ count(); return TOKEN(DO); }
"double"		{ count(); return TOKEN(DOUBLE); }
"else"			{ count(); return TOKEN(ELSE); }
"enum"			{ count(); return TOKEN(ENUM); }
"extern"		{ count(); return TOKEN(EXTERN); }
"float"			{ count(); return TOKEN(FLOAT); }
"for"			{ count(); return TOKEN(FOR); }
"goto"			{ count(); return TOKEN(GOTO); }
"if"			{ count(); return TOKEN(IF); }
"int"			{ count(); return TOKEN(INT); }
"long"			{ count(); return TOKEN(LONG); }
"register"		{ count(); return TOKEN(REGISTER); }
"return"		{ count(); return TOKEN(RETURN); }
"short"			{ count(); return TOKEN(SHORT); }
"signed"		{ count(); return TOKEN(SIGNED); }
"sizeof"		{ count(); return TOKEN(SIZEOF); }
"static"		{ count(); return TOKEN(STATIC); }
"struct"		{ count(); return TOKEN(STRUCT); }
"switch"		{ count(); return TOKEN(SWITCH); }
"typedef"		{ count(); return TOKEN(TYPEDEF); }
"union"			{ count(); return TOKEN(UNION); }
"unsigned"		{ count(); return TOKEN(UNSIGNED); }
"void"			{ count(); return TOKEN(VOID); }
"volatile"		{ count(); return TOKEN(VOLATILE); }
"while"			{ count(); return TOKEN(WHILE); }

{L}({L}|{D})*		{ count(); STRING_TOKEN; return check_type(); }

0[xX]{H}+{IS}?		{ count(); STRING_TOKEN; return CONSTANT; }
0{D}+{IS}?		{ count(); STRING_TOKEN; return CONSTANT; }
{D}+{IS}?		{ count(); STRING_TOKEN; return CONSTANT; }
L?'(\\.|[^\\'])+'	{ count(); STRING_TOKEN; return CONSTANT; }

{D}+{E}{FS}?		{ count(); STRING_TOKEN; return CONSTANT; }
{D}*"."{D}+({E})?{FS}?	{ count(); STRING_TOKEN; return CONSTANT; }
{D}+"."{D}*({E})?{FS}?	{ count(); STRING_TOKEN; return CONSTANT; }

L?\"(\\.|[^\\"])*\"	{ count(); STRING_TOKEN; return TOKEN(STRING_LITERAL); }

"..."			{ count(); return TOKEN(ELLIPSIS); }
">>="			{ count(); return TOKEN(RIGHT_ASSIGN); }
"<<="			{ count(); return TOKEN(LEFT_ASSIGN); }
"+="			{ count(); return TOKEN(ADD_ASSIGN); }
"-="			{ count(); return TOKEN(SUB_ASSIGN); }
"*="			{ count(); return TOKEN(MUL_ASSIGN); }
"/="			{ count(); return TOKEN(DIV_ASSIGN); }
"%="			{ count(); return TOKEN(MOD_ASSIGN); }
"&="			{ count(); return TOKEN(AND_ASSIGN); }
"^="			{ count(); return TOKEN(XOR_ASSIGN); }
"|="			{ count(); return TOKEN(OR_ASSIGN); }
">>"			{ count(); return TOKEN(RIGHT_OP); }
"<<"			{ count(); return TOKEN(LEFT_OP); }
"++"			{ count(); return TOKEN(INC_OP); }
"--"			{ count(); return TOKEN(DEC_OP); }
"->"			{ count(); return TOKEN(PTR_OP); }
"&&"			{ count(); return TOKEN(AND_OP); }
"||"			{ count(); return TOKEN(OR_OP); }
"<="			{ count(); return TOKEN(LE_OP); }
">="			{ count(); return TOKEN(GE_OP); }
"=="			{ count(); return TOKEN(EQ_OP); }
"!="			{ count(); return TOKEN(NE_OP); }
";"			{ count(); return TOKEN(';'); }
("{"|"<%")		{ count(); return TOKEN('{'); }
("}"|"%>")		{ count(); return TOKEN('}'); }
","			{ count(); return TOKEN(','); }
":"			{ count(); return TOKEN(':'); }
"="			{ count(); return TOKEN('='); }
"("			{ count(); return TOKEN('('); }
")"			{ count(); return TOKEN(')'); }
("["|"<:")		{ count(); return TOKEN('['); }
("]"|":>")		{ count(); return TOKEN(']'); }
"."			{ count(); return TOKEN('.'); }
"&"			{ count(); return TOKEN('&'); }
"!"			{ count(); return TOKEN('!'); }
"~"			{ count(); return TOKEN('~'); }
"-"			{ count(); return TOKEN('-'); }
"+"			{ count(); return TOKEN('+'); }
"*"			{ count(); return TOKEN('*'); }
"/"			{ count(); return TOKEN('/'); }
"%"			{ count(); return TOKEN('%'); }
"<"			{ count(); return TOKEN('<'); }
">"			{ count(); return TOKEN('>'); }
"^"			{ count(); return TOKEN('^'); }
"|"			{ count(); return TOKEN('|'); }
"?"			{ count(); return TOKEN('?'); }

[ \t\v\n\f]		{ count(); }
.			{ /* ignore bad characters */ }

%%

int yywrap()
{
	return TOKEN(1);
}


void comment()
{
	char c, c1;

loop:
	while ((c = yyinput()) != '*' && c != 0)
		putchar(c);

	if ((c1 = yyinput()) != '/' && c != 0)
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

