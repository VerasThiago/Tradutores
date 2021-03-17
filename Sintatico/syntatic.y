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

%token T_Comma
%token T_Assignment
%token T_Elem
%token T_If
%nonassoc T_Else
%token T_LeftBrace
%token T_LeftParentheses
%token T_Period
%token T_RightBrace
%token T_RightParentheses
%token T_Semicolon
%token T_Set
%token LOGICAL_AND_OP
%token LOGICAL_OR_OP
%token T_For
%token T_Return
%token T_Write
%token T_Writeln
%token T_Read
%token T_Empty
%token T_Type_Float
%token T_Type_Int
%token T_SetForAll
%token T_SetIsSet
%token T_SetIn

%token <body> T_SetBasic
%token <body> ENUMERATOR_OP
%token <body> T_Integer
%token <body> T_Float
%token <body> T_Basic_type
%token <body> T_Id
%left <body> RELATIONAL_OP
%left <body> MULTIPLICATIVE_OP
%left <body> ADDITIVE_OP
%token <body> T_String
%token <body> T_SET_OPERATION


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
	function_declaration T_LeftParentheses parameters T_RightParentheses function_body {
        printf("[SYNTATIC] (function_definition) function_declaration T_LeftParentheses parameters T_RightParentheses function_body\n");
    }
    | error {
        printf("[SYNTATIC] ERROR function_definition\n");
    }
;

function_declaration:
	type_identifier T_Id {
        printf("[SYNTATIC] (function_declaration) type_identifier T_Id(%s)\n", $2);
    }
;

function_body:
	T_LeftBrace statements T_RightBrace {
        printf("[SYNTATIC] (function_body) T_LeftBrace statements T_RightBrace\n");
    }
    | error {
        printf("[SYNTATIC] ERROR function_body\n");
    }
;

parameters:
	parameters_list {
        printf("[SYNTATIC] (parameters) T_LeftParentheses parameters_list T_RightParentheses\n");
    }
    | %empty {
       printf("[SYNTATIC] (parameters) VAZIO\n"); 
    }
    | error {
        printf("[SYNTATIC] ERROR parameters\n");
    }
;

parameters_list:
	parameters_list T_Comma parameter {
        printf("[SYNTATIC] (parameters_list) parameter T_Comma parameters_list\n");
    } 
	| parameter {
        printf("[SYNTATIC] (parameters_list) parameter\n");
    }
    | error {
        printf("[SYNTATIC] ERROR parameters_list\n");
    }
;

parameter:
	type_identifier T_Id {
        printf("[SYNTATIC] (parameter) type_identifier T_Id(%s)\n", $2);
    }
    | error {
        printf("[SYNTATIC] ERROR parameter\n");
    }
;

