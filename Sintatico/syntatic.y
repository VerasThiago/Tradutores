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

    struct Body {
        char tokenBody [2000];
        int line;
        int column;
        int scope;
    } body;

    struct TreeNode *node;
}

%token ','
%token '{'
%token '('
%token '}'
%token ')'
%token ';'
%token '='
%token '!'

%token ELEM
%token IF
%token ELSE
%token SET
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
%left <body> AND_OP
%left <body>  OR_OP

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
        root = createNode("start");

        push_back_node(&treeNodeList, root);
        
        $$ = root;
        $$->children = $1;
    }
;

program:
	function_definition {
        printf("[SYNTATIC] (program) function_definition\n");
        $$ = createNode("program");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
    }
	| function_definition program {
        printf("[SYNTATIC] (program) function_definition program\n");

        $$ = createNode("program");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
        $1->nxt = $2;
    }
	| variables_declaration program {
        printf("[SYNTATIC] (program) variables_declaration program\n");

        $$ = createNode("program");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
        $1->nxt = $2;
    }
;

function_definition:
	function_declaration '(' parameters ')' function_body {
        printf("[SYNTATIC] (function_definition) function_declaration '(' parameters ')' function_body\n");
        
        $$ = createNode("function_definition");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
        $1->nxt = $3;
        $3->nxt = $5;
    }
    | function_declaration '(' ')' function_body {
        printf("[SYNTATIC] (function_definition) function_declaration '(' ')' function_body\n");
        
        $$ = createNode("function_definition");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
        $1->nxt = $4;
    }
    | error {}
;

function_declaration:
	type_identifier ID {
        printf("[SYNTATIC] (function_declaration) type_identifier ID(%s)\n", $2.tokenBody);

        $$ = createNode("function_declaration");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
        $$->symbol = createSymbol($2.line, $2.column, "variable", lastType, $2.tokenBody, $2.scope);
        push_back(&tableList, createSymbol($2.line, $2.column, "function", lastType, $2.tokenBody, $2.scope));
    }
;

function_body:
	'{' statements '}' {
        printf("[SYNTATIC] (function_body) '{' statements '}'\n");

        $$ = createNode("function_body");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $2;
    }
    | '{' '}' {
        printf("[SYNTATIC] (function_body) '{' '}'\n");

        $$ = createNode("function_body");
        push_back_node(&treeNodeList, $$);
        
    }
;

parameters:
	parameters_list {
        printf("[SYNTATIC] (parameters)  parameters_list \n");

        $$ = createNode("parameters_list");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
    }
;

parameters_list:
	parameters_list ',' parameter {
        printf("[SYNTATIC] (parameters_list) parameter ',' parameters_list\n");

        $$ = createNode("parameters_list");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
        $1->nxt = $3;
        
    } 
	| parameter {
        printf("[SYNTATIC] (parameters_list) parameter\n");

        $$ = createNode("parameters_list");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
    }
;

parameter:
	type_identifier ID {
        printf("[SYNTATIC] (parameter) type_identifier ID(%s)\n", $2.tokenBody);

        $$ = createNode("parameter");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
        $$->symbol = createSymbol($2.line, $2.column, "variable", lastType, $2.tokenBody, $2.scope);
        // push_back(&tableList, createSymbol($2.line, $2.line, "func parameter", lastType, $2.tokenBody, $2.scope));
    }
;

type_identifier:
	INT {
        printf("[SYNTATIC] (type_identifier) INT\n");

        $$ = createNode("type_identifier");
        push_back_node(&treeNodeList, $$);
        
        
        strcpy(lastType, "int");

    }
    | FLOAT {
        printf("[SYNTATIC] (type_identifier) FLOAT\n");

        $$ = createNode("type_identifier");
        push_back_node(&treeNodeList, $$);
        

        strcpy(lastType, "float");

    }
	| ELEM {
        printf("[SYNTATIC] (type_identifier) ELEM\n");

        $$ = createNode("type_identifier");
        push_back_node(&treeNodeList, $$);
        

        strcpy(lastType, "elem");

    }
    | SET{
        printf("[SYNTATIC] (type_identifier) SET\n");

        $$ = createNode("type_identifier");
        push_back_node(&treeNodeList, $$);
        

        strcpy(lastType, "set");

    }
;

