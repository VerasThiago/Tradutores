%define lr.type canonical-lr
%define parse.error verbose
%debug
%locations



%{
    #include <stdlib.h>
    #include <stdio.h>
    #include <string.h>
    #include "stack.c"
    #include "table.c"

    extern int yylex();
    extern int yyparse();
    extern int yyerror(const char* message);
    extern int yylex_destroy();
    extern FILE* yyin;

%}

%union {
	char* body;
}

%token ','
%token '{'
%token '('
%token '}'
%token ')'
%token ';'
%token '='

%token ELEM
%token IF
%token ELSE
%token SET
%token AND_OP
%token OR_OP
%token FOR
%token RETURN
%token WRITE
%token WRITELN
%token READ
%token EMPTY
%token FLOAT
%token INT
%token ADD
%token REMOVE
%token EXISTS
%token FOR_ALL
%token IS_SET
%token IN

%token <body> INT_VALUE
%token <body> FLOAT_VALUE
%token <body> ID

%left <body> RELATIONAL_OP
%left <body> MULTIPLICATIVE_OP
%left <body> ADDITIVE_OP

%token <body> STRING


%start start

%%

start:
	program {
        printf("[SYNTATIC] (start) program\n");
    }
;

program:
	function_definition {
        printf("[SYNTATIC] (program) function_definition\n");
    }
	| function_definition program {
        printf("[SYNTATIC] (program) function_definition program\n");
    }
	| variables_declaration program {
        printf("[SYNTATIC] (program) variables_declaration program\n");
    }
;

function_definition:
	function_declaration '(' parameters ')' function_body {
        printf("[SYNTATIC] (function_definition) function_declaration '(' parameters ')' function_body\n");
    }
    | error {}
;

function_declaration:
	type_identifier ID {
        push_back(&tableList, createSymbol(lines, columns, "function", $2));
        printf("[SYNTATIC] (function_declaration) type_identifier ID(%s)\n", $2);
    }
;

function_body:
	'{' statements '}' {
        printf("[SYNTATIC] (function_body) '{' statements '}'\n");
    }
;

parameters:
	parameters_list {
        printf("[SYNTATIC] (parameters) '(' parameters_list ')'\n");
    }
    | %empty {
    //    printf("[SYNTATIC] (parameters) VAZIO\n"); 
    }
;

parameters_list:
	parameters_list ',' parameter {
        printf("[SYNTATIC] (parameters_list) parameter ',' parameters_list\n");
    } 
	| parameter {
        printf("[SYNTATIC] (parameters_list) parameter\n");
    }
;

parameter:
	type_identifier ID {
        printf("[SYNTATIC] (parameter) type_identifier ID(%s)\n", $2);
    }
;

type_identifier:
	INT {
        printf("[SYNTATIC] (type_identifier) INT\n");
    }
    | FLOAT {
        printf("[SYNTATIC] (type_identifier) FLOAT\n");
    }
	| ELEM {
        printf("[SYNTATIC] (type_identifier) ELEM\n");
    }
    | SET{
        printf("[SYNTATIC] (type_identifier) SET\n");
    }
;

statements:
	statement statements {
        printf("[SYNTATIC] (statements) statement statements\n");   
    }
	| statement {
        printf("[SYNTATIC] (statements) statement\n");   
    }
    | statements_braced {
        printf("[SYNTATIC] (statements) statements_braced\n");
    }
;

statements_braced:
    '{' statements '}' {
        printf("[SYNTATIC] (statements_braced) '{' statements '}'\n");
    }
    | '{' '}' {
        printf("[SYNTATIC] (statements_braced) '{' '}'\n");
    }
;

statement:
	variables_declaration {
        printf("[SYNTATIC] (statement) variables_declaration\n");   
    }
	| return {
        printf("[SYNTATIC] (statement) return\n");   
    }
	| conditional {
        printf("[SYNTATIC] (statement) conditional\n");   
    }
	| for {
        printf("[SYNTATIC] (statement) for\n");   
    }
    | is_set_statement {
        printf("[SYNTATIC] (statement) is_set_statement\n");   
    }
    | function_call_statement {
        printf("[SYNTATIC] (statement) function_call_statement\n");   
    }
	| expression_statement {
        printf("[SYNTATIC] (statement) expression_statement \n");   
    }
	| io_statement {
        printf("[SYNTATIC] (statement) io_statement\n");  
    }
	| set_pre_statement {
        printf("[SYNTATIC] (statement) set_pre_statement\n");  
    }
;

