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
    #include "error.h"

    extern Stack stackScope;
    extern TableList tableList;
    extern TreeNode* root;

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
    // printf("[LEXIC] Comment on line %d\n", lines);
}

{CONSTANT}|{DIGIT}+"."{DIGIT}+|{DIGIT}+ {
    strcpy(yylval.body.tokenBody, yytext);
    yylval.body.line = lines;
    yylval.body.column = columns;
    columns += yyleng;
    yylval.body.scope = top(&stackScope);

    if(strchr(yytext, '.') != NULL){
        // printf("[LEXIC] Constant (Float): %s\n", yytext);
         return FLOAT_VALUE;
    } else if(yytext[0] == 'E'){
        // printf("[LEXIC] Constant (Empty): %s\n", yytext);
        return EMPTY;
    } else {
        // printf("[LEXIC] Constant (Int): %s\n", yytext);
        return INT_VALUE;
    }
}

{SET_ADD}|{SET_REMOVE}|{SET_EXISTS}|{SET_IS_SET}|{SET_FOR_ALL}|{SET_IN} {
    // printf("[LEXIC] Set operator: %s\n", yytext);
    columns += yyleng;

    if(yytext[0] == 'a'){
        strcpy(yylval.body.tokenBody, yytext);
        yylval.body.line = lines;
        yylval.body.column = columns;
        yylval.body.scope = top(&stackScope);
        return ADD;
    } else if ( yytext[0] == 'r'){
        strcpy(yylval.body.tokenBody, yytext);
        yylval.body.line = lines;
        yylval.body.column = columns;
        yylval.body.scope = top(&stackScope);
        return REMOVE;
    } else if ( yytext[0] == 'e'){
        strcpy(yylval.body.tokenBody, yytext);
        yylval.body.line = lines;
        yylval.body.column = columns;
        yylval.body.scope = top(&stackScope);
        return EXISTS;
    } else if ( yytext[0] == 'f'){
        return FOR_ALL;
    } else if ( yytext[1] == 's'){
        strcpy(yylval.body.tokenBody, yytext);
        yylval.body.line = lines;
        yylval.body.column = columns;
        yylval.body.scope = top(&stackScope);
        return IS_SET;
    } else {
        strcpy(yylval.body.tokenBody, yytext);
        yylval.body.line = lines;
        yylval.body.column = columns;
        yylval.body.scope = top(&stackScope);
        return IN;
    }

}

{KEYWORD} {
    // printf("[LEXIC] Keyword: %s\n", yytext );
    columns += yyleng;

    if(yytext[0] == 'i'){
        return IF;
    } else if(yytext[0] == 'e'){
        return ELSE;
    } else if(yytext[0] == 'f'){
        return FOR;
    } else if(yytext[0] == 'r'){
        strcpy(yylval.body.tokenBody, yytext);
        columns += yyleng;
        yylval.body.line = lines;
        yylval.body.column = columns;
        yylval.body.scope = top(&stackScope);
        return RETURN;
    } 
}

{OUT} {
    columns += yyleng;
    // printf("[LEXIC] Write: %s\n", yytext);
    if(yytext[yyleng - 1] == 'n'){
        return WRITELN;
    } else {
        return WRITE;
    }
}

{IN} {
    // printf("[LEXIC] Read: %s\n", yytext);
    columns += yyleng;
    return READ;
}

{BASIC_TYPE} {
    columns += yyleng;
    // printf("[LEXIC] Basic type: %s (%d)\n", yytext, yyleng);
    if(yytext[0] == 'i'){
        return INT;
    } else {
        return FLOAT;
    }
}

{STRING} {
    // printf("[LEXIC] String: %s\n", yytext);
    strcpy(yylval.body.tokenBody, yytext);
    yylval.body.line = lines;
    yylval.body.column = columns;
    yylval.body.scope = top(&stackScope);
    columns += yyleng;
    return STRING;
}

{SET}|{ELEM} {
    // printf("[LEXIC] Custom type: %s\n", yytext);
    columns += yyleng;
    if(yytext[0] == 's'){
        return SET;
    } else {
        return ELEM;
    }
}


{ID} {
    if(yyleng >= 50) {
        // printf("[LEXIC] WARNING: Variable size greater than 50, changed to size 50\n");
        yytext[55] = 0;
    }
    strcpy(yylval.body.tokenBody, yytext);
    yylval.body.line = lines;
    yylval.body.column = columns;
    yylval.body.scope = top(&stackScope);
    // printf("[LEXIC] Identifier: %s (%d)\n", yytext, yyleng);
    columns += yyleng;
    return ID;
}

"&&" {
    // printf("[LEXIC] Logic AND operator: %s\n", yytext);
    strcpy(yylval.body.tokenBody, yytext);
    columns += yyleng;
    yylval.body.line = lines;
    yylval.body.column = columns;
    yylval.body.scope = top(&stackScope);
    return AND_OP;
}

"||" {
    // printf("[LEXIC] Logic OR operator: %s\n", yytext);
    strcpy(yylval.body.tokenBody, yytext);
    yylval.body.line = lines;
    yylval.body.column = columns;
    yylval.body.scope = top(&stackScope);
    columns += yyleng;
    return OR_OP;
}

{RELATIONAL_OP} {
    // printf("[LEXIC] Relational operator: %s\n", yytext);
    strcpy(yylval.body.tokenBody, yytext);
    yylval.body.line = lines;
    yylval.body.column = columns;
    yylval.body.scope = top(&stackScope);
    columns += yyleng;
    return RELATIONAL_OP;
}

{MULTIPLICATIVE_OP} {
    // printf("[LEXIC] Multiplicative operator: %s\n", yytext);
    strcpy(yylval.body.tokenBody, yytext);
    yylval.body.line = lines;
    yylval.body.column = columns;
    yylval.body.scope = top(&stackScope);
    columns += yyleng;
    return MULTIPLICATIVE_OP;
}

{ADDITIVE_OP} {
    // printf("[LEXIC] Additive operator: %s\n", yytext);
    strcpy(yylval.body.tokenBody, yytext);
    yylval.body.line = lines;
    yylval.body.column = columns;
    columns += yyleng;
    yylval.body.scope = top(&stackScope);
    return ADDITIVE_OP;
}

"=" {
    // printf("[LEXIC] Enumerator operator: %s\n", yytext);
    columns += yyleng;
    return '=';
}

"!" {
    // printf("[LEXIC] Not operator: %s\n", yytext);
    columns += yyleng;
    return '!';
}

";" {
    // printf("[LEXIC] Command separator: %s\n", yytext);
    columns += yyleng;
    return ';';
}

"{"|"}" {
    columns += yyleng;
    // printf("[LEXIC] Block delimiter: %s\n", yytext);
    if(yytext[0] == '{'){
        push(&stackScope);
        return '{';
    } else {
        pop(&stackScope);
        return '}';
    }
}

"("|")" {
    // printf("[LEXIC] Expression delimiter: %s (%d)\n", yytext, yyleng);
    columns += yyleng;
    if(yytext[0] == '('){
        return '(';
    } else {
        return ')';
    }
}

"," {
    // printf("[LEXIC] Variable separator: %s\n", yytext);
    columns += yyleng;
    return ',';
}

[ \t]+ {
    columns += yyleng;
}

\n|\r {
    // printf("[LEXIC] ENDL\n");
    lines++;
    columns = 1;
}

. {
    errors++;
    printf("\n[LEXIC] ERROR line: %d columns: %d undentified char: %s \n\n", lines, columns, yytext );
}

%%