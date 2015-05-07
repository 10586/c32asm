#include <cstdlib>
#include <iostream>
#include <exception>
#include <string>
#include "ast.h"
#include <cerrno>

int64_t IntegerASTNode::evaluate() {
	errno = 0;
	long int res = strtol(value.c_str(), NULL, 0);
	if (errno != 0) {
		cerr << "error converting literal to integer!\n";
		exit(EXIT_FAILURE);
	}
	return (int64_t) res;
}
