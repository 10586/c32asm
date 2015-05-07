#include "ast.h"
#include <iostream>
#include <cstdlib>

int64_t ReferenceASTNode::evaluate()
{
	cerr << "array size must be a constant expression\n"; 
	exit(EXIT_FAILURE);
}


