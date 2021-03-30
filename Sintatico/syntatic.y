%define lr.type canonical-lr
%define parse.error verbose
%debug
%locations



%{
    #include <stdlib.h>
    #include <stdio.h>
    #include <string.h>
    #include "stack.h"
    #include "table.h"
    #include "tree.h"

    extern int yylex();
    extern int yyparse();
    extern int yyerror(const char* message);
    extern int yylex_destroy();
    extern FILE* yyin;

%}

%union {
	char body[2000];
    struct TreeNode *node;
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
%token <body> STRING

%left <body> RELATIONAL_OP
%left <body> MULTIPLICATIVE_OP
%left <body> ADDITIVE_OP

%type <node> start
%type <node> program
%type <node> function_definition
%type <node> function_declaration
%type <node> function_body
%type <node> parameters
%type <node> parameters_list
%type <node> parameter
%type <node> type_identifier
%type <node> statements
%type <node> statements_braced
%type <node> statement
%type <node> set_pre_statement
%type <node> set_statement_add_remove
%type <node> set_statement_for_all
%type <node> set_statement_exists
%type <node> set_boolean_expression
%type <node> set_assignment_expression
%type <node> expression_statement
%type <node> expression
%type <node> expression_assignment
%type <node> expression_logical
%type <node> expression_relational
%type <node> expression_additive
%type <node> expression_multiplicative
%type <node> expression_value
%type <node> is_set_statement
%type <node> is_set_expression
%type <node> for
%type <node> for_expression
%type <node> io_statement
%type <node> arguments_list
%type <node> conditional
%type <node> conditional_expression
%type <node> return
%type <node> value
%type <node> function_call_statement
%type <node> function_call
%type <node> variables_declaration
%type <node> const


%start start

%%

start:
	program {
        printf("[SYNTATIC] (start) program\n");
        $$ = createNode("start");
        $$->children = $1;

        root = $$;

    }
;

program:
	function_definition {
        printf("[SYNTATIC] (program) function_definition\n");
        $$ = createNode("program");
        $$->children = $1;
    }
	| function_definition program {
        printf("[SYNTATIC] (program) function_definition program\n");

        $$ = createNode("program");
        $$->children = $1;
        $1->nxt = $2;
    }
	| variables_declaration program {
        printf("[SYNTATIC] (program) variables_declaration program\n");

        $$ = createNode("program");
        $$->children = $1;
        $1->nxt = $2;
    }
;

function_definition:
	function_declaration '(' parameters ')' function_body {
        printf("[SYNTATIC] (function_definition) function_declaration '(' parameters ')' function_body\n");
        
        $$ = createNode("function_definition");
        $$->children = $1;
        $1->nxt = $3;
        $3->nxt = $5;
    }
    | function_declaration '(' ')' function_body {
        printf("[SYNTATIC] (function_definition) function_declaration '(' ')' function_body\n");
        
        $$ = createNode("function_definition");
        $$->children = $1;
        $1->nxt = $4;
    }
    | error {}
;

function_declaration:
	type_identifier ID {
        push_back(&tableList, createSymbol(lines, columns - strlen($2), "function", lastType, $2));
        printf("[SYNTATIC] (function_declaration) type_identifier ID(%s)\n", $2);

        $$ = createNode("function_declaration");
        $$->children = $1;
        $$->symbol = createSymbol(lines, columns, "variable", lastType, $2);
    }
;

function_body:
	'{' statements '}' {
        printf("[SYNTATIC] (function_body) '{' statements '}'\n");

        $$ = createNode("function_body");
        $$->children = $2;
    }
    | '{' '}' {
        printf("[SYNTATIC] (function_body) '{' '}'\n");

        $$ = createNode("function_body");
    }
;

parameters:
	parameters_list {
        printf("[SYNTATIC] (parameters)  parameters_list \n");

        $$ = createNode("parameters_list");
        $$->children = $1;
    }
;

parameters_list:
	parameters_list ',' parameter {
        printf("[SYNTATIC] (parameters_list) parameter ',' parameters_list\n");

        $$ = createNode("parameters_list");
        $$->children = $1;
        $1->nxt = $3;
        
    } 
	| parameter {
        printf("[SYNTATIC] (parameters_list) parameter\n");

        $$ = createNode("parameters_list");
        $$->children = $1;
    }
;

parameter:
	type_identifier ID {
        printf("[SYNTATIC] (parameter) type_identifier ID(%s)\n", $2);

        $$ = createNode("parameter");
        $$->children = $1;
        $$->symbol = createSymbol(lines, columns, "variable", lastType, $2);
    }
;

type_identifier:
	INT {
        printf("[SYNTATIC] (type_identifier) INT\n");

        $$ = createNode("type_identifier");
        
        strcpy(lastType, "int");

    }
    | FLOAT {
        printf("[SYNTATIC] (type_identifier) FLOAT\n");

        $$ = createNode("type_identifier");

        strcpy(lastType, "float");

    }
	| ELEM {
        printf("[SYNTATIC] (type_identifier) ELEM\n");

        $$ = createNode("type_identifier");

        strcpy(lastType, "elem");

    }
    | SET{
        printf("[SYNTATIC] (type_identifier) SET\n");

        $$ = createNode("type_identifier");

        strcpy(lastType, "set");

    }
;

statements:
	statement statements {
        printf("[SYNTATIC] (statements) statement statements\n");

        $$ = createNode("statements");
        $$->children = $1;
        $1->nxt = $2;
    }
	| statement {
        printf("[SYNTATIC] (statements) statement\n");   

        $$ = createNode("statements");
        $$->children = $1;
    }
    | statements_braced {
        printf("[SYNTATIC] (statements) statements_braced\n");

        $$ = createNode("statements");
        $$->children = $1;
    }
;

statements_braced:
    '{' statements '}' {
        printf("[SYNTATIC] (statements_braced) '{' statements '}'\n");

        $$ = createNode("statements_braced");
        $$->children = $2;
    }
    | '{' '}' {
        printf("[SYNTATIC] (statements_braced) '{' '}'\n");

        $$ = createNode("statements_braced");
    }
;

statement:
	variables_declaration {
        printf("[SYNTATIC] (statement) variables_declaration\n");

        $$ = createNode("statement");
        $$->children = $1;   
    }
	| return {
        printf("[SYNTATIC] (statement) return\n");

        $$ = createNode("statement");
        $$->children = $1;    
    }
	| conditional {
        printf("[SYNTATIC] (statement) conditional\n");   

        $$ = createNode("statement");
        $$->children = $1;  
    }
	| for {
        printf("[SYNTATIC] (statement) for\n");

        $$ = createNode("statement");
        $$->children = $1;   
    }
    | is_set_statement {
        printf("[SYNTATIC] (statement) is_set_statement\n"); 

        $$ = createNode("statement");
        $$->children = $1;  
    }
    | function_call_statement {
        printf("[SYNTATIC] (statement) function_call_statement\n"); 

        $$ = createNode("statement");
        $$->children = $1; 
    }
	| expression_statement {
        printf("[SYNTATIC] (statement) expression_statement \n");

        $$ = createNode("statement");
        $$->children = $1;   
    }
	| io_statement {
        printf("[SYNTATIC] (statement) io_statement\n");

        $$ = createNode("statement");
        $$->children = $1;  
    }
	| set_pre_statement {
        printf("[SYNTATIC] (statement) set_pre_statement\n");

        $$ = createNode("statement");
        $$->children = $1;  
    }
;

set_pre_statement:
    set_statement_add_remove ';' {
        printf("[SYNTATIC] (set_pre_statement) set_statement_add_remove ';'\n");  

        $$ = createNode("set_pre_statement");
        $$->children = $1;
    }
    | set_statement_for_all {
        printf("[SYNTATIC] (set_pre_statement) set_statement_for_all\n");  

        $$ = createNode("set_pre_statement");
        $$->children = $1;
    }
;

set_statement_add_remove:
    ADD '(' set_boolean_expression ')' {
        printf("[SYNTATIC] (set_statement_add_remove) ADD '(' set_boolean_expression ')'\n"); 
        
        $$ = createNode("set_statement_add_remove");
        $$->children = $3;
        $$->symbol = createSymbol(lines, columns, "set operation", "", "add");
    }
    | REMOVE '(' set_boolean_expression ')' {
        printf("[SYNTATIC] (set_statement_add_remove) REMOVE '(' set_boolean_expression ')'\n"); 

        $$ = createNode("set_statement_add_remove");
        $$->children = $3;
        $$->symbol = createSymbol(lines, columns, "set operation", "", "remove");
    }
;

set_statement_for_all:
    FOR_ALL '(' set_assignment_expression ')' statements {
        printf("[SYNTATIC] (set_statement_for_all) FOR_ALL '(' set_assignment_expression ')' statements\n"); 

        $$ = createNode("set_statement_for_all");
        $$->children = $3;
        $3->nxt = $5;
    }
;

set_statement_exists:
    EXISTS '(' set_assignment_expression ')' {
        printf("[SYNTATIC] (set_statement_exists) EXISTS '(' set_assignment_expression ')'\n"); 

        $$ = createNode("set_statement_exists");
        $$->children = $3;
    }
;

set_boolean_expression:
    expression IN set_statement_add_remove {
        printf("[SYNTATIC] (set_boolean_expression) expression IN set_statement_add_remove\n");

        $$ = createNode("set_boolean_expression");
        $$->children = $1;
        $1->nxt = $3;
    }
    | expression IN ID {
        printf("[SYNTATIC] (set_boolean_expression) expression IN ID(%s)\n", $3);

        $$ = createNode("set_boolean_expression");
        $$->children = $1;
    }
;

set_assignment_expression:
    ID IN set_statement_add_remove {
        printf("[SYNTATIC] (set_assignment_expression) expression IN set_statement_add_remove\n");

        $$ = createNode("set_assignment_expression");
        $$->children = $3;
    }
    | ID IN ID {
        printf("[SYNTATIC] (set_assignment_expression) ID(%s) IN ID(%s)\n", $1, $3);

        $$ = createNode("set_assignment_expression");
        $$->symbol = createSymbol(lines, columns, "variable", lastType, $1);
    }
;

expression_statement:
    expression ';' {
        printf("[SYNTATIC] (expression_statement) expression\n");

        $$ = createNode("expression_statement");
        $$->children = $1;
    }
;

expression:
    expression_assignment {
        printf("[SYNTATIC] (expression) expression_assignment\n");

        $$ = createNode("expression");
        $$->children = $1;
    }
;

expression_assignment:
    expression_logical {
        printf("[SYNTATIC] (expression_assignment) expression_logical\n");

        $$ = createNode("expression_assignment");
        $$->children = $1;   
    }
    | ID '=' expression {
        printf("[SYNTATIC] (expression_assignment) ID(%s) '='  expression\n", $1);

        $$ = createNode("expression_assignment");
        $$->children = $3;
        $$->symbol = createSymbol(lines, columns, "variable", lastType, $1);
    }
;

expression_logical:
    expression_relational {
        printf("[SYNTATIC] (expression_logical) expression_relational\n");

        $$ = createNode("expression_logical");
        $$->children = $1;   
    }
    | set_boolean_expression {
        printf("[SYNTATIC] (expression_logical) set_expression\n");

        $$ = createNode("expression_logical");
        $$->children = $1;   
    }
    | is_set_expression {
        printf("[SYNTATIC] (is_set_expression) is_set_expression\n");

        $$ = createNode("expression_logical");
        $$->children = $1;   
    }
    | expression_logical AND_OP expression_logical {
        printf("[SYNTATIC] (expression_logical) expression_logical AND_OP(&&) expression_logical\n");

        $$ = createNode("expression_logical");
        $$->children = $1;   
    }
    | expression_logical OR_OP expression_logical {
        printf("[SYNTATIC] (expression_logical) expression_logical OR_OP(||) expression_logical\n");

        $$ = createNode("expression_logical");
        $$->children = $1;   
    }
;

expression_relational:
    expression_additive {
        printf("[SYNTATIC] (expression_relational) expression_additive \n");

        $$ = createNode("expression_relational");
        $$->children = $1;   
    }
    | expression_relational RELATIONAL_OP expression_relational {
        printf("[SYNTATIC] (expression_relational) expression_relational RELATIONAL_OP(%s) expression_relational\n", $2);

        $$ = createNode("expression_relational");
        $$->children = $1;   
        $1->nxt = $3;
        $$->symbol = createSymbol(lines, columns, "relational operator", "", $2);
    }
;

expression_additive:
    expression_multiplicative {
        printf("[SYNTATIC] (expression_additive) expression_multiplicative \n");
    
        $$ = createNode("expression_additive");
        $$->children = $1;   
    }
    | expression_additive ADDITIVE_OP expression_additive {
        printf("[SYNTATIC] (expression_additive) expression_additive ADDITIVE_OP(%s) expression_additive \n", $2);

        $$ = createNode("expression_additive");
        $$->children = $1;   
        $1->nxt = $3;
        $$->symbol = createSymbol(lines, columns, "additive operator", "", $2);
    }
;

expression_multiplicative:
    expression_value {
        printf("[SYNTATIC] (expression_multiplicative) expression_value \n");

        $$ = createNode("expression_multiplicative");
        $$->children = $1;
    }
    | expression_multiplicative MULTIPLICATIVE_OP expression_multiplicative {
        printf("[SYNTATIC] (expression_multiplicative)  expression_multiplicative MULTIPLICATIVE_OP(%s) expression_multiplicative \n", $2);

        $$ = createNode("expression_multiplicative");
        $$->children = $1;   
        $1->nxt = $3;
        $$->symbol = createSymbol(lines, columns, "multiplicative operator", "", $2);
    }
;

expression_value:
    '(' expression ')' {
        printf("[SYNTATIC] (expression_value) '(' expression ')' \n");

        $$ = createNode("expression_value");
        $$->children = $2;   
    }
    | value {
        printf("[SYNTATIC] (expression_value) value \n");

        $$ = createNode("expression_value");
        $$->children = $1;
    }
    | ADDITIVE_OP value {
        printf("[SYNTATIC] (expression_value) ADDITIVE_OP(%s) value \n", $1);

        $$ = createNode("expression_value");
        $$->children = $2;  
        $$->symbol = createSymbol(lines, columns, "additive operator", "", $1);
    }
    | set_statement_exists {
        printf("[SYNTATIC] (expression_value) set_statement_exists\n");

        $$ = createNode("expression_value");
        $$->children = $1;  
    }
;

is_set_statement:
    is_set_expression ';' {
        printf("[SYNTATIC] (is_set_statement) is_set_expression ';'\n");

        $$ = createNode("is_set_statement");
        $$->children = $1;  
    }
;

is_set_expression: 
    IS_SET '(' ID ')' {
        printf("[SYNTATIC] (is_set) IS_SET '(' ID(%s) ')' ';'\n", $3);

        $$ = createNode("is_set_expression");
        $$->symbol = createSymbol(lines, columns, "variable", lastType, $3); 
    }
;

for:
    FOR '(' for_expression ')' statements {
        printf("[SYNTATIC] (for) FOR '(' for_expression ')' statement\n");

        $$ = createNode("for");
        $$->children = $3;
        $3->nxt = $5;  
    }
;

for_expression:
    expression_assignment ';' expression_logical ';' expression_assignment {
        printf("[SYNTATIC] (for_expression) expression_assignment ';' expression_logical ';' expression_assignment\n");
        
        $$ = createNode("for_expression");
        $$->children = $1;
        $1->nxt = $3;  
        $3->nxt = $5;  
    }
;

io_statement:
    READ '(' ID ')' ';' {
        printf("[SYNTATIC] (io_statement) READ '(' ID(%s) ')' ';'\n", $3);

        $$ = createNode("io_statement");
    }
    | WRITE '(' STRING ')' ';' {
        printf("[SYNTATIC] (io_statement) WRITE '(' STRING(%s) ')' ';'\n", $3);

        $$ = createNode("io_statement");
        $$->symbol = createSymbol(lines, columns, "string", "", $3);
    }
    | WRITE '(' expression ')' ';' {
        printf("[SYNTATIC] (io_statement) WRITE '(' expression ')' ';'\n");

        $$ = createNode("io_statement");
        $$->children = $3;
    }
    | WRITELN '(' STRING ')' ';' {
        printf("[SYNTATIC] (io_statement) WRITELN '(' STRING(%s) ')' ';'\n", $3);

        $$ = createNode("io_statement");
        $$->symbol = createSymbol(lines, columns, "string", "", $3);
    }
    | WRITELN '(' expression ')' ';' {
        printf("[SYNTATIC] (io_statement) WRITELN '(' expression ')' ';'\n");

        $$ = createNode("io_statement");
        $$->children = $3;
    }
;

arguments_list:
    arguments_list ',' expression {
        printf("[SYNTATIC] (arguments_list) arguments_list ',' expression\n");

        $$ = createNode("arguments_list");
        $$->children = $1;
        $1->nxt = $3;
    }
    | expression {
        printf("[SYNTATIC] (arguments_list) expression\n");

        $$ = createNode("arguments_list");
        $$->children = $1;
    }
;

conditional:
    IF conditional_expression statements {
        printf("[SYNTATIC] (conditional) IF conditional_expression statements\n");

        $$ = createNode("conditional");
        $$->children = $2;
        $2->nxt = $3;
    }
    | IF conditional_expression statements_braced ELSE statements_braced {
        printf("[SYNTATIC] (conditional) IF conditional_expression statements_braced ELSE statements_braced\n");

        $$ = createNode("conditional");
        $$->children = $2;
        $2->nxt = $3;
        $3->nxt = $5;
    }
;

conditional_expression:
    '(' expression ')' {
        printf("[SYNTATIC] (conditional_expression) '(' expression ')'\n");

        $$ = createNode("conditional_expression");
        $$->children = $2;
    }
;

return:
    RETURN expression ';' {
        printf("[SYNTATIC] (return) RETURN expression ';'\n");

        $$ = createNode("return");
        $$->children = $2;
    }
    | RETURN ';' {
        printf("[SYNTATIC] (return) RETURN ';'\n");

        $$ = createNode("return");
    }
;

value:
    ID {
        printf("[SYNTATIC] (value) ID = %s\n", $1);

        $$ = createNode("value");
        $$->symbol = createSymbol(lines, columns, "variable", lastType, $1);
    }
    | const {
        printf("[SYNTATIC] (value) const\n");

        $$ = createNode("value");
        $$->children = $1;

    }
    | function_call {
        printf("[SYNTATIC] (value) function_call\n");

        $$ = createNode("value");
        $$->children = $1;
    }
;

function_call_statement:
    function_call ';' {
        printf("[SYNTATIC] (function_call_statement) function_call ';'\n");
        
        $$ = createNode("function_call_statement");
        $$->children = $1;

    }
;

function_call:
    ID '(' arguments_list ')' {
        printf("[SYNTATIC] (function_call) ID(%s) '(' arguments_list ')'\n", $1);

        Symbol* s = createSymbol(lines, columns, "function_call", "", $1);
        $$ = createNode("function_call");
        $$->children = $3;
        $$->symbol = s;
    }
    | ID '(' ')' {
        printf("[SYNTATIC] (function_call) ID(%s) '(' ')'\n", $1);

        Symbol* s = createSymbol(lines, columns, "function_call", "", $1);
        $$ = createNode("function_call");
        $$->symbol = s;
    }
;

variables_declaration:
    type_identifier ID ';' {
        printf("[SYNTATIC] (variables_declaration) type_identifier ID(%s) ';'\n", $2);
        
        push_back(&tableList, createSymbol(lines, columns - strlen($2), "variable", lastType, $2));
        
        Symbol* s = createSymbol(lines, columns, "variable", lastType, $2);
        $$ = createNode("variables_declaration");
        $$->children = $1;
        $$->symbol = s;
    }
    | error {}
;

const:
    INT_VALUE {
        printf("[SYNTATIC] (const) INT_VALUE = %s\n", $1);
        
        $$ = createNode("const");
        $$->symbol = createSymbol(lines, columns, "const", "int", $1);

    }
    | FLOAT_VALUE {
        printf("[SYNTATIC] (const) FLOAT_VALUE = %s\n", $1);
        
        $$ = createNode("const");
        $$->symbol = createSymbol(lines, columns, "const", "float", $1);
    }
    | EMPTY {
        printf("[SYNTATIC] (const) EMPTY\n");
        
        $$ = createNode("const");
        $$->symbol = createSymbol(lines, columns, "const", "empty", "EMPTY");
    }
;

%%

int yyerror(const char* message){
    printf("[SYNTATIC] ERROR [%d:%d] %s\n", lines, columns, message);
    errors++;
    return 0;
}

int main(int argc, char ** argv) {
    ++argv, --argc;
    if(argc > 0) {
        yyin = fopen(argv[0], "r");
    }
    else {
        yyin = stdin;
    }

    stackScope.size = stackScope.nxtScope = -1;
    tableList.size = -1;

    push(&stackScope);

    lines = 1;
    columns = 1;
    errors = 0;

    int ok[10000];
    memset(ok, 0, sizeof(ok));

    yyparse();
    printf("\n");

    if(errors){
        printf("Program analysis failed!\nAnalysis terminated with %d error(s)\n\n", errors);
    }
    else{
        printf("Correct program.\n\n");
    }

    if(errors){
        printf("Tree won't be displayed because unexpected behaviour can be found since it contains erros\n");
    } else {
        printf("\n");
        // printTree(root, 1, ok);
    }    
    printTable(&tableList);

    freeTree(root);
    freeTable(&tableList);
    fclose(yyin);
    yylex_destroy();

    return 0;
}