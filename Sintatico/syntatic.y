%define lr.type canonical-lr
%define parse.error verbose
%debug
%locations



%{
    #include <stdlib.h>
    #include <stdio.h>
    #include <string.h>

    extern int yylex();
    extern int yyparse();
    extern int yyerror(const char* message);
    extern int yylex_destroy();
    extern FILE* yyin;

    extern int lines;
    extern int errors;
    extern int columns;
%}

%union {
	char* body;
}

%token ','
%token ELEM
%token IF
%token ELSE
%token '{'
%token '('
%token '}'
%token ')'
%token ';'
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
%token FOR_ALL
%token IS_SET
%token IN

%token <body> SET_BASIC
%token <body> INT_VALUE
%token <body> FLOAT_VALUE
%token <body> ID

%token <body> ASSIGNMENT_OP
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
    | error {
        printf("[SYNTATIC] (start) error \n");
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
    | error {
        printf("[SYNTATIC] ERROR program\n");
    }
;

function_definition:
	function_declaration '(' parameters ')' function_body {
        printf("[SYNTATIC] (function_definition) function_declaration '(' parameters ')' function_body\n");
    }
    | error {
        printf("[SYNTATIC] ERROR function_definition\n");
    }
;

function_declaration:
	type_identifier ID {
        printf("[SYNTATIC] (function_declaration) type_identifier ID(%s)\n", $2);
    }
;

function_body:
	'{' statements '}' {
        printf("[SYNTATIC] (function_body) '{' statements '}'\n");
    }
    | error {
        printf("[SYNTATIC] ERROR function_body\n");
    }
;

parameters:
	parameters_list {
        printf("[SYNTATIC] (parameters) '(' parameters_list ')'\n");
    }
    | %empty {
       printf("[SYNTATIC] (parameters) VAZIO\n"); 
    }
    | error {
        printf("[SYNTATIC] ERROR parameters\n");
    }
;

parameters_list:
	parameters_list ',' parameter {
        printf("[SYNTATIC] (parameters_list) parameter ',' parameters_list\n");
    } 
	| parameter {
        printf("[SYNTATIC] (parameters_list) parameter\n");
    }
    | error {
        printf("[SYNTATIC] ERROR parameters_list\n");
    }
;

parameter:
	type_identifier ID {
        printf("[SYNTATIC] (parameter) type_identifier ID(%s)\n", $2);
    }
    | error {
        printf("[SYNTATIC] ERROR parameter\n");
    }
;

type_identifier:
	INT {
        printf("[SYNTATIC] type_identifier INT\n");
    }
    | FLOAT {
        printf("[SYNTATIC] type_identifier FLOAT\n");
    }
	| ELEM {
        printf("[SYNTATIC] type_identifier ELEM\n");
    }
    | SET{
        printf("[SYNTATIC] type_identifier SET\n");
    }
    | error {
        printf("[SYNTATIC] ERROR type_identifier\n");
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
    | %empty {
        printf("[SYNTATIC] (statements) empty\n");    
    }
    | error {
        printf("[SYNTATIC] ERROR (statements)\n");
    }
;

statements_braced:
    '{' statements '}' {
        printf("[SYNTATIC] (statements_braced) '{' statements '}'\n");
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
    | error {
        printf("[SYNTATIC] ERROR (statement)\n");
    }
;

set_pre_statement:
    set_statement_basic ';' {
        printf("[SYNTATIC] (set_pre_statement) set_statement_basic ';'\n");  
    }
    | set_statement_complex {
        printf("[SYNTATIC] (set_pre_statement) set_statement_complex\n");  
    }
    | error {
        printf("[SYNTATIC] ERROR set_pre_statement\n");
    }

;

set_statement_basic:
    SET_BASIC '(' set_expression ')' {
        printf("[SYNTATIC] (set_statement_basic) SET_BASIC(%s) '(' set_expression ')'\n", $1); 
    }
    | IS_SET '(' ID ')' {
        printf("[SYNTATIC] (set_statement_basic) IS_SET '(' ID(%s) ')'\n", $3);
    }
    | error {
        printf("[SYNTATIC] ERROR set_statement_basic\n");
    }
;

set_statement_complex:
    FOR_ALL '(' set_expression ')' statements {
        printf("[SYNTATIC] (set_statement_complex) FOR_ALL '(' set_expression ')' statements\n"); 
    }
    | error {
        printf("[SYNTATIC] ERROR set_statement_complex\n");
    }
;

set_expression:
    expression IN set_statement_basic {
        printf("[SYNTATIC] (set_expression) expression IN set_statement_basic\n");
    }
    | expression IN ID {
        printf("[SYNTATIC] (set_expression) expression IN ID(%s)\n", $3);
    }
    | error {
        printf("[SYNTATIC] ERROR set_expression\n");
    }
;

expression_statement:
    expression ';' {
        printf("[SYNTATIC] (expression_statement) expression\n");
    }
    | error {
        printf("[SYNTATIC] ERROR expression_statement\n");
    }
;

expression:
    '(' expression ')' {
        printf("[SYNTATIC] (expression) '(' expression ')'\n");
    }
    | expression_assignment {
        printf("[SYNTATIC] (expression) expression_assignment\n");
    }
    | error {
        printf("[SYNTATIC] ERROR expression\n");
    }
;

expression_assignment:
    ID ASSIGNMENT_OP expression {
         printf("[SYNTATIC] (expression_assignment) ID(%s) ASSIGNMENT_OP(=)  expression\n", $1);
    }
    | expression_logical {
        printf("[SYNTATIC] (expression) expression_logical\n");   
    }
;

expression_logical:
    '(' expression ')'{
        printf("[SYNTATIC] (expression_logical) '(' expression_logical ')' \n");
    }
    | expression_logical AND_OP expression_logical {
        printf("[SYNTATIC] (expression_logical) expression_logical AND_OP(&&) expression_logical\n");
    }
    | expression_logical OR_OP expression_logical {
        printf("[SYNTATIC] (expression_logical) expression_logical OR_OP(||) expression_logical\n");
    }
    | set_expression {
        printf("[SYNTATIC] (expression_logical) set_expression\n");
    }
    | expression_relational {
        printf("[SYNTATIC] (expression_logical) expression_relational\n");
    }
    | error {
        printf("[SYNTATIC] ERROR expression_logical\n");
    }
;

expression_relational:
    '(' expression ')'{
        printf("[SYNTATIC] (expression_relational) '(' expression_relational ')' \n");
    }
    | expression_relational RELATIONAL_OP expression_relational {
        printf("[SYNTATIC] (expression_relational) expression_relational RELATIONAL_OP(%s) expression_relational\n", $2);
    }
    | expression_multiplicative {
        printf("[SYNTATIC] (expression_relational) expression_multiplicative \n");
    }
    | error {
        printf("[SYNTATIC] ERROR expression_relational\n");
    }
;

expression_multiplicative:
    '(' expression ')'{
        printf("[SYNTATIC] (expression_multiplicative) '(' expression_multiplicative ')' \n");
    }
    | expression_multiplicative MULTIPLICATIVE_OP expression_multiplicative {
        printf("[SYNTATIC] (expression_multiplicative)  expression_multiplicative MULTIPLICATIVE_OP(%s) expression_multiplicative \n", $2);
    }
    | expression_additive {
        printf("[SYNTATIC] (expression_multiplicative) expression_additive \n");
    }
    | error {
        printf("[SYNTATIC] ERROR expression_multiplicative\n");
    }
;

expression_additive:
    '(' expression ')'{
        printf("[SYNTATIC] (expression_additive) '(' expression_additive ')' \n");
    }
    | expression_additive ADDITIVE_OP expression_additive {
        printf("[SYNTATIC] (expression_additive) expression_additive ADDITIVE_OP(%s) expression_additive \n", $2);
    }
    | expression_value {
        printf("[SYNTATIC] (expression_additive) expression_value \n");
    }
    | error {
        printf("[SYNTATIC] ERROR expression_additive\n");
    }
;

expression_value:
    '(' expression ')'{
        printf("[SYNTATIC] (expression_value) '(' expression_value ')' \n");
    }
    | value {
        printf("[SYNTATIC] (expression_value) value \n");
    }
    | '-' value {
        printf("[SYNTATIC] (expression_value) - value \n");
    }
    | error {
        printf("[SYNTATIC] ERROR functexpression_valueion_body\n");
    }
;


for:
    FOR '(' for_expression ')' statements {
        printf("[SYNTATIC] (for) FOR '(' for_expression ')' statement\n");
    }
    | error {
        printf("[SYNTATIC] ERROR for\n");
    }
;

for_expression:
    expression_assignment ';' expression_logical ';' expression_assignment {
        printf("[SYNTATIC] (for_expression) expression_assignment ';' expression_logical ';' expression_assignment\n");
    }
    | expression_assignment ';' expression_logical ';' {
        printf("[SYNTATIC] (for_expression) expression_assignment ';' expression_logical ';' empty \n");
    }
    | error {
        printf("[SYNTATIC] ERROR for_expression\n");
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
    | error {
        printf("[SYNTATIC] ERROR io_statement\n");
    }
;

arguments_list:
    arguments_list ',' value {
        printf("[SYNTATIC] (arguments_list) arguments_list value\n");
    }
    | value {
        printf("[SYNTATIC] (arguments_list) value\n");
    }
    | error {
        printf("[SYNTATIC] ERROR arguments_list:\n");
    }
;

conditional:
    IF conditional_expression statements {
        printf("[SYNTATIC] (conditional) IF conditional_expression statements\n");
    }
    | IF conditional_expression statements_braced ELSE statements_braced {
        printf("[SYNTATIC] (conditional) IF conditional_expression statements_braced ELSE statements_braced\n");
    }
    | error {
        printf("[SYNTATIC] ERROR conditional\n");
    }
;

conditional_expression:
    '(' expression ')' {
        printf("[SYNTATIC] (conditional_expression) '(' expression ')'\n");
    }
    | error {
        printf("[SYNTATIC] ERROR conditional_expression\n");
    }
;

return:
    RETURN value ';' {
        printf("[SYNTATIC] (return) RETURN value ';'\n");
    }
    | RETURN ';' {
        printf("[SYNTATIC] (return) RETURN ';'\n");
    }
    | error {
        printf("[SYNTATIC] ERROR return\n");
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
    | error {
        printf("[SYNTATIC] ERROR value\n");
    }    
;

function_call_statement:
    function_call ';' {
        printf("[SYNTATIC] (function_call_statement) function_call ';'\n");
    }
    | error {
        printf("[SYNTATIC] ERROR function_call_statement\n");
    }    
;

function_call:
    ID '(' arguments_list ')' {
        printf("[SYNTATIC] (function_call) ID(%s) '(' arguments_list ')'\n", $1);
    }
    | ID '(' ')' {
        printf("[SYNTATIC] (function_call) ID(%s) '(' ')'\n", $1);
    }
    | error {
        printf("[SYNTATIC] ERROR function_call\n");
    }    
;

variables_declaration:
    type_identifier ID ';' {
        printf("[SYNTATIC] (variables_declaration) type_identifier ID(%s) ';'\n", $2);
    }
    | error {
        printf("[SYNTATIC] ERROR variables_declaration\n");
    }    
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
    | error {
        printf("[SYNTATIC] ERROR const\n");
    }
;

%%

int yyerror(const char* message){
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
    yyparse();
    printf("\n");
    if(errors > 0){
        printf("Program analysis failed!\nLexical analysis terminated with %d error(s)\n", errors);
    }
    else{
        printf("Correct program.\n");
    }
    // fclose(yyin);
    yylex_destroy();
    return 0;
}
