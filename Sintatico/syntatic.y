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
%left '='
%token '!'

%token ELEM
%left IF
%left ELSE
%token SET
%token FOR
%token RETURN
%token WRITE
%token WRITELN
%token READ
%token FLOAT
%token INT
%token ADD
%token REMOVE
%token EXISTS
%token FOR_ALL
%token IS_SET
%left IN

%token <body> INT_VALUE
%token <body> FLOAT_VALUE
%token <body> EMPTY
%token <body> ID
%token <body> STRING

%left <body> RELATIONAL_OP
%left <body> MULTIPLICATIVE_OP
%left <body> ADDITIVE_OP
%left <body> AND_OP
%left <body> OR_OP

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

        if(verbose){
            $$ = createNode("program");
            $$->children = $1;
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;
        }
    }
	| function_definition program {
        printf("[SYNTATIC] (program) function_definition program\n");

        $$ = createNode("program");
        $$->children = $1;
        $1->nxt = $2;
        
        push_back_node(&treeNodeList, $$);
    }
	| variables_declaration program {
        printf("[SYNTATIC] (program) variables_declaration program\n");

        $$ = createNode("program");
        $$->children = $1;
        $1->nxt = $2;
        
        push_back_node(&treeNodeList, $$);
    }
;

function_definition:
	function_declaration '(' parameters ')' function_body {
        printf("[SYNTATIC] (function_definition) function_declaration '(' parameters ')' function_body\n");
        
        $$ = createNode("function_definition");
        $$->children = $1;
        $1->nxt = $3;
        $3->nxt = $5;
        
        push_back_node(&treeNodeList, $$);
        
    }
    | function_declaration '(' ')' function_body {
        printf("[SYNTATIC] (function_definition) function_declaration '(' ')' function_body\n");
               
        $$ = createNode("function_definition");
        $$->children = $1;
        $1->nxt = $4;
        
        push_back_node(&treeNodeList, $$);
        
    }
;

function_declaration:
	type_identifier ID {
        printf("[SYNTATIC] (function_declaration) type_identifier ID(%s)\n", $2.tokenBody);

        if(verbose){
            $$ = createNode("function_declaration");
            $$->children = $1;
        } else {
            char aux[] = "function_declaration - ";
            strcat(aux , $1->symbol->body);
            $$ = createNode(aux);
        }

        $$->symbol = createSymbol($2.line, $2.column, "variable", lastType, $2.tokenBody, $2.scope);
        push_back_node(&treeNodeList, $$);
        push_back(&tableList, createSymbol($2.line, $2.column, "function", lastType, $2.tokenBody, $2.scope));
    }
;

function_body:
	'{' statements '}' {
        printf("[SYNTATIC] (function_body) '{' statements '}'\n");

        if(verbose){
            $$ = createNode("function_body");
            $$->children = $2;

            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $2;
        }
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

        if(verbose){
            $$ = createNode("parameters_list");
            $$->children = $1;

            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;
        }
    }
;

parameters_list:
	parameters_list ',' parameter {
        printf("[SYNTATIC] (parameters_list) parameter ',' parameters_list\n");

        $$ = createNode("parameters_list");
        $$->children = $1;
        $1->nxt = $3;
        
        push_back_node(&treeNodeList, $$);
        
    } 
	| parameter {
        printf("[SYNTATIC] (parameters_list) parameter\n");

        if(verbose){
            $$ = createNode("parameters_list");
            $$->children = $1;
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;
        }
    }
;

parameter:
	type_identifier ID {
        printf("[SYNTATIC] (parameter) type_identifier ID(%s)\n", $2.tokenBody);

        if(verbose){
            $$ = createNode("parameter");
            $$->children = $1;
        } else {
            char aux[] = "parameter - ";
            strcat(aux , $1->symbol->body);
            $$ = createNode(aux);
        }

        $$->symbol = createSymbol($2.line, $2.column, "variable", lastType, $2.tokenBody, $2.scope);
        push_back_node(&treeNodeList, $$);
    }
