%{
	#include "ast.h"
	extern int yylex();
	int yyerror(char *s);
%}

%union {
	ASTNode			*node;
	ExpressionASTNode	*expression;
	ReferenceASTNode	*reference;
	DeclarationASTNode	*declaration;
	DeclarationSpecASTNode	*declspec;
	DeclarationSpecList	*decls_lst;
	DeclaratorList		*detr_lst;
	TypeSpecNode		*tspec;
	TypeQualifierList	*tqual_lst;
	PointerSpecASTNode	*ptrspec;
	DeclaratorASTNode	*declarator;
	std::string		*string;
	StorageClassSpecifier	 stclass;
	TypeQualifier		 tqual;
	int			 token;
}

%type <tspec> type_specifier
%type <tqual> type_qualifier
%type <stclass> storage_class_specifier 
%type <expression> primary_expression postfix_expression unary_expression
%type <expression> constant_expression
%type <decls_lst> declaration_specifiers
%type <declarator> declarator direct_declarator init_declarator
%type <ptrspec> pointer
%type <tqual_lst> type_qualifier_list
%type <detr_lst> init_declarator_list
%type <declaration> declaration

%token <string> IDENTIFIER CONSTANT STRING_LITERAL TYPE_NAME
%token <token> PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token <token> AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token <token> SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token <token> XOR_ASSIGN OR_ASSIGN SIZEOF

%token <token> TYPEDEF EXTERN STATIC AUTO REGISTER
%token <token> CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE VOID
%token <token> CONST VOLATILE

%token <token> STRUCT UNION ENUM ELLIPSIS

%token <token> CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%start translation_unit
%%
/*test */
primary_expression
	: IDENTIFIER		{ $$ = new ReferenceASTNode(*$1); delete $1; }
	| CONSTANT		{ $$ = new IntegerASTNode(*$1); delete $1; }
	| STRING_LITERAL	{ $$ = new StringASTNode(*$1); delete $1; }	
	| '(' expression ')'	/*{ $$ = $2; }*/
	;

postfix_expression
	: primary_expression
	| postfix_expression '[' expression ']'
	| postfix_expression '(' ')'
	| postfix_expression '(' argument_expression_list ')'
	| postfix_expression '.' IDENTIFIER
	| postfix_expression PTR_OP IDENTIFIER
	| postfix_expression INC_OP
	| postfix_expression DEC_OP
	;

argument_expression_list
	: assignment_expression
	| argument_expression_list ',' assignment_expression
	;

unary_expression
	: postfix_expression
	| INC_OP unary_expression
	| DEC_OP unary_expression
	| unary_operator cast_expression
	| SIZEOF unary_expression
	| SIZEOF '(' type_name ')'
	;

unary_operator
	: '&'
	| '*'
	| '+'
	| '-'
	| '~'
	| '!'
	;

cast_expression
	: unary_expression
	| '(' type_name ')' cast_expression
	;

multiplicative_expression
	: cast_expression
	| multiplicative_expression '*' cast_expression
	| multiplicative_expression '/' cast_expression
	| multiplicative_expression '%' cast_expression
	;

additive_expression
	: multiplicative_expression
	| additive_expression '+' multiplicative_expression
	| additive_expression '-' multiplicative_expression
	;

shift_expression
	: additive_expression
	| shift_expression LEFT_OP additive_expression
	| shift_expression RIGHT_OP additive_expression
	;

relational_expression
	: shift_expression
	| relational_expression '<' shift_expression
	| relational_expression '>' shift_expression
	| relational_expression LE_OP shift_expression
	| relational_expression GE_OP shift_expression
	;

equality_expression
	: relational_expression
	| equality_expression EQ_OP relational_expression
	| equality_expression NE_OP relational_expression
	;

and_expression
	: equality_expression
	| and_expression '&' equality_expression
	;

exclusive_or_expression
	: and_expression
	| exclusive_or_expression '^' and_expression
	;

inclusive_or_expression
	: exclusive_or_expression
	| inclusive_or_expression '|' exclusive_or_expression
	;

logical_and_expression
	: inclusive_or_expression
	| logical_and_expression AND_OP inclusive_or_expression
	;

logical_or_expression
	: logical_and_expression
	| logical_or_expression OR_OP logical_and_expression
	;

conditional_expression
	: logical_or_expression
	| logical_or_expression '?' expression ':' conditional_expression
	;

