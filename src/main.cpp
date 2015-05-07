#include <stdio.h>
#include "ast.h"
#include "llool_parse.h"

int yyparse();

int main (int argc, char **argv)
{
	yyparse();
	return 0;
}