;

type_identifier:
	INT {
        printf("[SYNTATIC] (type_identifier) INT\n");

        $$ = createNode("type_identifier");
        $$->symbol = createSymbol(-1 , -1, "Type", lastType, "INT", -1);
        
        push_back_node(&treeNodeList, $$);
        
        strcpy(lastType, "INT");

    }
    | FLOAT {
        printf("[SYNTATIC] (type_identifier) FLOAT\n");

        $$ = createNode("type_identifier");
        $$->symbol = createSymbol(-1 , -1, "Type", lastType, "FLOAT", -1);
        
        push_back_node(&treeNodeList, $$);

        strcpy(lastType, "FLOAT");

    }
	| ELEM {
        printf("[SYNTATIC] (type_identifier) ELEM\n");

        $$ = createNode("type_identifier");
        $$->symbol = createSymbol(-1 , -1, "Type", lastType, "ELEM", -1);

        push_back_node(&treeNodeList, $$);

        strcpy(lastType, "elem");

    }
    | SET{
        printf("[SYNTATIC] (type_identifier) SET\n");

        $$ = createNode("type_identifier");
        $$->symbol = createSymbol(-1 , -1, "Type", lastType, "SET", -1);

        push_back_node(&treeNodeList, $$);

        strcpy(lastType, "set");

    }
;

statements:
	statement statements {
        printf("[SYNTATIC] (statements) statement statements\n");

        $$ = createNode("statements");
        $$->children = $1;
        $1->nxt = $2;
        
        push_back_node(&treeNodeList, $$);
    }

	| statement {
        printf("[SYNTATIC] (statements) statement\n");   

        if(verbose){
            $$ = createNode("statements");
            $$->children = $1;
            
            push_back_node(&treeNodeList, $$);
        } else {
             $$ = $1;
        }
    }
    | statements_braced {
        printf("[SYNTATIC] (statements) statements_braced\n");

        if(verbose){
            $$ = createNode("statements");
            $$->children = $1;
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;
        }
    }
;