statements:
	statement statements {
        printf("[SYNTATIC] (statements) statement statements\n");

        $$ = createNode("statements");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
        $1->nxt = $2;
    }
	| statement {
        printf("[SYNTATIC] (statements) statement\n");   

        $$ = createNode("statements");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
    }
    | statements_braced {
        printf("[SYNTATIC] (statements) statements_braced\n");

        $$ = createNode("statements");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
    }
;

statements_braced:
    '{' statements '}' {
        printf("[SYNTATIC] (statements_braced) '{' statements '}'\n");

        $$ = createNode("statements_braced");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $2;
    }
    | '{' '}' {
        printf("[SYNTATIC] (statements_braced) '{' '}'\n");

        $$ = createNode("statements_braced");
        push_back_node(&treeNodeList, $$);
        
    }
;

statement:
	variables_declaration {
        printf("[SYNTATIC] (statement) variables_declaration\n");

        $$ = createNode("statement");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;   
    }
	| return {
        printf("[SYNTATIC] (statement) return\n");

        $$ = createNode("statement");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;    
    }
	| conditional {
        printf("[SYNTATIC] (statement) conditional\n");   

        $$ = createNode("statement");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;  
    }
	| for {
        printf("[SYNTATIC] (statement) for\n");

        $$ = createNode("statement");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;   
    }
    | is_set_statement {
        printf("[SYNTATIC] (statement) is_set_statement\n"); 

        $$ = createNode("statement");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;  
    }
    | function_call_statement {
        printf("[SYNTATIC] (statement) function_call_statement\n"); 

        $$ = createNode("statement");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1; 
    }
	| expression_statement {
        printf("[SYNTATIC] (statement) expression_statement \n");

        $$ = createNode("statement");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;   
    }
	| io_statement {
        printf("[SYNTATIC] (statement) io_statement\n");

        $$ = createNode("statement");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;  
    }
	| set_pre_statement {
        printf("[SYNTATIC] (statement) set_pre_statement\n");

        $$ = createNode("statement");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;  
    }
;

set_pre_statement:
    set_statement_add_remove ';' {
        printf("[SYNTATIC] (set_pre_statement) set_statement_add_remove ';'\n");  

        $$ = createNode("set_pre_statement");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
    }
    | set_statement_for_all {
        printf("[SYNTATIC] (set_pre_statement) set_statement_for_all\n");  

        $$ = createNode("set_pre_statement");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
    }
;

set_statement_add_remove:
    ADD '(' set_boolean_expression ')' {
        printf("[SYNTATIC] (set_statement_add_remove) ADD '(' set_boolean_expression ')'\n"); 
        
        $$ = createNode("set_statement_add_remove");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $3;
    }
    | REMOVE '(' set_boolean_expression ')' {
        printf("[SYNTATIC] (set_statement_add_remove) REMOVE '(' set_boolean_expression ')'\n"); 

        $$ = createNode("set_statement_add_remove");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $3;
    }
;

set_statement_for_all:
    FOR_ALL '(' set_assignment_expression ')' statements {
        printf("[SYNTATIC] (set_statement_for_all) FOR_ALL '(' set_assignment_expression ')' statements\n"); 

        $$ = createNode("set_statement_for_all");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $3;
        $3->nxt = $5;
    }
;

set_statement_exists:
    EXISTS '(' set_assignment_expression ')' {
        printf("[SYNTATIC] (set_statement_exists) EXISTS '(' set_assignment_expression ')'\n"); 

        $$ = createNode("set_statement_exists");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $3;
    }
;

set_boolean_expression:
    expression IN set_statement_add_remove {
        printf("[SYNTATIC] (set_boolean_expression) expression IN set_statement_add_remove\n");

        $$ = createNode("set_boolean_expression");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
        $1->nxt = $3;
    }
    | expression IN ID {
        printf("[SYNTATIC] (set_boolean_expression) expression IN ID(%s)\n", $3.tokenBody);

        $$ = createNode("set_boolean_expression");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
    }
;

set_assignment_expression:
    ID IN set_statement_add_remove {
        printf("[SYNTATIC] (set_assignment_expression) expression IN set_statement_add_remove\n");

        $$ = createNode("set_assignment_expression");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $3;
    }
    | ID IN ID {
        printf("[SYNTATIC] (set_assignment_expression) ID(%s) IN ID(%s)\n", $1.tokenBody, $3.tokenBody);

        $$ = createNode("set_assignment_expression");
        push_back_node(&treeNodeList, $$);
        
        $$->symbol = createSymbol($1.line, $1.column, "variable", lastType, $1.tokenBody, $1.scope);
    }
;