assignment_expression
	: conditional_expression
	| unary_expression assignment_operator assignment_expression
	;

assignment_operator
	: '='
	| MUL_ASSIGN
	| DIV_ASSIGN
	| MOD_ASSIGN
	| ADD_ASSIGN
	| SUB_ASSIGN
	| LEFT_ASSIGN
	| RIGHT_ASSIGN
	;

expression
	: assignment_expression
	| expression ',' assignment_expression
	;

constant_expression
	: conditional_expression
	;

declaration
	: declaration_specifiers ';' {
		$$ = new DeclarationASTNode($1, new DeclaratorList);
	}
	| declaration_specifiers init_declarator_list ';' {
		$$ = new DeclarationASTNode($1, $2);
		$$->declareSymbols();
	}
	;

declaration_specifiers
	: storage_class_specifier	{ 
		$$ = new DeclarationSpecList(); $$->push_back(new StorageClassNode($1));
	}
	| storage_class_specifier declaration_specifiers	{ 
		$$ = $2; $$->push_back(new StorageClassNode($1));
	}
	| type_specifier {
		$$ = new DeclarationSpecList(); $$->push_back($1);
	}
	| type_specifier declaration_specifiers	{ 
		$$ = $2; $$->push_back($1);
	}
	| type_qualifier {
		$$ = new DeclarationSpecList(); $$->push_back(new TypeQualifierNode($1));
	}
	| type_qualifier declaration_specifiers	{ 
		$$ = $$; $$->push_back(new TypeQualifierNode($1));
	}
	;

init_declarator_list
	: init_declarator {
		$$ = new DeclaratorList;
		$$->push_back($1);
	}
	| init_declarator_list ',' init_declarator {
		$$ = $1;
		$$->push_back($3);
	}
	;

init_declarator
	: declarator
	| declarator '=' initializer
	;

storage_class_specifier
	: TYPEDEF		{ $$ = SC_TYPEDEF; }
	| EXTERN		{ $$ = SC_EXTERN; }
	| STATIC		{ $$ = SC_STATIC; }
	| AUTO			{ $$ = SC_AUTO; }
	| REGISTER		{ $$ = SC_REGISTER; }
	;

type_specifier
	: VOID			{ $$ = new BuiltinTypeSpecNode(TS_VOID); }
	| CHAR			{ $$ = new BuiltinTypeSpecNode(TS_CHAR); }
	| SHORT			{ $$ = new BuiltinTypeSpecNode(TS_SHORT); }
	| INT			{ $$ = new BuiltinTypeSpecNode(TS_INT); }
	| LONG			{ $$ = new BuiltinTypeSpecNode(TS_LONG); }
	| FLOAT			{ $$ = new BuiltinTypeSpecNode(TS_FLOAT); }
	| DOUBLE		{ $$ = new BuiltinTypeSpecNode(TS_DOUBLE); }
	| SIGNED		{ $$ = new BuiltinTypeSpecNode(TS_SIGNED); }
	| UNSIGNED		{ $$ = new BuiltinTypeSpecNode(TS_UNSIGNED); }
	| struct_or_union_specifier
	| enum_specifier
	| TYPE_NAME		{ $$ = new NamedTypeSpecNode(*$1); delete $1; }
	;

struct_or_union_specifier
	: struct_or_union IDENTIFIER '{' struct_declaration_list '}'
	| struct_or_union '{' struct_declaration_list '}'
	| struct_or_union IDENTIFIER
	;

struct_or_union
	: STRUCT
	| UNION
	;

struct_declaration_list
	: struct_declaration
	| struct_declaration_list struct_declaration
	;

struct_declaration
	: specifier_qualifier_list struct_declarator_list ';'
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list
	| type_specifier
	| type_qualifier specifier_qualifier_list
	| type_qualifier
	;

struct_declarator_list
	: struct_declarator
	| struct_declarator_list ',' struct_declarator
	;

struct_declarator
	: declarator
	| ':' constant_expression
	| declarator ':' constant_expression
	;

enum_specifier
	: ENUM '{' enumerator_list '}'
	| ENUM IDENTIFIER '{' enumerator_list '}'
	| ENUM IDENTIFIER
	;

enumerator_list
	: enumerator
	| enumerator_list ',' enumerator
	;

enumerator
	: IDENTIFIER
	| IDENTIFIER '=' constant_expression
	;