statements_braced:
    '{' statements '}' {
        printf("[SYNTATIC] (statements_braced) '{' statements '}'\n");

        if(verbose){
            $$ = createNode("statements_braced");
            $$->children = $2;

            push_back_node(&treeNodeList, $$);
        } else{
            $$ = $2;
        }
        
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
        if(verbose){
            $$ = createNode("statement");
            $$->children = $1;   
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
	| return {
        printf("[SYNTATIC] (statement) return\n");
        if(verbose){
            $$ = createNode("statement");
            $$->children = $1;    
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
	| conditional {
        printf("[SYNTATIC] (statement) conditional\n");   
        if(verbose){
            $$ = createNode("statement");
            $$->children = $1;  
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
	| for {
        printf("[SYNTATIC] (statement) for\n");
        if(verbose){
            $$ = createNode("statement");
            $$->children = $1;   
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
    | is_set_statement {
        printf("[SYNTATIC] (statement) is_set_statement\n"); 
        if(verbose){
            $$ = createNode("statement");
            $$->children = $1;  
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
    | function_call_statement {
        printf("[SYNTATIC] (statement) function_call_statement\n"); 

        if(verbose){
            $$ = createNode("statement");
            $$->children = $1; 
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
	| expression_statement {
        printf("[SYNTATIC] (statement) expression_statement \n");
        if(verbose){
            $$ = createNode("statement");
            $$->children = $1;   
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
	| io_statement {
        printf("[SYNTATIC] (statement) io_statement\n");
        if(verbose){
            $$ = createNode("statement");
            $$->children = $1;  
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
	| set_pre_statement {
        printf("[SYNTATIC] (statement) set_pre_statement\n");
        if(verbose){
            $$ = createNode("statement");
            $$->children = $1;  
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
;

set_pre_statement:
    set_statement_add_remove ';' {
        printf("[SYNTATIC] (set_pre_statement) set_statement_add_remove ';'\n");  

        if(verbose){
            $$ = createNode("set_pre_statement");
            $$->children = $1;
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
    | set_statement_for_all {
        printf("[SYNTATIC] (set_pre_statement) set_statement_for_all\n");  

        if(verbose){
            $$ = createNode("set_pre_statement");
            $$->children = $1;
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
;

set_statement_add_remove:
    ADD '(' set_boolean_expression ')' {
        printf("[SYNTATIC] (set_statement_add_remove) ADD '(' set_boolean_expression ')'\n"); 
        
        if(verbose){
            $$ = createNode("set_statement_add_remove");
            $$->children = $3;
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $3;   
        }
    }
    | REMOVE '(' set_boolean_expression ')' {
        printf("[SYNTATIC] (set_statement_add_remove) REMOVE '(' set_boolean_expression ')'\n"); 

        if(verbose){
            $$ = createNode("set_statement_add_remove");
            $$->children = $3;
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $3;   
        }
    }
;

set_statement_for_all:
    FOR_ALL '(' set_assignment_expression ')' statements {
        printf("[SYNTATIC] (set_statement_for_all) FOR_ALL '(' set_assignment_expression ')' statements\n"); 

        $$ = createNode("set_statement_for_all");
        $$->children = $3;
        $3->nxt = $5;
        
        push_back_node(&treeNodeList, $$);

    }
;

set_statement_exists:
    EXISTS '(' set_assignment_expression ')' {
        printf("[SYNTATIC] (set_statement_exists) EXISTS '(' set_assignment_expression ')'\n"); 

        if(verbose){
            $$ = createNode("set_statement_exists");
            $$->children = $3;
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $3;   
        }
    }
;

set_boolean_expression:
    expression IN set_statement_add_remove {
        printf("[SYNTATIC] (set_boolean_expression) expression IN set_statement_add_remove\n");

        $$ = createNode("set_boolean_expression");
        $$->children = $1;
        $1->nxt = $3;
        
        push_back_node(&treeNodeList, $$);
        
    }
    | expression IN ID {
        printf("[SYNTATIC] (set_boolean_expression) expression IN ID(%s)\n", $3.tokenBody);

        if(verbose){
            $$ = createNode("set_boolean_expression");
            $$->children = $1;
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
;

set_assignment_expression:
    ID IN set_statement_add_remove {
        printf("[SYNTATIC] (set_assignment_expression) expression IN set_statement_add_remove\n");

        if(verbose){
            $$ = createNode("set_assignment_expression");
            $$->children = $3;
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $3;   
        }
    }
    | ID IN ID {
        printf("[SYNTATIC] (set_assignment_expression) ID(%s) IN ID(%s)\n", $1.tokenBody, $3.tokenBody);

        $$ = createNode("set_assignment_expression");
        $$->symbol = createSymbol($1.line, $1.column, "variable", lastType, $1.tokenBody, $1.scope);
        
        push_back_node(&treeNodeList, $$);
    }
;

expression_statement:
    expression ';' {
        printf("[SYNTATIC] (expression_statement) expression\n");

        if(verbose){
            $$ = createNode("expression_statement");
            $$->children = $1;
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }

    }
;

expression:
    expression_assignment {
        printf("[SYNTATIC] (expression) expression_assignment\n");

        if(verbose){
            $$ = createNode("expression");
            $$->children = $1;
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
;

expression_assignment:
    expression_logical {
        printf("[SYNTATIC] (expression_assignment) expression_logical\n");

        if(verbose){
            $$ = createNode("expression_assignment");
            $$->children = $1;   
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
    | ID '=' expression {
        printf("[SYNTATIC] (expression_assignment) ID(%s) '='  expression\n", $1.tokenBody);

        if(verbose){
            $$ = createNode("expression_assignment");
            $$->children = $3;
            $$->symbol = createSymbol($1.line, $1.column, "variable", lastType, $1.tokenBody, $1.scope);
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $3;   
        }
    }
    | ID '=' set_boolean_expression {
        printf("[SYNTATIC] (expression_assignment) ID(%s) '='  set_boolean_expression\n", $1.tokenBody);

        $$ = createNode("expression_assignment");
        $$->children = $3;
        $$->symbol = createSymbol($1.line, $1.column, "variable", lastType, $1.tokenBody, $1.scope);
        
        push_back_node(&treeNodeList, $$);
    }

    
;

expression_logical:
    expression_relational {
        printf("[SYNTATIC] (expression_logical) expression_relational\n");

        if(verbose){
            $$ = createNode("expression_logical");
            $$->children = $1;   
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
    | set_boolean_expression {
        printf("[SYNTATIC] (expression_logical) set_expression\n");

        if(verbose){
            $$ = createNode("expression_logical");
            $$->children = $1;   
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
    | is_set_expression {
        printf("[SYNTATIC] (is_set_expression) is_set_expression\n");

        if(verbose){
            $$ = createNode("expression_logical");
            $$->children = $1;   
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
    | expression_logical AND_OP expression_logical {
        printf("[SYNTATIC] (expression_logical) expression_logical AND_OP(&&) expression_logical\n");

        $$ = createNode("expression_logical");
        $$->children = $1;
        $1->nxt = $3;
        $$->symbol = createSymbol($2.line, $2.column, "logical operator", "", $2.tokenBody, $2.scope);  
        
        push_back_node(&treeNodeList, $$);
    }
    | expression_logical OR_OP expression_logical {
        printf("[SYNTATIC] (expression_logical) expression_logical OR_OP(||) expression_logical\n");

        $$ = createNode("expression_logical");
        $$->children = $1;
        $1->nxt = $3;
        $$->symbol = createSymbol($2.line, $2.column, "logical operator", "", $2.tokenBody, $2.scope);   
        
        push_back_node(&treeNodeList, $$);
    }
;

expression_relational:
    expression_additive {
        printf("[SYNTATIC] (expression_relational) expression_additive \n");
        if(verbose){
            $$ = createNode("expression_relational");
            $$->children = $1;   
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
    | expression_relational RELATIONAL_OP expression_relational {
        printf("[SYNTATIC] (expression_relational) expression_relational RELATIONAL_OP(%s) expression_relational\n", $2.tokenBody);

        $$ = createNode("expression_relational");
        $$->children = $1;   
        $1->nxt = $3;
        $$->symbol = createSymbol($2.line, $2.column, "relational operator", "", $2.tokenBody, $2.scope);
        
        push_back_node(&treeNodeList, $$);
    }
;

expression_additive:
    expression_multiplicative {
        printf("[SYNTATIC] (expression_additive) expression_multiplicative \n");

        if(verbose){
            $$ = createNode("expression_additive");
            $$->children = $1;   
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
    | expression_additive ADDITIVE_OP expression_additive {
        printf("[SYNTATIC] (expression_additive) expression_additive ADDITIVE_OP(%s) expression_additive \n", $2.tokenBody);

        $$ = createNode("expression_additive");
        $$->children = $1;   
        $1->nxt = $3;
        $$->symbol = createSymbol($2.line, $2.column, "additive operator", "", $2.tokenBody, $2.scope);
        
        push_back_node(&treeNodeList, $$);
    }
;

expression_multiplicative:
    expression_value {
        printf("[SYNTATIC] (expression_multiplicative) expression_value \n");

        if(verbose){
            $$ = createNode("expression_multiplicative");
            $$->children = $1;
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
    | expression_multiplicative MULTIPLICATIVE_OP expression_multiplicative {
        printf("[SYNTATIC] (expression_multiplicative)  expression_multiplicative MULTIPLICATIVE_OP(%s) expression_multiplicative \n", $2.tokenBody);

        $$ = createNode("expression_multiplicative");
        $$->children = $1;   
        $1->nxt = $3;
        $$->symbol = createSymbol($2.line, $2.column, "multiplicative operator", "", $2.tokenBody, $2.scope);
        
        push_back_node(&treeNodeList, $$);
    }
;

expression_value:
    '(' expression ')' {
        printf("[SYNTATIC] (expression_value) '(' expression ')' \n");

        if(verbose){
            $$ = createNode("expression_value");
            push_back_node(&treeNodeList, $$);
            
            $$->children = $2;   
        } else {
            $$ = $2;   
        }
    }
    | '!' '(' expression ')' {
        printf("[SYNTATIC] (expression_value) ! '(' expression ')' \n");

        if(verbose){
            $$ = createNode("expression_value");
            $$->children = $3;
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $3;   
        }
    }
    | ADDITIVE_OP '(' expression ')' {
        printf("[SYNTATIC] (expression_value) ADDITIVE_OP(%s) '(' expression ')' \n", $1.tokenBody);

        $$ = createNode("expression_value");
        $$->children = $3;
        $$->symbol = createSymbol($1.line, $1.column, "additive operator", "", $1.tokenBody, $1.scope); 
        
        push_back_node(&treeNodeList, $$);
    }
    | value {
        printf("[SYNTATIC] (expression_value) value \n");

        if(verbose){
            $$ = createNode("expression_value");
            $$->children = $1;
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
    | '!' value {
        printf("[SYNTATIC] (expression_value) ! value \n");

        if(verbose){
            $$ = createNode("expression_value");
            push_back_node(&treeNodeList, $$);
            
            $$->children = $2;
        } else {
            $$ = $2;   
        }  
    }
    | ADDITIVE_OP value {
        printf("[SYNTATIC] (expression_value) ADDITIVE_OP(%s) value \n", $1.tokenBody);

        $$ = createNode("expression_value");
        $$->children = $2;
        $$->symbol = createSymbol($1.line, $1.column, "additive operator", "", $1.tokenBody, $1.scope);
        
        push_back_node(&treeNodeList, $$);
    }
    | set_statement_exists {
        printf("[SYNTATIC] (expression_value) set_statement_exists\n");

        if(verbose){
            $$ = createNode("expression_value");
            $$->children = $1;  
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
;

is_set_statement:
    is_set_expression ';' {
        printf("[SYNTATIC] (is_set_statement) is_set_expression ';'\n");

        if(verbose){
            $$ = createNode("is_set_statement");
            $$->children = $1;  
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;   
        }
    }
;

is_set_expression: 
    IS_SET '(' expression ')' {
        printf("[SYNTATIC] (is_set_expression) IS_SET '(' expression ')' ';'\n");

        if(verbose){
            $$ = createNode("is_set_expression");
            $$->children = $3;  

            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $3;  
        }
    }
    | '!' IS_SET '(' expression ')' {
        printf("[SYNTATIC] (is_set_expression) ! IS_SET '(' expression ')' ';'\n");

        if(verbose){
            $$ = createNode("is_set_expression");
            $$->children = $4;

            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $4;  
        }
    } 
    | IS_SET '(' set_statement_add_remove ')' {
        printf("[SYNTATIC] (is_set_expression) IS_SET '(' set_statement_add_remove ')' ';'\n");

        if(verbose){
            $$ = createNode("is_set_expression");
            $$->children = $3;  

            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $3;  
        }
         
    }
    | '!' IS_SET '(' set_statement_add_remove ')' {
        printf("[SYNTATIC] (is_set_expression) ! IS_SET '(' set_statement_add_remove ')' ';'\n");

        if(verbose){
            $$ = createNode("is_set_expression");
            $$->children = $4;  

            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $4;  
        }
    }
    | IS_SET '(' set_statement_exists ')' {
        printf("[SYNTATIC] (is_set_expression) IS_SET '(' set_statement_exists ')' ';'\n");

        if(verbose){
            $$ = createNode("is_set_expression");
            $$->children = $3;  

            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $3;  
        }
         
    }
    | '!' IS_SET '(' set_statement_exists ')' {
        printf("[SYNTATIC] (is_set_expression) ! IS_SET '(' set_statement_exists ')' ';'\n");

        if(verbose){
            $$ = createNode("is_set_expression");
            $$->children = $4;  

            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $4;  
        }
    }
;   

for:
    FOR '(' for_expression ')' statements {
        printf("[SYNTATIC] (for) FOR '(' for_expression ')' statement\n");

        $$ = createNode("for");
        $$->children = $3;
        $3->nxt = $5;  
        
        push_back_node(&treeNodeList, $$);
    }
;

for_expression:
    expression_assignment ';' expression_logical ';' expression_assignment {
        printf("[SYNTATIC] (for_expression) expression_assignment ';' expression_logical ';' expression_assignment\n");
        
        $$ = createNode("for_expression");
        $$->children = $1;
        $1->nxt = $3;  
        
        push_back_node(&treeNodeList, $$);
        $3->nxt = $5;  
        
    }
;

io_statement:
    READ '(' ID ')' ';' {
        printf("[SYNTATIC] (io_statement) READ '(' ID(%s) ')' ';'\n", $3.tokenBody);

        $$ = createNode("io_statement - READ");
        push_back_node(&treeNodeList, $$);
        $$->symbol = createSymbol($3.line, $3.column, "variable", lastType, $3.tokenBody, $3.scope);
        
    }
    | WRITE '(' STRING ')' ';' {
        printf("[SYNTATIC] (io_statement) WRITE '(' STRING(%s) ')' ';'\n", $3.tokenBody);
      
        $$ = createNode("io_statement - WRITE");
        $$->symbol = createSymbol($3.line, $3.column, "string", "", $3.tokenBody, $3.scope);
        
        push_back_node(&treeNodeList, $$);
        
    }
    | WRITE '(' expression ')' ';' {
        printf("[SYNTATIC] (io_statement) WRITE '(' expression ')' ';'\n");

        if(verbose){
            $$ = createNode("io_statement - WRITE");
            $$->children = $3;
           
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $3;  
        }
        
    }
    | WRITELN '(' STRING ')' ';' {
        printf("[SYNTATIC] (io_statement) WRITELN '(' STRING(%s) ')' ';'\n", $3.tokenBody);

        $$ = createNode("io_statement - WRITELN");
        $$->symbol = createSymbol($3.line, $3.column, "string", "", $3.tokenBody, $3.scope);
        
        push_back_node(&treeNodeList, $$);
      
    }
    | WRITELN '(' expression ')' ';' {
        printf("[SYNTATIC] (io_statement) WRITELN '(' expression ')' ';'\n");

        if(verbose){
            $$ = createNode("io_statement - WRITELN");
            $$->children = $3;
           
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $3;  
        }
        
    }
;

arguments_list:
    arguments_list ',' expression {
        printf("[SYNTATIC] (arguments_list) arguments_list ',' expression\n");

        $$ = createNode("arguments_list");
        $$->children = $1;
        $1->nxt = $3;
        
        push_back_node(&treeNodeList, $$);
        
    }
    | expression {
        printf("[SYNTATIC] (arguments_list) expression\n");

        if(verbose){
            $$ = createNode("arguments_list");
            $$->children = $1;
           
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;  
        }
        
    }
;

conditional:
    IF conditional_expression statements {
        printf("[SYNTATIC] (conditional) IF conditional_expression statements\n");

        $$ = createNode("conditional");
        $$->children = $2;
        $2->nxt = $3;
        push_back_node(&treeNodeList, $$);
 
    }
    | IF conditional_expression statements ELSE statements {
        printf("[SYNTATIC] (conditional) IF conditional_expression statements_braced ELSE statements_braced\n");

        $$ = createNode("conditional");
        $$->children = $2;
        $2->nxt = $3;
        $3->nxt = $5;
        
        push_back_node(&treeNodeList, $$);
        
    }
;

conditional_expression:
    '(' expression ')' {
        printf("[SYNTATIC] (conditional_expression) '(' expression ')'\n");

        if(verbose){
            $$ = createNode("conditional_expression");
            $$->children = $2;
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $2;  
        }
        
    }
;

return:
    RETURN expression ';' {
        printf("[SYNTATIC] (return) RETURN expression ';'\n");

        if(verbose){
            $$ = createNode("return");
            $$->children = $2;
            
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $2;  
        }
        
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
        $$->symbol = createSymbol($1.line, $1.column, "variable", lastType, $1.tokenBody, $1.scope);
        
        push_back_node(&treeNodeList, $$);
        
    }
    | const {
        printf("[SYNTATIC] (value) const\n");

        if(verbose){
            $$ = createNode("value");
            $$->children = $1;
           
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;  
        }
        

    }
    | function_call {
        printf("[SYNTATIC] (value) function_call\n");

        if(verbose){
            $$ = createNode("value");
            $$->children = $1;
           
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;  
        }
        
    }
;

function_call_statement:
    function_call ';' {
        printf("[SYNTATIC] (function_call_statement) function_call ';'\n");
        
        if(verbose){
            $$ = createNode("function_call_statement");
            $$->children = $1;
           
            push_back_node(&treeNodeList, $$);
        } else {
            $$ = $1;  
        }
        
    }
;

function_call:
    ID '(' arguments_list ')' {
        printf("[SYNTATIC] (function_call) ID(%s) '(' arguments_list ')'\n", $1.tokenBody);

        $$ = createNode("function_call");
        $$->children = $3;
        $$->symbol = createSymbol($1.line, $1.column, "function_call", "", $1.tokenBody, $1.scope);
        
        push_back_node(&treeNodeList, $$);
        
    }
    | ID '(' ')' {
        printf("[SYNTATIC] (function_call) ID(%s) '(' ')'\n", $1.tokenBody);

        $$ = createNode("function_call");
        $$->symbol = createSymbol($1.line, $1.column, "function_call", "", $1.tokenBody, $1.scope);
       
        push_back_node(&treeNodeList, $$);
        
    }
;

variables_declaration:
    type_identifier ID ';' {
        printf("[SYNTATIC] (variables_declaration) type_identifier ID(%s) ';'\n", $2.tokenBody);
        
        if(verbose){
            $$ = createNode("variables_declaration");
            $$->children = $1;

        } else {
            char aux[] = "variables_declaration - ";
            strcat(aux , $1->symbol->body);
            $$ = createNode(aux);
        }
        $$->symbol = createSymbol($2.line, $2.column, "variable", lastType, $2.tokenBody, $2.scope);

        push_back_node(&treeNodeList, $$);
        push_back(&tableList, createSymbol($2.line, $2.line, "variable", lastType, $2.tokenBody, $2.scope));
    }
;

const:
    INT_VALUE {
        printf("[SYNTATIC] (const) INT_VALUE = %s\n", $1.tokenBody);
        
        $$ = createNode("const");
        $$->symbol = createSymbol($1.line, $1.column, "INT", "INT", $1.tokenBody, $1.scope);
        
        push_back_node(&treeNodeList, $$);
        

    }
    | FLOAT_VALUE {
        printf("[SYNTATIC] (const) FLOAT_VALUE = %s\n", $1.tokenBody);
        
        $$ = createNode("const");
        $$->symbol = createSymbol($1.line, $1.column, "FLOAT", "FLOAT", $1.tokenBody, $1.scope);
        
        push_back_node(&treeNodeList, $$);
        
    }
    | EMPTY {
        printf("[SYNTATIC] (const) EMPTY\n");
        
        $$ = createNode("const");
        $$->symbol = createSymbol($1.line, $1.column, "EMPTY", "EMPTY", $1.tokenBody, $1.scope);
        
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

    verbose = 0;

    if(argc > 1){
        verbose = atoi(argv[1]);
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