%option noyywrap

%{

    #include<stdio.h>
    #include<string.h>
    #include<stdlib.h>
    #include "syntatic.tab.h"

    int lines = 1, errors = 0, columns = 0;
%}

%option noinput nounput

DIGIT                           [0-9]

ID                              [_a-zA-Z_][a-z0-9A-Z_]*

CONSTANT                        EMPTY

KEYWORD                         if|else|for|return

BASIC_TYPE                      int|float

SET                             set

ELEM                            elem

SET_BASIC                       add|remove|exists

SET_IS_SET                      is_set

SET_FOR_ALL                     forall

SET_IN                          in

ENUMERATOR_OP                   =

LOGICAL_AND_OP                  &&

LOGICAL_OR_OP                   \|\|

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
         return T_Float;
    } else if(yytext[0] == 'E'){
        // printf("[LEXICO] Constant (Empty): %s\n", yytext);
        return T_Empty;
    } else {
        // printf("[LEXICO] Constant (Int): %s\n", yytext);
        return T_Integer;
    }
}

{SET_BASIC}|{SET_IS_SET}|{SET_FOR_ALL}|{SET_IN} {
    // printf("[LEXICO] Set operator: %s\n", yytext);
    columns += yyleng;
    if(yytext[0] == 'a' || yytext[0] == 'r' || yytext[0] == 'e'){
        yylval.body = strdup(yytext);
        return T_SetBasic;
    } else if ( yytext[0] == 'i' && yytext[1] == 's'){
        return T_SetIsSet;
    } else if ( yytext[0] == 'f'){
        return T_SetForAll;
    } else {
        return T_SetIn;
    }
}

{KEYWORD} {
    // printf("[LEXICO] Keyword: %s\n", yytext );
    columns += yyleng;

    if(yytext[0] == 'i'){
        return T_If;
    } else if(yytext[0] == 'e'){
        return T_Else;
    } else if(yytext[0] == 'f'){
        return T_For;
    } else if(yytext[0] == 'r'){
        return T_Return;
    } 
}

{OUT} {
    columns += yyleng;
    // printf("[LEXICO] Write: %s\n", yytext);
    if(yytext[yyleng - 1] == 'n'){
        return T_Writeln;
    } else {
        return T_Write;
    }
}

{IN} {
    // printf("[LEXICO] Read: %s\n", yytext);
    columns += yyleng;
    return T_Read;
}

{BASIC_TYPE} {
    columns += yyleng;
    // printf("[LEXICO] Basic type: %s\n", yytext);
    if(yytext[0] == 'i'){
        return T_Type_Int;
    } else {
        return T_Type_Float;
    }
}

{STRING} {
    // printf("[LEXICO] String: %s\n", yytext);
    columns += yyleng;
    yylval.body = strdup(yytext);
    return T_String;
}

{SET}|{ELEM} {
    // printf("[LEXICO] Custom type: %s\n", yytext);
    columns += yyleng;
    if(yytext[0] == 's'){
        return T_Set;
    } else {
        return T_Elem;
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
    return T_Id;
}

{LOGICAL_AND_OP} {
    // printf("[LEXICO] Logic AND operator: %s\n", yytext);
    columns += yyleng;
    return LOGICAL_AND_OP;
}

{LOGICAL_OR_OP} {
    // printf("[LEXICO] Logic OR operator: %s\n", yytext);
    columns += yyleng;
    return LOGICAL_OR_OP;
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

{ENUMERATOR_OP} {
    // printf("[LEXICO] Enumerator operator: %s\n", yytext);
    columns += yyleng;
    return ENUMERATOR_OP;
}

";" {
    // printf("[LEXICO] Command separator: %s\n", yytext);
    columns += yyleng;
    return T_Semicolon;
}

"{"|"}" {
    // printf("[LEXICO] Block delimiter: %s\n", yytext);
    if(yytext[0] == '{'){
        return T_LeftBrace;
    } else {
        return T_RightBrace;
    }
    columns += yyleng;
}

"("|")" {
    // printf("[LEXICO] Expression delimiter: %s\n", yytext);
    columns += yyleng;
    if(yytext[0] == '('){
        return T_LeftParentheses;
    } else {
        return T_RightParentheses;
    }
}

"," {
    // printf("[LEXICO] Variable separator: %s\n", yytext);
    columns += yyleng;
    return T_Comma;
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