expression_statement:
    expression ';' {
        printf("[SYNTATIC] (expression_statement) expression\n");

        $$ = createNode("expression_statement");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
    }
;

expression:
    expression_assignment {
        printf("[SYNTATIC] (expression) expression_assignment\n");

        $$ = createNode("expression");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
    }
;

expression_assignment:
    expression_logical {
        printf("[SYNTATIC] (expression_assignment) expression_logical\n");

        $$ = createNode("expression_assignment");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;   
    }
    | ID '=' expression {
        printf("[SYNTATIC] (expression_assignment) ID(%s) '='  expression\n", $1.tokenBody);

        $$ = createNode("expression_assignment");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $3;
        $$->symbol = createSymbol($1.line, $1.column, "variable", lastType, $1.tokenBody, $1.scope);
    }
    | ID '=' set_boolean_expression {
        printf("[SYNTATIC] (expression_assignment) ID(%s) '='  set_boolean_expression\n", $1.tokenBody);

        $$ = createNode("expression_assignment");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $3;
        $$->symbol = createSymbol($1.line, $1.column, "variable", lastType, $1.tokenBody, $1.scope);
    }

    
;

expression_logical:
    expression_relational {
        printf("[SYNTATIC] (expression_logical) expression_relational\n");

        $$ = createNode("expression_logical");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;   
    }
    | set_boolean_expression {
        printf("[SYNTATIC] (expression_logical) set_expression\n");

        $$ = createNode("expression_logical");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;   
    }
    | is_set_expression {
        printf("[SYNTATIC] (is_set_expression) is_set_expression\n");

        $$ = createNode("expression_logical");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;   
    }
    | expression_logical AND_OP expression_logical {
        printf("[SYNTATIC] (expression_logical) expression_logical AND_OP(&&) expression_logical\n");

        $$ = createNode("expression_logical");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
        $1->nxt = $3;
        $$->symbol = createSymbol($2.line, $2.column, "logical operator", "", $2.tokenBody, $2.scope);  
    }
    | expression_logical OR_OP expression_logical {
        printf("[SYNTATIC] (expression_logical) expression_logical OR_OP(||) expression_logical\n");

        $$ = createNode("expression_logical");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
        $1->nxt = $3;
        $$->symbol = createSymbol($2.line, $2.column, "logical operator", "", $2.tokenBody, $2.scope);   
    }
;

expression_relational:
    expression_additive {
        printf("[SYNTATIC] (expression_relational) expression_additive \n");

        $$ = createNode("expression_relational");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;   
    }
    | expression_relational RELATIONAL_OP expression_relational {
        printf("[SYNTATIC] (expression_relational) expression_relational RELATIONAL_OP(%s) expression_relational\n", $2.tokenBody);

        $$ = createNode("expression_relational");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;   
        $1->nxt = $3;
        $$->symbol = createSymbol($2.line, $2.column, "relational operator", "", $2.tokenBody, $2.scope);
    }
;

expression_additive:
    expression_multiplicative {
        printf("[SYNTATIC] (expression_additive) expression_multiplicative \n");
    
        $$ = createNode("expression_additive");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;   
    }
    | expression_additive ADDITIVE_OP expression_additive {
        printf("[SYNTATIC] (expression_additive) expression_additive ADDITIVE_OP(%s) expression_additive \n", $2.tokenBody);

        $$ = createNode("expression_additive");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;   
        $1->nxt = $3;
        $$->symbol = createSymbol($2.line, $2.column, "additive operator", "", $2.tokenBody, $2.scope);
    }
;

expression_multiplicative:
    expression_value {
        printf("[SYNTATIC] (expression_multiplicative) expression_value \n");

        $$ = createNode("expression_multiplicative");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
    }
    | expression_multiplicative MULTIPLICATIVE_OP expression_multiplicative {
        printf("[SYNTATIC] (expression_multiplicative)  expression_multiplicative MULTIPLICATIVE_OP(%s) expression_multiplicative \n", $2.tokenBody);

        $$ = createNode("expression_multiplicative");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;   
        $1->nxt = $3;
        $$->symbol = createSymbol($2.line, $2.column, "multiplicative operator", "", $2.tokenBody, $2.scope);
    }
;

