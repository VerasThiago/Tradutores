%define parse.error verbose
%define parse.lac none
%define api.pure
%debug
%defines

%{

%}

%token <token> T_Basic_type
%token <token> T_Comma
%token <token> T_Assignment
%token <token> T_Elem
%token <token> T_If
%token <token> T_Else
%token <token> T_Empty
%token <token> T_Id
%token <token> T_LeftBrace
%token <token> T_LeftParentheses
%token <token> T_Period
%token <token> T_RightBrace
%token <token> T_RightParentheses
%token <token> T_Semicolon
%token <token> T_Set
%token <token> digit
%token <token> ENUMERATOR_OP
%token <token> LOGICAL_AND_OP
%token <token> LOGICAL_OR_OP
%token <token> RELATIONAL_OP
%token <token> MULTIPLICATIVE_OP
%token <token> ADDITIVE_OP
%token <token> T_String
%token <token> identifiers_list
%token <token> T_SET_OPERATION
%token <token> T_SET_OPERATION_1
%token <token> T_SET_OPERATION_2
%token <token> T_SET_OPERATION_3
%token <token> T_For
%token <token> T_Return
%token <token> T_Write
%token <token> T_Writeln
%token <token> T_Read
%token <token> T_In


%start start

%%

start:
	program {}

program:
	function_definition {}
	| function_definition program {}
	| variables_declaration program {}
    
function_definition:
	function_declaration parameters function_body {}

function_declaration:
	type_identifier T_Id {}

function_body:
	T_LeftBrace statements T_RightBrace {}

parameters:
	T_LeftParentheses parameters_list T_RightParentheses {}
    | T_LeftParentheses T_RightParentheses {}

parameters_list:
	parameter T_Comma parameters_list {} 
	| parameter {}

parameter:
	type_identifier T_Id {}
	

type_identifier:
	T_Basic_type {}
	| T_Elem {}
    | T_Set {}

statements:
	statement statements {}
	| statement {}
    | T_LeftBrace statements T_RightBrace {}

statement:
	variables_declaration {}
	| return {}
	| conditional {}
	| for {}
	| expression_statement T_Semicolon {}
	| io_statement {}
	| set_statement {}

set_statement:
    T_SET_OPERATION_1 T_LeftParentheses T_Id T_RightParentheses T_Semicolon {}
    | T_SET_OPERATION_1 T_LeftParentheses set_expression T_RightParentheses T_Semicolon {}
    | T_SET_OPERATION_2 T_LeftParentheses T_Id T_SET_OPERATION_3 set_expression T_RightParentheses statement {}

set_expression:
    T_SET_OPERATION T_LeftParentheses T_SET_OPERATION_3 set_expression T_RightParentheses statement {}

expression_statement:
    expression T_Semicolon
    | T_Semicolon

expression:
    expression ENUMERATOR_OP expression {}
    | expression_logical {}

expression_logical: 
    expression_logical LOGICAL_AND_OP expression_logical {}
    | expression_logical LOGICAL_OR_OP expression_logical {}
    | expression_relational {}

expression_relational:
    expression_relational RELATIONAL_OP expression_relational {}
    | expression_multiplicative {}


expression_multiplicative:
    expression_multiplicative MULTIPLICATIVE_OP expression_multiplicative {}
    | expression_additive {}

expression_additive:
    expression_additive ADDITIVE_OP expression_additive {}
    | expression_value {}

expression_value:
    value {}
    | "-" value {}

expression_empty:
    expression {}
    | %empty {}

for:
    T_For T_LeftParentheses for_expression T_RightParentheses statement {}
    | T_For T_LeftParentheses for_expression T_RightParentheses T_LeftBrace statement T_RightBrace {}

for_expression:
    expression_empty T_Semicolon expression_empty T_Semicolon expression_empty {}

io_statement:
    T_Read T_LeftParentheses T_Id T_RightParentheses T_Semicolon {}
    | T_Write T_LeftParentheses T_String T_RightParentheses T_Semicolon {}
    | T_Write T_LeftParentheses expression T_RightParentheses T_Semicolon {}
    | T_Writeln T_LeftParentheses T_String T_RightParentheses T_Semicolon {}
    | T_Writeln T_LeftParentheses expression T_RightParentheses T_Semicolon {}

arguments_list:
    arguments_list T_Comma value {}
    | value {}

conditional:
    T_If conditional_expression statements {}
    | T_If conditional_expression statement T_Else statements {}

conditional_expression:
    T_LeftParentheses expression T_RightBrace {}

return:
    T_Return value T_Semicolon {}
    | T_Return T_Semicolon {}

value:
    T_Id {}
    | const {}
    | function_call {}

function_call:
    T_Id T_LeftParentheses arguments_list T_RightParentheses {}
    | T_Id T_LeftParentheses T_RightParentheses {}

variables_declaration:
    type_identifier identifiers_list T_Semicolon {}

const:
    T_Integer {}
    | T_Float {}
    | T_Empty {}

T_Integer: 
    digit T_Integer_Aux {}

T_Integer_Aux:
    digit T_Integer_Aux {}
    | %empty {}

T_Float:
    digit T_Period digit {}

%%