type_identifier:
	T_Type_Int {
        printf("[SYNTATIC] type_identifier INT\n");
    }
    | T_Type_Float {
        printf("[SYNTATIC] type_identifier FLOAT\n");
    }
	| T_Elem {
        printf("[SYNTATIC] type_identifier ELEM\n");
    }
    | T_Set {
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
    T_LeftBrace statements T_RightBrace {
        printf("[SYNTATIC] (statements_braced) T_LeftBrace statements T_RightBrace\n");
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
        printf("[SYNTATIC] (statement) FOR\n");   
    }
	| expression_statement T_Semicolon {
        printf("[SYNTATIC] (statement) expression_statement T_Semicolon\n");   
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
    set_statement_basic T_Semicolon {
        printf("[SYNTATIC] (set_pre_statement) set_statement_basic T_Semicolon\n");  
    }
    | set_statement_complex {
        printf("[SYNTATIC] (set_pre_statement) set_statement_complex\n");  
    }
    | error {
        printf("[SYNTATIC] ERROR set_pre_statement\n");
    }

;

set_statement_basic:
    T_SetBasic T_LeftParentheses set_expression T_RightParentheses {
        printf("[SYNTATIC] (set_statement_basic) T_SetBasic(%s) T_LeftParentheses set_expression T_RightParentheses\n", $1); 
    }
    | T_SetIsSet T_LeftParentheses T_Id T_RightParentheses {
        printf("[SYNTATIC] (set_statement_basic) T_SetIsSet T_LeftParentheses T_Id(%s) T_RightParentheses\n", $3);
    }
    | error {
        printf("[SYNTATIC] ERROR set_statement_basic\n");
    }
;

set_statement_complex:
    T_SetForAll T_LeftParentheses set_expression T_RightParentheses statements {
        printf("[SYNTATIC] (set_statement_complex) T_SetForAll T_LeftParentheses set_expression T_RightParentheses statements\n"); 
    }
    | error {
        printf("[SYNTATIC] ERROR set_statement_complex\n");
    }
;

set_expression:
    expression T_SetIn set_statement_basic {
        printf("[SYNTATIC] (set_expression) expression T_SetIn set_statement_basic\n");
    }
    | expression T_SetIn T_Id {
        printf("[SYNTATIC] (set_expression) expression T_SetIn T_id(%s)\n", $3);
    }
    | error {
        printf("[SYNTATIC] ERROR set_expression\n");
    }
;

expression_statement:
    expression {
        printf("[SYNTATIC] (expression_statement) expression\n");
    }
    | error {
        printf("[SYNTATIC] ERROR expression_statement\n");
    }
;

expression:
    T_LeftParentheses expression T_RightParentheses {
        printf("[SYNTATIC] (expression) T_LeftParentheses expression T_RightParentheses\n");
    }
    | expression_assignment {
        printf("[SYNTATIC] (expression) expression_assignment\n");
    }
    | error {
        printf("[SYNTATIC] ERROR expression\n");
    }
;

expression_assignment:
    T_Id ENUMERATOR_OP expression {
         printf("[SYNTATIC] (expression_assignment) T_Id(%s) ENUMERATOR_OP(=)  expression\n", $1);
    }
    | expression_logical {
        printf("[SYNTATIC] (expression) expression_logical\n");   
    }
;

expression_logical:
    T_LeftParentheses expression T_RightParentheses{
        printf("[SYNTATIC] (expression_logical) T_LeftParentheses expression_logical T_RightParentheses \n");
    }
    | expression_logical LOGICAL_AND_OP expression_logical {
        printf("[SYNTATIC] (expression_logical) expression_logical LOGICAL_AND_OP(&&) expression_logical\n");
    }
    | expression_logical LOGICAL_OR_OP expression_logical {
        printf("[SYNTATIC] (expression_logical) expression_logical LOGICAL_OR_OP(||) expression_logical\n");
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
    T_LeftParentheses expression T_RightParentheses{
        printf("[SYNTATIC] (expression_relational) T_LeftParentheses expression_relational T_RightParentheses \n");
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
    T_LeftParentheses expression T_RightParentheses{
        printf("[SYNTATIC] (expression_multiplicative) T_LeftParentheses expression_multiplicative T_RightParentheses \n");
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
    T_LeftParentheses expression T_RightParentheses{
        printf("[SYNTATIC] (expression_additive) T_LeftParentheses expression_additive T_RightParentheses \n");
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
    T_LeftParentheses expression T_RightParentheses{
        printf("[SYNTATIC] (expression_value) T_LeftParentheses expression_value T_RightParentheses \n");
    }
    | value {
        printf("[SYNTATIC] (expression_value) value \n");
    }
    | "-" value {}
    | error {
        printf("[SYNTATIC] ERROR functexpression_valueion_body\n");
    }
;


for:
    T_For T_LeftParentheses for_expression T_RightParentheses statements {
        printf("[SYNTATIC] (for) T_For T_LeftParentheses for_expression T_RightParentheses statement\n");
    }
    | error {
        printf("[SYNTATIC] ERROR for\n");
    }
;

for_expression:
    expression_assignment T_Semicolon expression_logical T_Semicolon expression_assignment {
        printf("[SYNTATIC] (for_expression) expression_assignment T_Semicolon expression_logical T_Semicolon expression_assignment\n");
    }
    | expression_assignment T_Semicolon expression_logical T_Semicolon {
        printf("[SYNTATIC] (for_expression) expression_assignment T_Semicolon expression_logical T_Semicolon empty \n");
    }
    | error {
        printf("[SYNTATIC] ERROR for_expression\n");
    }
;

io_statement:
    T_Read T_LeftParentheses T_Id T_RightParentheses T_Semicolon {
        printf("[SYNTATIC] (io_statement) T_Read T_LeftParentheses T_Id(%s) T_RightParentheses T_Semicolon\n", $3);
    }
    | T_Write T_LeftParentheses T_String T_RightParentheses T_Semicolon {
        printf("[SYNTATIC] (io_statement) T_Write T_LeftParentheses T_String(%s) T_RightParentheses T_Semicolon\n", $3);
    }
    | T_Write T_LeftParentheses expression T_RightParentheses T_Semicolon {
        printf("[SYNTATIC] (io_statement) T_Write T_LeftParentheses expression T_RightParentheses T_Semicolon\n");
    }
    | T_Writeln T_LeftParentheses T_String T_RightParentheses T_Semicolon {
        printf("[SYNTATIC] (io_statement) T_Writeln T_LeftParentheses T_String(%s) T_RightParentheses T_Semicolon\n", $3);
    }
    | T_Writeln T_LeftParentheses expression T_RightParentheses T_Semicolon {
        printf("[SYNTATIC] (io_statement) T_Writeln T_LeftParentheses expression T_RightParentheses T_Semicolon\n");
    }
    | error {
        printf("[SYNTATIC] ERROR io_statement\n");
    }
;

arguments_list:
    arguments_list T_Comma value {
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
    T_If conditional_expression statements {
        printf("[SYNTATIC] (conditional) T_If conditional_expression statements\n");
    }
    | T_If conditional_expression statements_braced T_Else statements_braced {
        printf("[SYNTATIC] (conditional) T_If conditional_expression statements_braced T_Else statements_braced\n");
    }
    | error {
        printf("[SYNTATIC] ERROR conditional\n");
    }
;

conditional_expression:
    T_LeftParentheses expression T_RightParentheses {
        printf("[SYNTATIC] (conditional_expression) T_LeftParentheses expression T_RightParentheses\n");
    }
    | error {
        printf("[SYNTATIC] ERROR conditional_expression\n");
    }
;

return:
    T_Return value T_Semicolon {
        printf("[SYNTATIC] (return) T_Return value T_Semicolon\n");
    }
    | T_Return T_Semicolon {
        printf("[SYNTATIC] (return) T_Return T_Semicolon\n");
    }
    | error {
        printf("[SYNTATIC] ERROR return\n");
    }
;

value:
    T_Id {
        printf("[SYNTATIC] (value) T_Id = %s\n", $1);
    }
    | const {
        printf("[SYNTATIC] (value) const\n");
    }
    | function_call {

    }
    | error {
        printf("[SYNTATIC] ERROR value\n");
    }    
;

function_call:
    T_Id T_LeftParentheses arguments_list T_RightParentheses {}
    | T_Id T_LeftParentheses T_RightParentheses {}
    | error {
        printf("[SYNTATIC] ERROR function_call\n");
    }    
;

variables_declaration:
    type_identifier T_Id T_Semicolon {
        printf("[SYNTATIC] (variables_declaration) type_identifier T_Id(%s) T_Semicolon\n", $2);
    }
    | error {
        printf("[SYNTATIC] ERROR variables_declaration\n");
    }    
;

const:
    T_Integer {
        printf("[SYNTATIC] (const) T_Integer = %s\n", $1);
    }
    | T_Float {
        printf("[SYNTATIC] (const) T_Float = %s\n", $1);
    }
    | T_Empty {
        printf("[SYNTATIC] (const) T_Empty\n");
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
