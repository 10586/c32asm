/* scanner for low-level obj-oriented language */

%{
#include "scan/prologue.h"
%}

DIGIT		[0-9]
HEXDIGIT	[0-9a-fA-F]
OCTDIGIT	[0-7]
BINDIGIT	[0-1]
LETTER		[a-zA-Z]
ALPHANUM	[a-zA-Z0-9]
ID		[a-zA-Z_][a-zA-Z_0-9]*
ANSIHEXESC	\\x{HEXDIGIT}{2}
ANSIOCTESC	\\{OCTDIGIT}{3}
ANSICTLESC	\\c{LETTER}
ANSIESC		{ANSIHEXESC}|{ANSIOCTESC}|{ANSICTLESC}|(\\[abeEfnrv\'"])
STRINGCHR	[^"\]|{ANSIESC}
CHRDIGIT	[^'\]|{ANSIESC}
WHITESPACE	[ \t]*
%%

0x{HEXDIGIT}+	{
			printf("hexlit(\"%s\")", yytext);
		}

0b{BINDIGIT}+	{
			printf("binlit(\"%s\")", yytext);
		}

0{OCTDIGIT}+	{
			printf("octlit(\"%s\")", yytext);
		}

{DIGIT}+	{
			printf("declit(\"%s\")", yytext);
		}

\'{CHRDIGIT}\'	{
			printf("charlit(\"%s\")", yytext);
		}

\"{STRINGCHR}*\"	{
			printf("strlit(\"%s\")", yytext); 
		}

{ID}		{
			printf("ident(\"%s\")", yytext);
		}

\/\/.*		{
			printf("linecmt(\"%s\")", yytext);
		}

\/\*([^*]|(\*[^\/]))*\*\/ {
			printf("blkcmt(\"%s\")", yytext);
		}

\+\+|\-\-|\-\>|\:\:\|[*+-/.^~]	{
			printf("oper(\"%s\")", yytext);
		}


%%

#include "scan/epilogue.h"
