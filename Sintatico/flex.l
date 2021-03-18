%option noyywrap

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

    extern char* lastType;

    extern int lines;
    extern int errors;
    extern int columns;

%}

%option noinput nounput

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

AND_OP                          &&

OR_OP                           \|\|

RELATIONAL_OP                   <|>|==|<=|>=

MULTIPLICATIVE_OP               [*/%]

ADDITIVE_OP                     [+-]

IN                              read

OUT                             write|writeln

STRING                          \"[^\"]*\"|'[^']*'

COMMENT                         "//"

%%

{COMMENT}.* {
    // printf("[LEXICO] Comment on line %d\n", lines);
}

{CONSTANT}|{DIGIT}+"."{DIGIT}+|{DIGIT}+ {
    columns += yyleng;
    yylval.body = strdup(yytext);
    if(strchr(yytext, '.') != NULL){
        // printf("[LEXICO] Constant (Float): %s\n", yytext);
         return FLOAT_VALUE;
    } else if(yytext[0] == 'E'){
        // printf("[LEXICO] Constant (Empty): %s\n", yytext);
        return EMPTY;
    } else {
        // printf("[LEXICO] Constant (Int): %s\n", yytext);
        return INT_VALUE;
    }
}

{SET_ADD}|{SET_REMOVE}|{SET_EXISTS}|{SET_IS_SET}|{SET_FOR_ALL}|{SET_IN} {
    // printf("[LEXICO] Set operator: %s\n", yytext);
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
    // printf("[LEXICO] Keyword: %s\n", yytext );
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
    // printf("[LEXICO] Write: %s\n", yytext);
    if(yytext[yyleng - 1] == 'n'){
        return WRITELN;
    } else {
        return WRITE;
    }
}

{IN} {
    // printf("[LEXICO] Read: %s\n", yytext);
    columns += yyleng;
    return READ;
}

{BASIC_TYPE} {
    columns += yyleng;
    // printf("[LEXICO] Basic type: %s\n", yytext);
    if(yytext[0] == 'i'){
        return INT;
    } else {
        return FLOAT;
    }
}

{STRING} {
    // printf("[LEXICO] String: %s\n", yytext);
    columns += yyleng;
    yylval.body = strdup(yytext);
    return STRING;
}

{SET}|{ELEM} {
    // printf("[LEXICO] Custom type: %s\n", yytext);
    columns += yyleng;
    if(yytext[0] == 's'){
        return SET;
    } else {
        return ELEM;
    }
}


{ID} {
    if(yyleng >= 33) {
        // printf("[LEXICO] WARNING:The idenfier length is too long, the idenfier was truncated to the first 33 characters\n");
        yytext[33] = 0;
    }
    // printf("[LEXICO] Identifier: %s\n", yytext);
    columns += yyleng;
    yylval.body = strdup(yytext);
    return ID;
}

{AND_OP} {
    // printf("[LEXICO] Logic AND operator: %s\n", yytext);
    columns += yyleng;
    return AND_OP;
}

{OR_OP} {
    // printf("[LEXICO] Logic OR operator: %s\n", yytext);
    columns += yyleng;
    return OR_OP;
}

{RELATIONAL_OP} {
    // printf("[LEXICO] Relational operator: %s\n", yytext);
    columns += yyleng;
    yylval.body = strdup(yytext);
    yylval.body = strdup(yytext);
    return RELATIONAL_OP;
}

{MULTIPLICATIVE_OP} {
    // printf("[LEXICO] Multiplicative operator: %s\n", yytext);
    columns += yyleng;
    yylval.body = strdup(yytext);
    return MULTIPLICATIVE_OP;
}

{ADDITIVE_OP} {
    // printf("[LEXICO] Additive operator: %s\n", yytext);
    columns += yyleng;
    yylval.body = strdup(yytext);
    return ADDITIVE_OP;
}

"=" {
    // printf("[LEXICO] Enumerator operator: %s\n", yytext);
    columns += yyleng;
    return '=';
}

";" {
    // printf("[LEXICO] Command separator: %s\n", yytext);
    columns += yyleng;
    return ';';
}

"{"|"}" {
    columns += yyleng;
    // printf("[LEXICO] Block delimiter: %s\n", yytext);
    if(yytext[0] == '{'){
        push(&stackScope);  
        return '{';
    } else {
        pop(&stackScope);
        return '}';
    }
}

"("|")" {
    // printf("[LEXICO] Expression delimiter: %s\n", yytext);
    columns += yyleng;
    if(yytext[0] == '('){
        return '(';
    } else {
        return ')';
    }
}

"," {
    // printf("[LEXICO] Variable separator: %s\n", yytext);
    columns += yyleng;
    return ',';
}

[ \t]+

\n|\r {
    lines++;
    columns = 0;
}

. {
    errors++;
    // printf("[LEXICO] ERROR line: %d columns: %d Undentified char: %s \n", lines, columns, yytext );
}

%%