set_pre_statement:
    set_statement_add_remove ';' {
        printf("[SYNTATIC] (set_pre_statement) set_statement_add_remove ';'\n");  
    }
    | set_statement_for_all {
        printf("[SYNTATIC] (set_pre_statement) set_statement_for_all\n");  
    }
;

set_statement_add_remove:
    ADD '(' set_boolean_expression ')' {
        printf("[SYNTATIC] (set_statement_add_remove) ADD '(' set_boolean_expression ')'\n"); 
    }
    | REMOVE '(' set_boolean_expression ')' {
        printf("[SYNTATIC] (set_statement_add_remove) REMOVE '(' set_boolean_expression ')'\n"); 
    }
;

set_statement_for_all:
    FOR_ALL '(' set_assignment_expression ')' statements {
        printf("[SYNTATIC] (set_statement_for_all) FOR_ALL '(' set_assignment_expression ')' statements\n"); 
    }
;

set_statement_exists:
    EXISTS '(' set_assignment_expression ')' {
        printf("[SYNTATIC] (set_statement_exists) EXISTS '(' set_assignment_expression ')'\n"); 
    }
;

set_boolean_expression:
    expression IN set_statement_add_remove {
        printf("[SYNTATIC] (set_boolean_expression) expression IN set_statement_add_remove\n");
    }
    | expression IN ID {
        printf("[SYNTATIC] (set_boolean_expression) expression IN ID(%s)\n", $3);
    }
;

set_assignment_expression:
    ID IN set_statement_add_remove {
        printf("[SYNTATIC] (set_assignment_expression) expression IN set_statement_add_remove\n");
    }
    | ID IN ID {
        printf("[SYNTATIC] (set_assignment_expression) ID(%s) IN ID(%s)\n", $1, $3);
    }
;

expression_statement:
    expression ';' {
        printf("[SYNTATIC] (expression_statement) expression\n");
    }
;

expression:
    expression_assignment {
        printf("[SYNTATIC] (expression) expression_assignment\n");
    }
;

expression_assignment:
    expression_logical {
        printf("[SYNTATIC] (expression) expression_logical\n");   
    }
    | ID '=' expression {
        //  printf("[SYNTATIC] (expression_assignment) ID(%s) '='  expression\n", $1);
    }
;

expression_logical:
    expression_relational {
        printf("[SYNTATIC] (expression_logical) expression_relational\n");
    }
    | set_boolean_expression {
        printf("[SYNTATIC] (expression_logical) set_expression\n");
    }
    | is_set_expression {
        printf("[SYNTATIC] (is_set_expression) is_set_expression\n");
    }
    | expression_logical AND_OP expression_logical {
        printf("[SYNTATIC] (expression_logical) expression_logical AND_OP(&&) expression_logical\n");
    }
    | expression_logical OR_OP expression_logical {
        printf("[SYNTATIC] (expression_logical) expression_logical OR_OP(||) expression_logical\n");
    }
;

expression_relational:
    expression_additive {
        printf("[SYNTATIC] (expression_relational) expression_additive \n");
    }
    | expression_relational RELATIONAL_OP expression_relational {
        printf("[SYNTATIC] (expression_relational) expression_relational RELATIONAL_OP(%s) expression_relational\n", $2);
    }
;

expression_additive:
    expression_multiplicative {
        printf("[SYNTATIC] (expression_additive) expression_multiplicative \n");
    }
    | expression_additive ADDITIVE_OP expression_additive {
        printf("[SYNTATIC] (expression_additive) expression_additive ADDITIVE_OP(%s) expression_additive \n", $2);
    }
;

expression_multiplicative:
    expression_value {
        printf("[SYNTATIC] (expression_multiplicative) expression_additive \n");
    }
    | expression_multiplicative MULTIPLICATIVE_OP expression_multiplicative {
        printf("[SYNTATIC] (expression_multiplicative)  expression_multiplicative MULTIPLICATIVE_OP(%s) expression_multiplicative \n", $2);
    }
;

expression_value:
    '(' expression ')' {
        printf("[SYNTATIC] (expression_value) '(' expression ')' \n");
    }
    | value {
        printf("[SYNTATIC] (expression_value) value \n");
    }
    | ADDITIVE_OP value {
        printf("[SYNTATIC] (expression_value) ADDITIVE_OP(%s) value \n", $1);
    }
    | set_statement_exists {
        printf("[SYNTATIC] (expression_value) set_statement_exists\n");
    }
;

is_set_statement:
    is_set_expression ';' {
        printf("[SYNTATIC] (is_set_statement) is_set_expression ';'\n");
    }
