%option noyywrap
%option noinput nounput

%{
    #define RED     "\x1b[31m"
    #define GREEN   "\x1b[32m"
    #define YELLOW  "\x1b[33m"
    #define BLUE    "\x1b[34m"
    #define MAGENTA "\x1b[35m"
    #define CYAN    "\x1b[36m"
    #define RESET   "\x1b[0m"
    #include<stdio.h>
    #include<string.h>
    #include<stdlib.h>
    
    int lines = 1, errors = 0, columns = 0;
%}

DIGIT                           [0-9]

ID                              [_a-zA-Z_][a-z0-9A-Z_]*

CONSTANT                        EMPTY

KEYWORD                         if|else|for|return

BASIC_TYPE                      int|float

SET                             set

ELEM                            elem

SET_OPERATION                   add|remove|exists

SET_OPERATION_1                 is_set

SET_OPERATION_2                 forall

SET_OPERATION_3                 is

ENUMERATOR_OP             =

LOGICAL_AND_OP            &&

LOGICAL_OR_OP             \|\|

RELATIONAL_OP             <|>|==|<=|>=

MULTIPLICATIVE_OP         [*/%]

ADDITIVE_OP               [+-]

IN                              read

OUT                             write|writeln

STRING                          \"[^\"]*\"|'[^']*'

COMMENT                         "//"

%%

{COMMENT}.* {
    printf("Comment on line %d\n", lines);
}

{CONSTANT}|{DIGIT}+"."{DIGIT}+|{DIGIT}+ {
    if(strchr(yytext, '.') != NULL){
        printf("Constant (Float): %s\n", yytext);
    } else if(yytext[0] == 'E'){
        printf("Constant (Empty): %s\n", yytext);
    } else {
        printf("Constant (Int): %s\n", yytext);
    }
    columns += yyleng;
}

{SET_OPERATION}|{SET_OPERATION_1}|{SET_OPERATION_2}|"in" {
    columns += yyleng;
    printf("Set operator: %s\n", yytext);
    if(yytext[0] == 'a' || yytext[0] == 'r' || yytext[0] == 'e'){
        // return T_SET_OPERATION;
    } else if ( yytext[0] == 'i' && yytext[1] == 's'){
        // return T_SET_OPERATION_1;
    } else if ( yytext[0] == 'f'){
        // return T_SET_OPERATION_2;
    } else {
        // reutrn T_SET_OPERATION_3;
    }
}

{KEYWORD} {
    printf("Keyword: %s\n", yytext );
    columns += yyleng;

    if(yytext[0] == 'i'){
        // return T_If;
    } else if(yytext[0] == 'e'){
        // return T_Else;
    } else if(yytext[0] == 'f'){
        // return T_For;
    } else if(yytext[0] == 'r'){
        // // return T_Return;
    } 
}

{OUT} {
    columns += yyleng;
    printf("Write: %s\n", yytext);
    if(yytext[yyleng - 1] == 'n'){
        // return T_Writeln;
    } else {
        // return T_Write;
    }
}

{IN} {
    printf("Read: %s\n", yytext);
    columns += yyleng;
    // return T_Read;
}

{BASIC_TYPE} {
    printf("Basic type: %s\n", yytext);
    columns += yyleng;
    // return T_Basic_Type;
}

{STRING} {
    printf("String: %s\n", yytext);
    columns += yyleng;
    // return T_String;
}

{SET}|{ELEM} {
    printf("Custom type: %s\n", yytext);
    columns += yyleng;
    if(yytext[0] == 's'){
        // return T_Set;
    } else {
        // return T_Elem;
    }
}

"++" {
    printf("Icrement Op, %s", yytext);
    columns += yyleng;
}

"--" {
    printf("Decrement Op, %s", yytext);
    columns += yyleng;
}

{ID} {
    if(yyleng >= 33) {
        printf("%sWARNING:%sThe idenfier length is too long, the idenfier was truncated to the first 33 characters\n" RESET, YELLOW, RESET);
        yytext[33] = 0;
    }
    printf("Identifier: %s\n", yytext);
    columns += yyleng;
}

{LOGICAL_AND_OP} {
    printf("Logic AND operator: %s\n", yytext);
    columns += yyleng;
}

{LOGICAL_OR_OP} {
    printf("Logic OR operator: %s\n", yytext);
    columns += yyleng;
}

{RELATIONAL_OP} {
    printf("Relational operator: %s\n", yytext);
    columns += yyleng;
}

{MULTIPLICATIVE_OP} {
    printf("Multiplicative operator: %s\n", yytext);
    columns += yyleng;
}

{ADDITIVE_OP} {
    printf("Additive operator: %s\n", yytext);
    columns += yyleng;
}

{ENUMERATOR_OP} {
    printf("Enumerator operator: %s\n", yytext);
    columns += yyleng;
}

";" {
    printf("Command separator: %s\n", yytext);
    columns += yyleng;
}

"{"|"}" {
    printf("Block delimiter: %s\n", yytext);
    columns += yyleng;
}

"("|")" {
    printf("Expression delimiter: %s\n", yytext);
    columns += yyleng;
}

"," {
    printf("Variable separator: %s\n", yytext);
    columns += yyleng;
}

[ \t]+

\n|\r {
    lines++;
    columns = 0;
}

. {
    errors++;
    printf("%sERROR%s line: %d columns: %d Undentified char: %s\n" RESET, RED, RESET, lines, columns, yytext );
}

%%

int main(int argc, char ** argv) {
    ++argv, --argc;
    if(argc > 0) {
        yyin = fopen(argv[0], "r");
    }
    else {
        yyin = stdin;
    }
    yylex();
    printf("\n");
    if(errors > 0){
        printf("%sProgram analysis failed!%s\n%sLexical analysis terminated with %d error(s)\n"RESET, RED, RESET, CYAN, errors);
    }
    else{
        printf("%sCorrect program.\n" RESET, GREEN);
    }
    fclose(yyin);
    yylex_destroy();
    return 0;
}