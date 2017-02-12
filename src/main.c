#include <stdio.h>
#include "cpu.h"
#include "c32asm_parse.h"

int yyparse();
extern int yydebug;
int main (int argc, char **argv)
{
	yydebug=0;
	yyparse();
	return 0;
}