;

is_set_expression: 
    IS_SET '(' ID ')' {
        printf("[SYNTATIC] (is_set) IS_SET '(' ID(%s) ')' ';'\n", $3);
    }
;

for:
    FOR '(' for_expression ')' statements {
        printf("[SYNTATIC] (for) FOR '(' for_expression ')' statement\n");
    }
;

for_expression:
    expression_assignment ';' expression_logical ';' expression_assignment {
        printf("[SYNTATIC] (for_expression) expression_assignment ';' expression_logical ';' expression_assignment\n");
    }
;

io_statement:
    READ '(' ID ')' ';' {
        printf("[SYNTATIC] (io_statement) READ '(' ID(%s) ')' ';'\n", $3);
    }
    | WRITE '(' STRING ')' ';' {
        printf("[SYNTATIC] (io_statement) WRITE '(' STRING(%s) ')' ';'\n", $3);
    }
    | WRITE '(' expression ')' ';' {
        printf("[SYNTATIC] (io_statement) WRITE '(' expression ')' ';'\n");
    }
    | WRITELN '(' STRING ')' ';' {
        printf("[SYNTATIC] (io_statement) WRITELN '(' STRING(%s) ')' ';'\n", $3);
    }
    | WRITELN '(' expression ')' ';' {
        printf("[SYNTATIC] (io_statement) WRITELN '(' expression ')' ';'\n");
    }
;

arguments_list:
    arguments_list ',' expression {
        printf("[SYNTATIC] (arguments_list) expression value\n");
    }
    | expression {
        printf("[SYNTATIC] (arguments_list) expression\n");
    }
    
;

conditional:
    IF conditional_expression statements {
        printf("[SYNTATIC] (conditional) IF conditional_expression statements\n");
    }
    | IF conditional_expression statements_braced ELSE statements_braced {
        printf("[SYNTATIC] (conditional) IF conditional_expression statements_braced ELSE statements_braced\n");
    }
;

conditional_expression:
    '(' expression ')' {
        printf("[SYNTATIC] (conditional_expression) '(' expression ')'\n");
    }
;

return:
    RETURN expression ';' {
        printf("[SYNTATIC] (return) RETURN expression ';'\n");
    }
    | RETURN ';' {
        printf("[SYNTATIC] (return) RETURN ';'\n");
    }
;

value:
    ID {
        printf("[SYNTATIC] (value) ID = %s\n", $1);
    }
    | const {
        printf("[SYNTATIC] (value) const\n");
    }
    | function_call {
        printf("[SYNTATIC] (value) function_call\n");
    }
;

function_call_statement:
    function_call ';' {
        printf("[SYNTATIC] (function_call_statement) function_call ';'\n");
    }
;

function_call:
    ID '(' arguments_list ')' {
        printf("[SYNTATIC] (function_call) ID(%s) '(' arguments_list ')'\n", $1);
    }
    | ID '(' ')' {
        printf("[SYNTATIC] (function_call) ID(%s) '(' ')'\n", $1);
    }
;

variables_declaration:
    type_identifier ID ';' {
        push_back(&tableList, createSymbol(lines, columns, "variable", $2));
        printf("[SYNTATIC] (variables_declaration) type_identifier ID(%s) ';'\n", $2);
    }
    | error {}
;

const:
    INT_VALUE {
        printf("[SYNTATIC] (const) INT_VALUE = %s\n", $1);
    }
    | FLOAT_VALUE {
        printf("[SYNTATIC] (const) FLOAT_VALUE = %s\n", $1);
    }
    | EMPTY {
        printf("[SYNTATIC] (const) EMPTY\n");
    }
;

%%

int yyerror(const char* message){
    printf("[SYNTATIC] ERROR [%d:%d] %s\n", lines, columns, message);
    return 0;
}

int main(int argc, char ** argv) {
    // ++argv, --argc;
    // if(argc > 0) {
    //     yyin = fopen(argv[0], "r");
    // }
    // else {
    //     yyin = stdin;
    // }

    stackScope.size = stackScope.nxtScope = -1;
    
    tableList.size = -1;

    push(&stackScope);

    lines = 0;
    columns = 0;
    errors = 0;

    yyparse();
    printf("\n");
    if(errors > 0){
        printf("Program analysis failed!\nLexical analysis terminated with %d error(s)\n", errors);
    }
    else{
        printf("Correct program.\n");
    }

    printTable(&tableList);

    // fclose(yyin);
    yylex_destroy();
    return 0;
}