expression_value:
    '(' expression ')' {
        printf("[SYNTATIC] (expression_value) '(' expression ')' \n");

        $$ = createNode("expression_value");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $2;   
    }
    | ADDITIVE_OP '(' expression ')' {
        printf("[SYNTATIC] (expression_value) ADDITIVE_OP(%s) '(' expression ')' \n", $1.tokenBody);

        $$ = createNode("expression_value");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $3;
        $$->symbol = createSymbol($1.line, $1.column, "additive operator", "", $1.tokenBody, $1.scope); 
    }
    | '!' '(' expression ')' {
        printf("[SYNTATIC] (expression_value) ! '(' expression ')' \n");

        $$ = createNode("expression_value");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $3;
    }
    | value {
        printf("[SYNTATIC] (expression_value) value \n");

        $$ = createNode("expression_value");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
    }
    | ADDITIVE_OP value {
        printf("[SYNTATIC] (expression_value) ADDITIVE_OP(%s) value \n", $1.tokenBody);

        $$ = createNode("expression_value");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $2;  
        $$->symbol = createSymbol($1.line, $1.column, "additive operator", "", $1.tokenBody, $1.scope);
    }
    | '!' value {
        printf("[SYNTATIC] (expression_value) ! value \n");

        $$ = createNode("expression_value");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $2;  
    }
    | set_statement_exists {
        printf("[SYNTATIC] (expression_value) set_statement_exists\n");

        $$ = createNode("expression_value");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;  
    }
;

is_set_statement:
    is_set_expression ';' {
        printf("[SYNTATIC] (is_set_statement) is_set_expression ';'\n");

        $$ = createNode("is_set_statement");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;  
    }
;

is_set_expression: 
    IS_SET '(' ID ')' {
        printf("[SYNTATIC] (is_set_expression) IS_SET '(' ID(%s) ')' ';'\n", $3.tokenBody);

        $$ = createNode("is_set_expression");
        push_back_node(&treeNodeList, $$);
        
        $$->symbol = createSymbol($3.line, $3.column, "variable", lastType, $3.tokenBody, $3.scope); 
    }
    | '!' IS_SET '(' ID ')' {
        printf("[SYNTATIC] (is_set_expression) ! IS_SET '(' ID(%s) ')' ';'\n", $4.tokenBody);

        $$ = createNode("is_set_expression");
        push_back_node(&treeNodeList, $$);
        
        $$->symbol = createSymbol($4.line, $4.column, "variable", lastType, $4.tokenBody, $4.scope); 
    }
;   

for:
    FOR '(' for_expression ')' statements {
        printf("[SYNTATIC] (for) FOR '(' for_expression ')' statement\n");

        $$ = createNode("for");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $3;
        $3->nxt = $5;  
    }
;

for_expression:
    expression_assignment ';' expression_logical ';' expression_assignment {
        printf("[SYNTATIC] (for_expression) expression_assignment ';' expression_logical ';' expression_assignment\n");
        
        $$ = createNode("for_expression");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
        $1->nxt = $3;  
        $3->nxt = $5;  
    }
;

io_statement:
    READ '(' ID ')' ';' {
        printf("[SYNTATIC] (io_statement) READ '(' ID(%s) ')' ';'\n", $3.tokenBody);

        $$ = createNode("io_statement");
        push_back_node(&treeNodeList, $$);
        
    }
    | WRITE '(' STRING ')' ';' {
        printf("[SYNTATIC] (io_statement) WRITE '(' STRING(%s) ')' ';'\n", $3.tokenBody);

        $$ = createNode("io_statement");
        push_back_node(&treeNodeList, $$);
        
        $$->symbol = createSymbol($3.line, $3.column, "string", "", $3.tokenBody, $3.scope);
    }
    | WRITE '(' expression ')' ';' {
        printf("[SYNTATIC] (io_statement) WRITE '(' expression ')' ';'\n");

        $$ = createNode("io_statement");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $3;
    }
    | WRITELN '(' STRING ')' ';' {
        printf("[SYNTATIC] (io_statement) WRITELN '(' STRING(%s) ')' ';'\n", $3.tokenBody);

        $$ = createNode("io_statement");
        push_back_node(&treeNodeList, $$);
        
        $$->symbol = createSymbol($3.line, $3.column, "string", "", $3.tokenBody, $3.scope);
    }
    | WRITELN '(' expression ')' ';' {
        printf("[SYNTATIC] (io_statement) WRITELN '(' expression ')' ';'\n");

        $$ = createNode("io_statement");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $3;
    }
;

arguments_list:
    arguments_list ',' expression {
        printf("[SYNTATIC] (arguments_list) arguments_list ',' expression\n");

        $$ = createNode("arguments_list");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
        $1->nxt = $3;
    }
    | expression {
        printf("[SYNTATIC] (arguments_list) expression\n");

        $$ = createNode("arguments_list");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
    }