type_qualifier
	: CONST				{ $$ = TQ_CONST; }
	| VOLATILE			{ $$ = TQ_VOLATILE; }
	;

declarator
	: pointer direct_declarator	{ $$ = new PointerDeclaratorNode($2, $1); }
	| direct_declarator
	;

direct_declarator
	: IDENTIFIER			{ $$ = new SymbolDeclaratorNode(*$1); delete $1; }
	| '(' declarator ')'		{ $$ = $2; }
	| direct_declarator '[' constant_expression ']' { 
		$$ = new ArrayDeclaratorNode( $1 , $3 );
	}
	| direct_declarator '[' ']' {
		$$ = new ArrayDeclaratorNode( $1, nullptr );
	}
	/*| direct_declarator '(' parameter_type_list ')' {
		/* this would be a function declaration * /
	}
	| direct_declarator '(' identifier_list ')' {
		/* as would this * /
	}
	| direct_declarator '(' ')' {
		/* and this * /
	} */
	;

pointer
	: '*'				{ $$ = new PointerSpecASTNode( nullptr ); }
	| '*' type_qualifier_list	{ $$ = new PointerSpecASTNode( $2, nullptr ); }
	| '*' pointer			{ $$ = new PointerSpecASTNode( $2 ); }
	| '*' type_qualifier_list pointer { $$ = new PointerSpecASTNode( $2, $3 ); }
	;

type_qualifier_list
	: type_qualifier { $$ = new TypeQualifierList; $$->push_back($1); }
	| type_qualifier_list type_qualifier { $$ = $1; $$->push_back($2); }
	;


parameter_type_list
	: parameter_list
	| parameter_list ',' ELLIPSIS
	;

parameter_list
	: parameter_declaration
	| parameter_list ',' parameter_declaration
	;

parameter_declaration
	: declaration_specifiers declarator
	| declaration_specifiers abstract_declarator
	| declaration_specifiers
	;

identifier_list
	: IDENTIFIER
	| identifier_list ',' IDENTIFIER
	;

type_name
	: specifier_qualifier_list
	| specifier_qualifier_list abstract_declarator
	;

abstract_declarator
	: pointer
	| direct_abstract_declarator
	| pointer direct_abstract_declarator
	;

direct_abstract_declarator
	: '(' abstract_declarator ')'
	| '[' ']'
	| '[' constant_expression ']'
	| direct_abstract_declarator '[' ']'
	| direct_abstract_declarator '[' constant_expression ']'
	| '(' ')'
	| '(' parameter_type_list ')'
	| direct_abstract_declarator '(' ')'
	| direct_abstract_declarator '(' parameter_type_list ')'
	;

initializer
	: assignment_expression
	| '{' initializer_list '}'
	| '{' initializer_list ',' '}'
	;

initializer_list
	: initializer
	| initializer_list ',' initializer
	;

statement
	: labeled_statement
	| compound_statement
	| expression_statement
	| selection_statement
	| iteration_statement
	| jump_statement
	;

labeled_statement
	: IDENTIFIER ':' statement
	| CASE constant_expression ':' statement
	| DEFAULT ':' statement
	;

compound_statement
	: '{' '}'
	| '{' statement_list '}'
	| '{' declaration_list '}'
	| '{' declaration_list statement_list '}'
	;

declaration_list
	: declaration
	| declaration_list declaration
	;

statement_list
	: statement
	| statement_list statement
	;

expression_statement
	: ';'
	| expression ';'
	;

selection_statement
	: IF '(' expression ')' statement
	| IF '(' expression ')' statement ELSE statement
	| SWITCH '(' expression ')' statement
	;

iteration_statement
	: WHILE '(' expression ')' statement
	| DO statement WHILE '(' expression ')' ';'
	| FOR '(' expression_statement expression_statement ')' statement
	| FOR '(' expression_statement expression_statement expression ')' statement
	;

jump_statement
	: GOTO IDENTIFIER ';'
	| CONTINUE ';'
	| BREAK ';'
	| RETURN ';'
	| RETURN expression ';'
	;

translation_unit
	: external_declaration
	| translation_unit external_declaration
	;

external_declaration
	: function_definition
	| declaration
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement
	| declaration_specifiers declarator compound_statement
	| declarator declaration_list compound_statement
	| declarator compound_statement
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
