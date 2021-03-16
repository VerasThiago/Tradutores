%define lr.type canonical-lr
%error-verbose
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
%token T_Else
%token T_LeftBrace
%token T_LeftParentheses
%token T_Period
%token T_RightBrace
%token T_RightParentheses
%token T_Semicolon
%token T_Set
%token LOGICAL_AND_OP
%token LOGICAL_OR_OP
%token T_SET_OPERATION_1
%token T_SET_OPERATION_2
%token T_SET_OPERATION_3
%token T_For
%token T_Return
%token T_Write
%token T_Writeln
%token T_Read
%token T_Empty
%token T_Type_Float
%token T_Type_Int

%token <body> ENUMERATOR_OP
%token <body> T_Integer
%token <body> T_Float
%token <body> T_Basic_type
%token <body> T_Id
%token <body> RELATIONAL_OP
%token <body> MULTIPLICATIVE_OP
%token <body> ADDITIVE_OP
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
    | error {
        printf("[SYNTATIC] ERROR program\n");
    }
	| function_definition program {}
	| variables_declaration program {}
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
        printf("[SYNTATIC] (function_declaration) type_identifier T_Id\n");
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
	T_LeftParentheses parameters_list T_RightParentheses {}
    | T_LeftParentheses T_RightParentheses {}
    | %empty {}
    | error {
        printf("[SYNTATIC] ERROR parameters\n");
    }
;

parameters_list:
	parameter T_Comma parameters_list {} 
	| parameter {}
    | %empty {}
    | error {
        printf("[SYNTATIC] ERROR parameters_list\n");
    }
;

parameter:
	type_identifier T_Id {}
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
	| T_Elem {}
    | T_Set {}
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
    | T_LeftBrace statements T_RightBrace {
        printf("[SYNTATIC] (statements) T_LeftBrace statements T_RightBrace\n");
    }
    | %empty {
        printf("[SYNTATIC] (statements) empty\n");    
    }
    | expression_statement statements {
        printf("[SYNTATIC] (statements) expression_statement statements\n");    
    }
    | error {
        printf("[SYNTATIC] ERROR (statements)\n");
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
	| for {}
	| expression_statement T_Semicolon {}
	| io_statement {}
	| set_statement {}
    | error {
        printf("[SYNTATIC] ERROR (statement)\n");
    }
;

set_statement:
    T_SET_OPERATION_1 T_LeftParentheses T_Id T_RightParentheses T_Semicolon {}
    | T_SET_OPERATION_1 T_LeftParentheses set_expression T_RightParentheses T_Semicolon {}
    | T_SET_OPERATION_2 T_LeftParentheses T_Id T_SET_OPERATION_3 set_expression T_RightParentheses statement {}
    | error {
        printf("[SYNTATIC] ERROR set_statement\n");
    }
;

set_expression:
    T_SET_OPERATION T_LeftParentheses T_SET_OPERATION_3 set_expression T_RightParentheses statement {}
    | error {
        printf("[SYNTATIC] ERROR functset_expressionion_body\n");
    }
;

expression_statement:
    expression T_Semicolon
    | T_Semicolon
    | error {
        printf("[SYNTATIC] ERROR expression_statement\n");
    }
;

expression:
    expression ENUMERATOR_OP expression {
        printf("EXP %s EXP\n", $2);
    }
    | expression_logical {
        printf("[SYNTATIC] (statexpressionement) expression_logical\n");   
    }
    | error {
        printf("[SYNTATIC] ERROR expression\n");
    }
;

expression_logical: 
    expression_logical LOGICAL_AND_OP expression_logical {}
    | expression_logical LOGICAL_OR_OP expression_logical {}
    | expression_relational {
        printf("[SYNTATIC] (expression_logical) expression_relational\n");
    }
    | error {
        printf("[SYNTATIC] ERROR expression_logical\n");
    }
;

expression_relational:
    expression_relational RELATIONAL_OP expression_relational {
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
    expression_multiplicative MULTIPLICATIVE_OP expression_multiplicative {}
    | expression_additive {
        printf("[SYNTATIC] (expression_multiplicative) expression_additive \n");
    }
    | error {
        printf("[SYNTATIC] ERROR expression_multiplicative\n");
    }
;

expression_additive:
    expression_additive ADDITIVE_OP expression_additive {}
    | expression_value {
        printf("[SYNTATIC] (expression_additive) expression_value \n");
    }
    | error {
        printf("[SYNTATIC] ERROR expression_additive\n");
    }
;

expression_value:
    value {
        printf("[SYNTATIC] (expression_value) value \n");
    }
    | "-" value {}
    | error {
        printf("[SYNTATIC] ERROR functexpression_valueion_body\n");
    }
;

expression_empty:
    expression {}
    | %empty {}
    | error {
        printf("[SYNTATIC] ERROR expression_empty\n");
    }
;

for:
    T_For T_LeftParentheses for_expression T_RightParentheses statement {}
    | T_For T_LeftParentheses for_expression T_RightParentheses T_LeftBrace statement T_RightBrace {}
    | error {
        printf("[SYNTATIC] ERROR for\n");
    }
;

for_expression:
    expression_empty T_Semicolon expression_empty T_Semicolon expression_empty {}
    | error {
        printf("[SYNTATIC] ERROR for_expression\n");
    }
;

io_statement:
    T_Read T_LeftParentheses T_Id T_RightParentheses T_Semicolon {}
    | T_Write T_LeftParentheses T_String T_RightParentheses T_Semicolon {}
    | T_Write T_LeftParentheses expression T_RightParentheses T_Semicolon {}
    | T_Writeln T_LeftParentheses T_String T_RightParentheses T_Semicolon {}
    | T_Writeln T_LeftParentheses expression T_RightParentheses T_Semicolon {}
    | error {
        printf("[SYNTATIC] ERROR io_statement\n");
    }
;

arguments_list:
    arguments_list T_Comma value {}
    | value {}
    | error {
        printf("[SYNTATIC] ERROR arguments_list:\n");
    }
;

conditional:
    T_If conditional_expression statements {
        printf("[SYNTATIC] (conditional) conditional_expression statements\n");
    }
    | T_If conditional_expression statement T_Else statements {}
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
    | T_Return T_Semicolon {}
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
    | function_call {}
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
        printf("[SYNTATIC] (variables_declaration) type_identifier T_Id T_Semicolon\n");
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