;

conditional:
    IF conditional_expression statements {
        printf("[SYNTATIC] (conditional) IF conditional_expression statements\n");

        $$ = createNode("conditional");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $2;
        $2->nxt = $3;
    }
    | IF conditional_expression statements_braced ELSE statements_braced {
        printf("[SYNTATIC] (conditional) IF conditional_expression statements_braced ELSE statements_braced\n");

        $$ = createNode("conditional");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $2;
        $2->nxt = $3;
        $3->nxt = $5;
    }
;

conditional_expression:
    '(' expression ')' {
        printf("[SYNTATIC] (conditional_expression) '(' expression ')'\n");

        $$ = createNode("conditional_expression");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $2;
    }
;

return:
    RETURN expression ';' {
        printf("[SYNTATIC] (return) RETURN expression ';'\n");

        $$ = createNode("return");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $2;
    }
    | RETURN ';' {
        printf("[SYNTATIC] (return) RETURN ';'\n");

        $$ = createNode("return");
        push_back_node(&treeNodeList, $$);
        
    }
;

value:
    ID {
        printf("[SYNTATIC] (value) ID = %s\n", $1.tokenBody);

        $$ = createNode("value");
        push_back_node(&treeNodeList, $$);
        
        $$->symbol = createSymbol($1.line, $1.column, "variable", lastType, $1.tokenBody, $1.scope);
    }
    | const {
        printf("[SYNTATIC] (value) const\n");

        $$ = createNode("value");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;

    }
    | function_call {
        printf("[SYNTATIC] (value) function_call\n");

        $$ = createNode("value");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
    }
;

function_call_statement:
    function_call ';' {
        printf("[SYNTATIC] (function_call_statement) function_call ';'\n");
        
        $$ = createNode("function_call_statement");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;

    }
;

function_call:
    ID '(' arguments_list ')' {
        printf("[SYNTATIC] (function_call) ID(%s) '(' arguments_list ')'\n", $1.tokenBody);

        $$ = createNode("function_call");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $3;
        $$->symbol = createSymbol($1.line, $1.column, "function_call", "", $1.tokenBody, $1.scope);
    }
    | ID '(' ')' {
        printf("[SYNTATIC] (function_call) ID(%s) '(' ')'\n", $1.tokenBody);

        $$ = createNode("function_call");
        push_back_node(&treeNodeList, $$);
        
        $$->symbol = createSymbol($1.line, $1.column, "function_call", "", $1.tokenBody, $1.scope);
    }
;

variables_declaration:
    type_identifier ID ';' {
        printf("[SYNTATIC] (variables_declaration) type_identifier ID(%s) ';'\n", $2.tokenBody);
        
        push_back(&tableList, createSymbol($2.line, $2.line, "variable", lastType, $2.tokenBody, $2.scope));
        
        $$ = createNode("variables_declaration");
        push_back_node(&treeNodeList, $$);
        
        $$->children = $1;
        $$->symbol = createSymbol($2.line, $2.column, "variable", lastType, $2.tokenBody, $2.scope);
    }
    | error {}
;

const:
    INT_VALUE {
        printf("[SYNTATIC] (const) INT_VALUE = %s\n", $1.tokenBody);
        
        $$ = createNode("const");
        push_back_node(&treeNodeList, $$);
        
        $$->symbol = createSymbol($1.line, $1.column, "const", "int", $1.tokenBody, $1.scope);

    }
    | FLOAT_VALUE {
        printf("[SYNTATIC] (const) FLOAT_VALUE = %s\n", $1.tokenBody);
        
        $$ = createNode("const");
        push_back_node(&treeNodeList, $$);
        
        $$->symbol = createSymbol($1.line, $1.column, "const", "float", $1.tokenBody, $1.scope);
    }
    | EMPTY {
        printf("[SYNTATIC] (const) EMPTY\n");
        
        $$ = createNode("const");
        push_back_node(&treeNodeList, $$);
        
    }
;

%%

int yyerror(const char* message){
    printf("\n[SYNTATIC] [%d,%d] ERROR %s\n\n", yylval.body.line, yylval.body.column, message);
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
    treeNodeList.size = -1;

    push(&stackScope);

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
        printTree(root, 1, ok);
    }    
    printTable(&tableList);
    
    freeTable(&tableList);
    freeNodeList(&treeNodeList);

    fclose(yyin);
    yylex_destroy();

    return 0;
}