%option noyywrap
%option noinput nounput

%{

    #include<stdio.h>
    #include<string.h>
    #include<stdlib.h>
    #include "syntatic.tab.h"
    #include "stack.h"
    #include "table.h"
    #include "tree.h"

    extern Stack stackScope;
    extern TableList tableList;
    extern TreeNode* root;

    extern char lastType[200];

    int lines = 1;
    int columns = 1;
    extern int errors;

%}


DIGIT                           [0-9]

ID                              [_a-zA-Z_][a-z0-9A-Z_]*

CONSTANT                        EMPTY

KEYWORD                         if|else|for|return

BASIC_TYPE                      int|float

SET                             set

ELEM                            elem

SET_ADD                         add

SET_REMOVE                      remove

SET_EXISTS                      exists

SET_IS_SET                      is_set

SET_FOR_ALL                     forall

SET_IN                          in

RELATIONAL_OP                   <|>|==|<=|>=|!=

MULTIPLICATIVE_OP               [*/%]

ADDITIVE_OP                     [+-]

IN                              read

OUT                             write|writeln

STRING                          \"[^\"]*\"|\'([^'\\\n]|\\.)'

COMMENT                         "//"

%%

{COMMENT}.* {
    printf("[LEXICO] Comment on line %d\n", lines);
}

{CONSTANT}|{DIGIT}+"."{DIGIT}+|{DIGIT}+ {
    strcpy(yylval.body.tokenBody, yytext);
    yylval.body.line = lines;
    yylval.body.column = columns;
    columns += yyleng;
    yylval.body.scope = top(&stackScope);

    if(strchr(yytext, '.') != NULL){
        printf("[LEXICO] Constant (Float): %s\n", yytext);
         return FLOAT_VALUE;
    } else if(yytext[0] == 'E'){
        printf("[LEXICO] Constant (Empty): %s\n", yytext);
        return EMPTY;
    } else {
        printf("[LEXICO] Constant (Int): %s\n", yytext);
        return INT_VALUE;
    }
}

{SET_ADD}|{SET_REMOVE}|{SET_EXISTS}|{SET_IS_SET}|{SET_FOR_ALL}|{SET_IN} {
    printf("[LEXICO] Set operator: %s\n", yytext);
    columns += yyleng;

    if(yytext[0] == 'a'){
        return ADD;
    } else if ( yytext[0] == 'r'){
        return REMOVE;
    } else if ( yytext[0] == 'e'){
        return EXISTS;
    } else if ( yytext[0] == 'f'){
        return FOR_ALL;
    } else if ( yytext[1] == 's'){
        return IS_SET;
    } else {
        return IN;
    }

}

{KEYWORD} {
    printf("[LEXICO] Keyword: %s\n", yytext );
    columns += yyleng;

    if(yytext[0] == 'i'){
        return IF;
    } else if(yytext[0] == 'e'){
        return ELSE;
    } else if(yytext[0] == 'f'){
        return FOR;
    } else if(yytext[0] == 'r'){
        return RETURN;
    } 
}

{OUT} {
    columns += yyleng;
    printf("[LEXICO] Write: %s\n", yytext);
    if(yytext[yyleng - 1] == 'n'){
        return WRITELN;
    } else {
        return WRITE;
    }
}

{IN} {
    printf("[LEXICO] Read: %s\n", yytext);
    columns += yyleng;
    return READ;
}

{BASIC_TYPE} {
    columns += yyleng;
    printf("[LEXICO] Basic type: %s (%d)\n", yytext, yyleng);
    if(yytext[0] == 'i'){
        return INT;
    } else {
        return FLOAT;
    }
}

{STRING} {
    printf("[LEXICO] String: %s\n", yytext);
    strcpy(yylval.body.tokenBody, yytext);
    yylval.body.line = lines;
    yylval.body.column = columns;
    yylval.body.scope = top(&stackScope);
    columns += yyleng;
    return STRING;
}

{SET}|{ELEM} {
    printf("[LEXICO] Custom type: %s\n", yytext);
    columns += yyleng;
    if(yytext[0] == 's'){
        return SET;
    } else {
        return ELEM;
    }
}


{ID} {
    if(yyleng >= 33) {
        printf("[LEXICO] WARNING:The idenfier length is too long, the idenfier was truncated to the first 33 characters\n");
        yytext[33] = 0;
    }
    strcpy(yylval.body.tokenBody, yytext);
    yylval.body.line = lines;
    yylval.body.column = columns;
    yylval.body.scope = top(&stackScope);
    printf("[LEXICO] Identifier: %s (%d)\n", yytext, yyleng);
    columns += yyleng;
    return ID;
}

"&&" {
    printf("[LEXICO] Logic AND operator: %s\n", yytext);
    columns += yyleng;
    return AND_OP;
}

"||" {
    printf("[LEXICO] Logic OR operator: %s\n", yytext);
    columns += yyleng;
    return OR_OP;
}

{RELATIONAL_OP} {
    printf("[LEXICO] Relational operator: %s\n", yytext);
    strcpy(yylval.body.tokenBody, yytext);
    yylval.body.line = lines;
    yylval.body.column = columns;
    yylval.body.scope = top(&stackScope);
    columns += yyleng;
    return RELATIONAL_OP;
}

{MULTIPLICATIVE_OP} {
    printf("[LEXICO] Multiplicative operator: %s\n", yytext);
    strcpy(yylval.body.tokenBody, yytext);
    yylval.body.line = lines;
    yylval.body.column = columns;
    yylval.body.scope = top(&stackScope);
    columns += yyleng;
    return MULTIPLICATIVE_OP;
}

{ADDITIVE_OP} {
    printf("[LEXICO] Additive operator: %s\n", yytext);
    strcpy(yylval.body.tokenBody, yytext);
    yylval.body.line = lines;
    yylval.body.column = columns;
    columns += yyleng;
    yylval.body.scope = top(&stackScope);
    return ADDITIVE_OP;
}

"=" {
    printf("[LEXICO] Enumerator operator: %s\n", yytext);
    columns += yyleng;
    return '=';
}

"!" {
    printf("[LEXICO] Not operator: %s\n", yytext);
    columns += yyleng;
    return '!';
}

";" {
    printf("[LEXICO] Command separator: %s\n", yytext);
    columns += yyleng;
    return ';';
}

"{"|"}" {
    columns += yyleng;
    printf("[LEXICO] Block delimiter: %s\n", yytext);
    if(yytext[0] == '{'){
        push(&stackScope);
        printf("ESCOPO: %d\n", top(&stackScope));  
        return '{';
    } else {
        pop(&stackScope);
        printf("ESCOPO: %d\n", top(&stackScope));  
        return '}';
    }
}

"("|")" {
    printf("[LEXICO] Expression delimiter: %s (%d)\n", yytext, yyleng);
    columns += yyleng;
    if(yytext[0] == '('){
        return '(';
    } else {
        return ')';
    }
}

"," {
    printf("[LEXICO] Variable separator: %s\n", yytext);
    columns += yyleng;
    return ',';
}

[ \t]+ {
    printf("[LEXICO] spaces(%d)\n",yyleng);
    columns += yyleng;
}

\n|\r {
    printf("[LEXICO] ENDL\n");
    lines++;
    columns = 1;
}

. {
    errors++;
    printf("[LEXICO] ERROR line: %d columns: %d Undentified char: %s \n", lines, columns, yytext );
}

%%