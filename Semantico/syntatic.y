%define lr.type canonical-lr
%define parse.error verbose

%defines

%{
    #include <stdlib.h>
    #include <stdio.h>
    #include <string.h>
    #include "stack.h"
    #include "table.h"
    #include "tree.h"
    #include "error.h"
    #include "semantic.h"
    #include "utils.h"

    extern int yylex();
    extern int yyparse();
    extern int yyerror(const char* message);
    extern int yylex_destroy();
    extern FILE* yyin;

    // Tree
    extern TreeNode* root;

    // Table
    extern TableList tableList;

    // Stack
    extern Stack stackScope;

    // Utils
    extern int errors;
    extern int verbose;
    extern char lastType[200];
    extern char fileName[200];
    extern GarbageCollector garbageCollector;


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
%right THEN ELSE
%token SET
%token FOR
%token WRITE
%token WRITELN
%token READ
%token FLOAT
%token INT
%token FOR_ALL

%token <body> RETURN
%token <body> ADD
%token <body> REMOVE
%token <body> EXISTS
%token <body> IS_SET
%token <body> INT_VALUE
%token <body> FLOAT_VALUE
%token <body> EMPTY
%token <body> ID
%token <body> STRING

%left <body> IN 
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
%type <node> expression_or_empty
%type <node> expression
%type <node> expression_assignment
%type <node> expression_logical
%type <node> expression_relational
%type <node> expression_additive
%type <node> expression_multiplicative
%type <node> expression_value
%type <node> is_set_expression
%type <node> for
%type <node> for_expression
%type <node> io_statement
%type <node> arguments_list
%type <node> conditional
%type <node> return
%type <node> value
%type <node> function_call
%type <node> variables_declaration
%type <node> const


%start start

%%

start:
	program {
        // printf("[SYNTATIC] (start) program\n");
        root = createNode("start");

        $$ = root;
        $$->children = $1;
    }
;

program:
	function_definition {
        // printf("[SYNTATIC] (program) function_definition\n");

        if(verbose){
            $$ = createNode("program");
            $$->children = $1;
        } else {
            $$ = $1;
        }
    }
	| function_definition program {
        // printf("[SYNTATIC] (program) function_definition program\n");

        $$ = createNode("program");
        $$->children = $1;
        $1->nxt = $2;
        
    }
	| variables_declaration program {
        // printf("[SYNTATIC] (program) variables_declaration program\n");

        $$ = createNode("program");
        $$->children = $1;
        $1->nxt = $2;
        
    }
;

function_definition:
	function_declaration '(' {
        push(&stackScope);

    } parameters {
        char paramsAsString[100] = "";
        getTreeTypeList($4, paramsAsString);
        $1->symbol->paramsType = strdup(paramsAsString);

        pop(&stackScope);
        stackScope.nxtScope--; // Gambiarra here

    } ')'  function_body {
        // printf("[SYNTATIC] (function_definition) function_declaration '(' parameters ')' function_body\n");
        
        $$ = createNode("function_definition");

        $$->children = $1;
        $1->nxt = $4;
        $4->nxt = $7;
        
    }
    | function_declaration '(' ')' function_body {
        // printf("[SYNTATIC] (function_definition) function_declaration '(' ')' function_body\n");
               
        $$ = createNode("function_definition");
        $$->children = $1;
        $1->nxt = $4;
        
    }
;

function_declaration:
	type_identifier ID {
        // printf("[SYNTATIC] (function_declaration) type_identifier ID(%s)\n", $2.tokenBody);

        checkDuplicatedFunc(&tableList, $2.line, $2.column, $2.tokenBody, $2.scope);

        if(verbose){
            $$ = createNode("function_declaration");
            $$->children = $1;
        } else {
            char aux[] = "function_declaration - ";
            strcat(aux , $1->symbol->body);
            $$ = createNode(aux);
        }

        $$->symbol = createSymbol($2.line, $2.column, "function", lastType, $2.tokenBody, $2.scope);
        $$->type = getTypeID($1->symbol->body);

        push_back(&tableList, $$->symbol);
    }
;

function_body:
	'{' statements '}' {
        // printf("[SYNTATIC] (function_body) '{' statements '}'\n");

        if(verbose){
            $$ = createNode("function_body");
            $$->children = $2;

        } else {
            $$ = $2;
        }
    }
    | '{' '}' {
        // printf("[SYNTATIC] (function_body) '{' '}'\n");

        $$ = createNode("function_body");
    }
;

parameters:
	parameters_list {
        // printf("[SYNTATIC] (parameters)  parameters_list \n");

        if(verbose){
            $$ = createNode("parameters_list");
            $$->children = $1;

        } else {
            $$ = $1;
        }
    }
;

parameters_list:
	parameters_list ',' parameter {
        // printf("[SYNTATIC] (parameters_list) parameter ',' parameters_list\n");
        $$ = createNode("parameters_list");
        $$->children = $1;
        $1->nxt = $3;
    } 
	| parameter {
        // printf("[SYNTATIC] (parameters_list) parameter\n");
        if(verbose){
            $$ = createNode("parameters_list");
            $$->children = $1;
            
        } else {
            $$ = $1;
        }
    }
;

parameter:
	type_identifier ID {
        // printf("[SYNTATIC] (parameter) type_identifier ID(%s)\n", $2.tokenBody);
        if(verbose){
            $$ = createNode("parameter");
            $$->children = $1;
        } else {
            char aux[] = "parameter - ";
            strcat(aux , $1->symbol->body);
            $$ = createNode(aux);
        }
        checkDuplicatedVar(&tableList, $2.line, $2.column, $2.tokenBody, $2.scope);
        $$->type = getTypeID($1->symbol->body);
        $$->symbol = createSymbol($2.line, $2.column, "param variable", lastType, $2.tokenBody, $2.scope);
        push_back(&tableList, $$->symbol);
    }
;

type_identifier:
	INT {
        // printf("[SYNTATIC] (type_identifier) INT\n");
        $$ = createNode("type_identifier");
        $$->symbol = createSymbol(-1 , -1, "Type", lastType, "INT", -1);
        strcpy(lastType, "INT");
    }
    | FLOAT {
        // printf("[SYNTATIC] (type_identifier) FLOAT\n");
        $$ = createNode("type_identifier");
        $$->symbol = createSymbol(-1 , -1, "Type", lastType, "FLOAT", -1);
        strcpy(lastType, "FLOAT");
    }
	| ELEM {
        // printf("[SYNTATIC] (type_identifier) ELEM\n");
        $$ = createNode("type_identifier");
        $$->symbol = createSymbol(-1 , -1, "Type", lastType, "ELEM", -1);
        strcpy(lastType, "ELEM");
    }
    | SET{
        // printf("[SYNTATIC] (type_identifier) SET\n");
        $$ = createNode("type_identifier");
        $$->symbol = createSymbol(-1 , -1, "Type", lastType, "SET", -1);
        strcpy(lastType, "SET");
    }
;

statements:
	statement statements {
        // printf("[SYNTATIC] (statements) statement statements\n");
        $$ = createNode("statements");
        $$->children = $1;
        $1->nxt = $2;
    }
	| statement {
        // printf("[SYNTATIC] (statements) statement\n");   
        if(verbose){
            $$ = createNode("statements");
            $$->children = $1;
        } else {
             $$ = $1;
        }
    }
;

statements_braced:
    '{' statements '}' {
        // printf("[SYNTATIC] (statements_braced) '{' statements '}'\n");
        if(verbose){
            $$ = createNode("statements_braced");
            $$->children = $2;

        } else{
            $$ = $2;
        }
    }
    | '{' '}' {
        // printf("[SYNTATIC] (statements_braced) '{' '}'\n");
        $$ = createNode("statements_braced");
    }
;

statement:
	variables_declaration {
        // printf("[SYNTATIC] (statement) variables_declaration\n");
        if(verbose){
            $$ = createNode("statement");
            $$->children = $1;   
        } else {
            $$ = $1;   
        }
    }
    | statements_braced {
        if(verbose){
            $$ = createNode("statement");
            $$->children = $1;   
        } else {
            $$ = $1;   
        }
    }
	| return {
        // printf("[SYNTATIC] (statement) return\n");
        if(verbose){
            $$ = createNode("statement");
            $$->children = $1;    
        } else {
            $$ = $1;   
        }
    }
	| conditional {
        // printf("[SYNTATIC] (statement) conditional\n");   
        if(verbose){
            $$ = createNode("statement");
            $$->children = $1;  
        } else {
            $$ = $1;   
        }
    }
	| for {
        // printf("[SYNTATIC] (statement) for\n");
        if(verbose){
            $$ = createNode("statement");
            $$->children = $1;   
        } else {
            $$ = $1;   
        }
    }
	| expression_statement {
        // printf("[SYNTATIC] (statement) expression_statement \n");
        if(verbose){
            $$ = createNode("statement");
            $$->children = $1;   
        } else {
            $$ = $1;   
        }
    }
	| io_statement {
        // printf("[SYNTATIC] (statement) io_statement\n");
        if(verbose){
            $$ = createNode("statement");
            $$->children = $1;  
        } else {
            $$ = $1;   
        }
    }
	| set_pre_statement {
        // printf("[SYNTATIC] (statement) set_pre_statement\n");
        if(verbose){
            $$ = createNode("statement");
            $$->children = $1;  
        } else {
            $$ = $1;   
        }
    }
;

set_pre_statement:
    set_statement_for_all {
        // printf("[SYNTATIC] (set_pre_statement) set_statement_for_all\n");  
        if(verbose){
            $$ = createNode("set_pre_statement");
            $$->children = $1;
        } else {
            $$ = $1;   
        }
    }
;

set_statement_add_remove:
    ADD '(' set_boolean_expression ')' {
        // printf("[SYNTATIC] (set_statement_add_remove) ADD '(' set_boolean_expression ')'\n"); 
        $$ = createNode("set_statement_add_remove");
        $$->children = $3;
        $$->symbol = createSymbol($1.line, $1.column, "set function", "", $1.tokenBody, $1.scope);
        $$->type = getTypeID("SET");
    }
    | REMOVE '(' set_boolean_expression ')' {
        // printf("[SYNTATIC] (set_statement_add_remove) REMOVE '(' set_boolean_expression ')'\n"); 
        $$ = createNode("set_statement_add_remove");
        $$->symbol = createSymbol($1.line, $1.column, "set function", "", $1.tokenBody, $1.scope);
        $$->children = $3;
        $$->type = getTypeID("SET");   
    }
;

set_statement_for_all:
    FOR_ALL '(' set_assignment_expression ')' statement {
        // printf("[SYNTATIC] (set_statement_for_all) FOR_ALL '(' set_assignment_expression ')' statements\n"); 
        $$ = createNode("set_statement_for_all");
        $$->children = $3;
        $3->nxt = $5;
    }
;

set_statement_exists:
    EXISTS '(' set_assignment_expression ')' {
        // printf("[SYNTATIC] (set_statement_exists) EXISTS '(' set_assignment_expression ')'\n"); 
        $$ = createNode("set_statement_exists");
        $$->symbol = createSymbol($1.line, $1.column, "set function", "", $1.tokenBody, $1.scope);
        $$->children = $3;
        $$->type = getTypeID("ELEM");
    }
;

set_boolean_expression:
    expression IN set_statement_add_remove {
        // printf("[SYNTATIC] (set_boolean_expression) expression IN set_statement_add_remove\n");
        if(checkSingleCast($1, getTypeID("ELEM"))) execSingleCast($1, getTypeID("ELEM"));
        checkStructureBoolINSet($1->type, $3->type, getTypeID("ELEM"), getTypeID("SET"), $2.line, $2.column, $2.tokenBody);

        $$ = createNode("set_boolean_expression");
        $$->children = $1;
        $1->nxt = $3;
        $$->type = getTypeID("INT");

        char *body = getCastExpression($1, $3, $2.tokenBody);
        $$->symbol = createSymbol($2.line, $2.column, "boolean operator", "", body, $2.scope);
        pushGarbageCollector(NULL, body);
    }
    | expression IN ID {
        // printf("[SYNTATIC] (set_boolean_expression) expression IN ID(%s)\n", $3.tokenBody);
        Symbol* s = checkVarExist(&tableList, $3.line, $3.column, $3.tokenBody, $3.scope);
        TreeNode* nodeID = createIDNode(s, $3.line, $3.column, $3.tokenBody, $3.scope);

        if(checkSingleCast($1, getTypeID("ELEM"))) execSingleCast($1, getTypeID("ELEM"));
        checkStructureBoolINSet($1->type, s ? getTypeID(s->type):9, getTypeID("ELEM"), getTypeID("SET"), $2.line, $2.column, $2.tokenBody);

        $$ = createNode("set_boolean_expression");
        $$->children = $1;
        $1->nxt = nodeID;
        $$->type = getTypeID("INT");

        char *body = getCastExpression($1, nodeID, $2.tokenBody);
        $$->symbol = createSymbol($2.line, $2.column, "boolean operator", "", body, $2.scope);
        pushGarbageCollector(NULL, body);
    }
;

set_assignment_expression:
    ID IN set_statement_add_remove {
        // printf("[SYNTATIC] (set_assignment_expression) expression IN set_statement_add_remove\n");
        Symbol* s = checkVarExist(&tableList, $1.line, $1.column, $1.tokenBody, $1.scope);
        TreeNode* nodeID = createIDNode(s, $1.line, $1.column, $1.tokenBody, $1.scope);

        if(checkSingleCast($3, getTypeID("SET"))) execSingleCast($3, getTypeID("SET"));
        
        $$ = createNode("set_assignment_expression");
        $$->children = nodeID;
        $$->children->nxt = $3;
        $$->type = getTypeID("ELEM");   

        char *body =  getCastExpressionSymbol(s, $3, $2.tokenBody);
        $$->symbol = createSymbol($2.line, $2.column, "assignment operator", "", body, $2.scope);
        pushGarbageCollector(NULL, body);
    }
    | ID IN ID {
        // printf("[SYNTATIC] (set_assignment_expression) ID(%s) IN ID(%s)\n", $1.tokenBody, $3.tokenBody);

        Symbol* s1 = checkVarExist(&tableList, $1.line, $1.column, $1.tokenBody, $1.scope);
        Symbol* s2 = checkVarExist(&tableList, $3.line, $3.column, $3.tokenBody, $3.scope);

        TreeNode* nodeID1 = createIDNode(s1, $1.line, $1.column, $1.tokenBody, $1.scope);
        TreeNode* nodeID2 = createIDNode(s2, $3.line, $3.column, $3.tokenBody, $3.scope);

        if(checkSingleCast(nodeID2, getTypeID("SET"))) execSingleCast(nodeID2, getTypeID("SET"));

        $$ = createNode("set_assignment_expression");
        $$->children = nodeID1;
        $$->children->nxt = nodeID2;
        $$->type = getTypeID("ELEM");

        char *body =  getCastExpression(nodeID1, nodeID2, $2.tokenBody);
        $$->symbol = createSymbol($2.line, $2.column, "assignment operator", "", body, $2.scope);
        pushGarbageCollector(NULL, body);
    }
;

expression_statement:
    expression ';' {
        // printf("[SYNTATIC] (expression_statement) expression\n");
        if(verbose){
            $$ = createNode("expression_statement");
            $$->children = $1;
        } else {
            $$ = $1;   
        }
    }
;

expression_or_empty:
    expression {
        $$ = $1;   
    }
    | %empty {
        $$ = createNode("expression_or_empty");
        $$->type = getTypeID("INT");
    }
;

expression:
    expression_assignment {
        // printf("[SYNTATIC] (expression) expression_assignment\n");
        if(verbose){
            $$ = createNode("expression");
            $$->children = $1;
            
        } else {
            $$ = $1;   
        }
    }
;

expression_assignment:
    expression_logical {
        // printf("[SYNTATIC] (expression_assignment) expression_logical\n");
        if(verbose){
            $$ = createNode("expression_assignment");
            $$->children = $1;   
            
        } else {
            $$ = $1;   
        }
    }
    | ID '=' expression {
        // printf("[SYNTATIC] (expression_assignment) ID(%s) '='  expression\n", $1.tokenBody);
        $$ = createNode("expression_assignment");
        $$->children = $3;
        
        Symbol* s = checkVarExist(&tableList, $1.line, $1.column, $1.tokenBody, $1.scope);
        if(s){
            if(checkCastSymbol(s, $3)) execForceCastSymbol(s, $3);
            checkMissType(getTypeID(s->type), $3->type, $1.line, $1.column, "=");
        }

        char *body =  getCastExpressionSymbol(s, $3, "=");
        $$->symbol = createSymbol($1.line, $1.column, "assignment operator", "", body, $1.scope);
        pushGarbageCollector(NULL, body);
    }
;

expression_logical:
    expression_relational {
        // printf("[SYNTATIC] (expression_logical) expression_relational\n");
        if(verbose){
            $$ = createNode("expression_logical");
            $$->children = $1;   
            
        } else {
            $$ = $1;   
        }
    }
    | set_boolean_expression {
        // printf("[SYNTATIC] (expression_logical) set_expression\n");
        if(verbose){
            $$ = createNode("expression_logical");
            $$->children = $1;   
            
        } else {
            $$ = $1;   
        }
    }
    | expression_logical AND_OP expression_relational {
        // printf("[SYNTATIC] (expression_logical) expression_logical AND_OP(&&) expression_logical\n");
        $$ = createNode("expression_logical");
        $$->children = $1;
        $1->nxt = $3;

        if(checkCast($1, $3)) execCast($1, $3);
        $$->type = $1->type;
        checkMissType($1->type, $3->type, $2.line, $2.column, $2.tokenBody);

        char* body = getCastExpression($1, $3, $2.tokenBody);
        $$->symbol = createSymbol($2.line, $2.column, "logical operator", "", body, $2.scope);
        pushGarbageCollector(NULL, body);
    }
    | expression_logical OR_OP expression_relational {
        // printf("[SYNTATIC] (expression_logical) expression_logical OR_OP(||) expression_logical\n");
        $$ = createNode("expression_logical");
        $$->children = $1;
        $1->nxt = $3;

        if(checkCast($1, $3)) execCast($1, $3);
        $$->type = $1->type;
        checkMissType($1->type, $3->type, $2.line, $2.column, $2.tokenBody);

        char* body = getCastExpression($1, $3, $2.tokenBody);
        $$->symbol = createSymbol($2.line, $2.column, "logical operator", "", body, $2.scope);
        pushGarbageCollector(NULL, body);
    }
;

expression_relational:
    expression_additive {
        // printf("[SYNTATIC] (expression_relational) expression_additive \n");
        if(verbose){
            $$ = createNode("expression_relational");
            $$->children = $1;   
            
        } else {
            $$ = $1;   
        }
    }
    | expression_relational RELATIONAL_OP expression_additive {
        // printf("[SYNTATIC] (expression_relational) expression_relational RELATIONAL_OP(%s) expression_relational\n", $2.tokenBody);
        $$ = createNode("expression_relational");
        $$->children = $1;   
        $1->nxt = $3;

        if(checkCast($1, $3)) execCast($1, $3);
        $$->type = getTypeID("INT");
        checkMissType($1->type, $3->type, $2.line, $2.column, $2.tokenBody);

        char *body =  getCastExpression($1, $3, $2.tokenBody);
        $$->symbol = createSymbol($2.line, $2.column, "relational operator", "", body, $2.scope);
        pushGarbageCollector(NULL, body);
    }
;

expression_additive:
    expression_multiplicative {
        // printf("[SYNTATIC] (expression_additive) expression_multiplicative \n");
        if(verbose){
            $$ = createNode("expression_additive");
            $$->children = $1;   
            
        } else {
            $$ = $1;   
        }
    }
    | expression_additive ADDITIVE_OP expression_multiplicative {
        // printf("[SYNTATIC] (expression_additive) expression_additive ADDITIVE_OP(%s) expression_additive \n", $2.tokenBody);
        $$ = createNode("expression_additive");
        $$->children = $1;   
        $1->nxt = $3;

        if(checkCast($1, $3)) execCast($1, $3);
        $$->type = $1->type;
        checkMissType($1->type, $3->type, $2.line, $2.column, $2.tokenBody);
        
        char *body = getCastExpression($1, $3, $2.tokenBody);
        $$->symbol = createSymbol($2.line, $2.column, "additive operator", "", body, $2.scope);
        pushGarbageCollector(NULL, body);
    }
;

expression_multiplicative:
    expression_value {
        // printf("[SYNTATIC] (expression_multiplicative) expression_value \n");
        if(verbose){
            $$ = createNode("expression_multiplicative");
            $$->children = $1;
            
        } else {
            $$ = $1;   
        }
    }
    | expression_multiplicative MULTIPLICATIVE_OP expression_value {
        // printf("[SYNTATIC] (expression_multiplicative)  expression_multiplicative MULTIPLICATIVE_OP(%s) expression_multiplicative \n", $2.tokenBody);
        $$ = createNode("expression_multiplicative");
        $$->children = $1;   
        $1->nxt = $3;

        if(checkCast($1, $3)) execCast($1, $3);
        $$->type = $1->type;
        checkMissType($1->type, $3->type, $2.line, $2.column, $2.tokenBody);

        char *body = getCastExpression($1, $3, $2.tokenBody);
        $$->symbol = createSymbol($2.line, $2.column, "multiplicative operator", "", body, $2.scope);
        pushGarbageCollector(NULL, body);
    }
;

expression_value:
    '(' expression ')' {
        // printf("[SYNTATIC] (expression_value) '(' expression ')' \n");
        if(verbose){
            $$ = createNode("expression_value");
            
            $$->children = $2;   
        } else {
            $$ = $2;   
        }
    }
    | '!' '(' expression ')' {
        // printf("[SYNTATIC] (expression_value) ! '(' expression ')' \n");
        if(verbose){
            $$ = createNode("expression_value");
            $$->children = $3;
            
        } else {
            $$ = $3;   
        }
    }
    | ADDITIVE_OP '(' expression ')' {
        // printf("[SYNTATIC] (expression_value) ADDITIVE_OP(%s) '(' expression ')' \n", $1.tokenBody);
        $$ = createNode("expression_value");
        $$->children = $3;
        $$->symbol = createSymbol($1.line, $1.column, "additive operator", "", $1.tokenBody, $1.scope); 
        $$->type = $3->type;
    }
    | value {
        // printf("[SYNTATIC] (expression_value) value \n");
        if(verbose){
            $$ = createNode("expression_value");
            $$->children = $1;
            
        } else {
            $$ = $1;   
        }
    }
    | '!' value {
        // printf("[SYNTATIC] (expression_value) ! value \n");
        if(verbose){
            $$ = createNode("expression_value");
            
            $$->children = $2;
        } else {
            $$ = $2;   
        }  
    }
    | ADDITIVE_OP value {
        // printf("[SYNTATIC] (expression_value) ADDITIVE_OP(%s) value \n", $1.tokenBody);
        $$ = $2;
    }
    | is_set_expression {
        // printf("[SYNTATIC] (is_set_expression) is_set_expression\n");
        if(verbose){
            $$ = createNode("expression_logical");
            $$->children = $1;   
            
        } else {
            $$ = $1;   
        }
    }
    | set_statement_exists {
        // printf("[SYNTATIC] (expression_value) set_statement_exists\n");

        if(verbose){
            $$ = createNode("expression_value");
            $$->children = $1;  
            
        } else {
            $$ = $1;   
        }
    }
    | set_statement_add_remove {
        if(verbose){
            $$ = createNode("expression_value");
            $$->children = $1;  
            
        } else {
            $$ = $1;   
        }
    }
;

is_set_expression: 
    IS_SET '(' expression ')' {
        // printf("[SYNTATIC] (is_set_expression) IS_SET '(' expression ')' ';'\n");
        $$ = createNode("is_set_expression");
        $$->symbol = createSymbol($1.line, $1.column, "set function", "", $1.tokenBody, $1.scope);
        $$->children = $3;
        $$->type = getTypeID("INT");  
    }
    | '!' IS_SET '(' expression ')' {
        // printf("[SYNTATIC] (is_set_expression) ! IS_SET '(' expression ')' ';'\n");
        $$ = createNode("is_set_expression");
        $$->symbol = createSymbol($2.line, $2.column, "set function", "", $2.tokenBody, $2.scope);
        $$->children = $4;
        $$->type = getTypeID("INT");    
    }
;   

for:
    FOR '(' for_expression ')' statement {
        // printf("[SYNTATIC] (for) FOR '(' for_expression ')' statement\n");
        $$ = createNode("for");
        $$->children = $3;
        $3->nxt = $5;  
    }
;

for_expression:
    expression_or_empty ';' expression_or_empty ';' expression_or_empty {
        // printf("[SYNTATIC] (for_expression) expression_assignment ';' expression_logical ';' expression_assignment\n");
        $$ = createNode("for_expression");
        $$->children = $1;
        $1->nxt = $3;  
        $3->nxt = $5;  
    }
;

io_statement:
    READ '(' ID ')' ';' {
        // printf("[SYNTATIC] (io_statement) READ '(' ID(%s) ')' ';'\n", $3.tokenBody);

        $$ = createNode("io_statement - READ");
        $$->symbol = createSymbol($3.line, $3.column, "variable", lastType, $3.tokenBody, $3.scope);
    }
    | WRITE '(' STRING ')' ';' {
        // printf("[SYNTATIC] (io_statement) WRITE '(' STRING(%s) ')' ';'\n", $3.tokenBody);
        $$ = createNode("io_statement - WRITE");
        $$->symbol = createSymbol($3.line, $3.column, "string", "", $3.tokenBody, $3.scope);
    }
    | WRITE '(' expression ')' ';' {
        // printf("[SYNTATIC] (io_statement) WRITE '(' expression ')' ';'\n");
        $$ = createNode("io_statement - WRITE");
        $$->children = $3;
    }
    | WRITELN '(' STRING ')' ';' {
        // printf("[SYNTATIC] (io_statement) WRITELN '(' STRING(%s) ')' ';'\n", $3.tokenBody);
        $$ = createNode("io_statement - WRITELN");
        $$->symbol = createSymbol($3.line, $3.column, "string", "", $3.tokenBody, $3.scope);
    }
    | WRITELN '(' expression ')' ';' {
        // printf("[SYNTATIC] (io_statement) WRITELN '(' expression ')' ';'\n");
        $$ = createNode("io_statement - WRITELN");
        $$->children = $3;
    }
;

arguments_list:
    arguments_list ',' expression {
        // printf("[SYNTATIC] (arguments_list) arguments_list ',' expression\n");
        $$ = createNode("arguments_list");
        $$->children = $1;
        $1->nxt = $3;
    }
    | expression {
        // printf("[SYNTATIC] (arguments_list) expression\n");
        if(verbose){
            $$ = createNode("arguments_list");
            $$->children = $1;
           
        } else {
            $$ = $1;  
        }
    }
;

conditional:
    IF '(' expression ')' statement %prec THEN{
        // printf("[SYNTATIC] (conditional) IF conditional_expression statements\n");
        $$ = createNode("conditional");
        $$->children = $3;
        $3->nxt = $5;
    }
    | IF '(' expression ')' statement ELSE statement {
        // printf("[SYNTATIC] (conditional) IF conditional_expression statements_braced ELSE statements_braced\n");
        $$ = createNode("conditional");
        $$->children = $3;
        $3->nxt = $5;
        $5->nxt = $7;
    }
;


return:
    RETURN expression ';' {
        // printf("[SYNTATIC] (return) RETURN expression ';'\n");
        Symbol* s = getClosestFunctionFromLine(&tableList, $1.line);
        
        if(s){
            checkAndExecForceCast($2, getTypeID(s->type));
            checkMissTypeReturn(getTypeID(s->type), $2->type, $1.line, $1.column, s->body);
        }

        $$ = createNode("return");
        $$->children = $2;
    }
    | RETURN ';' {
        // printf("[SYNTATIC] (return) RETURN ';'\n");
        $$ = createNode("return");
    }
;

value:
    ID {
        // printf("[SYNTATIC] (value) ID = %s\n", $1.tokenBody);
        $$ = createNode("value");
        Symbol* s = checkVarExist(&tableList, $1.line, $1.column, $1.tokenBody, $1.scope);

        $$->symbol = s ? createSymbol($1.line, $1.column, "variable", s->type, $1.tokenBody, $1.scope) :
                         createSymbol($1.line, $1.column, "variable", "??", $1.tokenBody, $1.scope);

        $$->type = getTypeID($$->symbol->type);
    }
    | const {
        // printf("[SYNTATIC] (value) const\n");
        if(verbose){
            $$ = createNode("value");
            $$->children = $1;
        } else {
            $$ = $1;  
        }
    }
    | function_call {
        // printf("[SYNTATIC] (value) function_call\n");
        if(verbose){
            $$ = createNode("value");
            $$->children = $1;
           
        } else {
            $$ = $1;  
        }
    }
;

function_call:
    ID '(' arguments_list ')' {
        // printf("[SYNTATIC] (function_call) ID(%s) '(' arguments_list ')'\n", $1.tokenBody);

        $$ = createNode("function_call");
        $$->children = $3;

        Symbol* s = checkFuncExist(&tableList, $1.line, $1.column, $1.tokenBody, $1.scope);

        $$->symbol = s ? createSymbol($1.line, $1.column, "function_call", s->type, $1.tokenBody, $1.scope) :
                         createSymbol($1.line, $1.column, "function_call", "??", $1.tokenBody, $1.scope);

        if(s && strcmp(s->classType, "function") == 0){
            $$->type = getTypeID($$->symbol->type);

            int x = 0;
            char argsAsString[100] = "";
            char *funcParams = getSymbol(&tableList, $1.tokenBody, 0)->paramsType;
            
            checkAndExecForceCastArgs($3, funcParams, &x);

            getTreeTypeList($3, argsAsString);
            checkArgsParms(argsAsString, funcParams, $1.line, $1.column, $1.tokenBody);
        }
    }
    | ID '(' ')' {
        // printf("[SYNTATIC] (function_call) ID(%s) '(' ')'\n", $1.tokenBody);

        $$ = createNode("function_call");

        Symbol* s = checkFuncExist(&tableList, $1.line, $1.column, $1.tokenBody, $1.scope);

        $$->symbol = s ? createSymbol($1.line, $1.column, "function_call", s->type, $1.tokenBody, $1.scope) :
                         createSymbol($1.line, $1.column, "function_call", "??", $1.tokenBody, $1.scope);

        if(s && strcmp(s->classType, "function_call") == 0) {
            $$->type = getTypeID($$->symbol->type);
            char argsAsString[] = "";
            checkArgsParms(argsAsString, getSymbol(&tableList, $1.tokenBody, 0)->paramsType, $1.line, $1.column, $1.tokenBody);
        }
    }
;

variables_declaration:
    type_identifier ID ';' {
        // printf("[SYNTATIC] (variables_declaration) type_identifier ID(%s) ';'\n", $2.tokenBody);
        
        checkDuplicatedVar(&tableList, $2.line, $2.column, $2.tokenBody, $2.scope);
        
        char aux[] = "variables_declaration - ";
        strcat(aux , $1->symbol->body);
        $$ = createNode(aux);

        $$->symbol = createSymbol($2.line, $2.column, "variable", lastType, $2.tokenBody, $2.scope);
        $$->type = getTypeID($$->symbol->type);

        push_back(&tableList, $$->symbol);
    }
;

const:
    INT_VALUE {
        // printf("[SYNTATIC] (const) INT_VALUE = %s\n", $1.tokenBody);
        $$ = createNode("const");
        $$->symbol = createSymbol($1.line, $1.column, "INT", "INT", $1.tokenBody, $1.scope);
        $$->type = getTypeID("INT");
    }
    | FLOAT_VALUE {
        // printf("[SYNTATIC] (const) FLOAT_VALUE = %s\n", $1.tokenBody);
        $$ = createNode("const");
        $$->symbol = createSymbol($1.line, $1.column, "FLOAT", "FLOAT", $1.tokenBody, $1.scope);
        $$->type = getTypeID("FLOAT");
    }
    | EMPTY {
        // printf("[SYNTATIC] (const) EMPTY\n");
        $$ = createNode("const");
        $$->symbol = createSymbol($1.line, $1.column, "EMPTY", "EMPTY", $1.tokenBody, $1.scope);
        $$->type = getTypeID("EMPTY");
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
        strcpy(fileName, argv[0]);
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
    garbageCollector.nodeSize = -1;
    garbageCollector.strSize = -1;

    push(&stackScope);

    errors = 0;

    int ok[10000];
    memset(ok, 0, sizeof(ok));

    printf("\n");
    yyparse();
    printf("\n");

    checkMainFunc();

    if(errors){
        printf("Program analysis failed!\nAnalysis terminated with %d error(s)\n\n", errors);
    }
    else{
        printf("Correct program.\n\n");
    }

    printTree(root, 1, ok);
    printTable(&tableList);
    
    // Don't need to free the table because 
    // the table only contains symbols and the freeNodeList will free that pointer
    // freeTable(&tableList); 

    freeGarbageCollector();

    fclose(yyin);
    yylex_destroy();

    return 0;
}
