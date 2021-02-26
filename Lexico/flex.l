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

DIGIT                   [0-9]

ID                      [_a-zA-Z_][a-z0-9A-Z_]*

CONSTANT                EMPTY

KEYWORD                 if|else|for|return

ARITMETIC_OPERATOR      [+*/-]

LOGIC_OPERATOR          [!&|><%]

BASIC_TYPE              int|float

SET                     set

ELEM                    elem

SET_OPERATION           add|remove|in|is_set|exists|forall

IN                      read

OUT                     write|writeln

STRING                  \"[^\"]*\"|'[^']*'

COMMENT                "//"

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

{SET_OPERATION} {
    printf("Set operator: %s\n", yytext);
    columns += yyleng;
}

{KEYWORD} {
    printf("Keyword: %s\n", yytext );
    columns += yyleng;
}

{OUT} {
    printf("Write: %s\n", yytext);
    columns += yyleng;
}

{IN} {
    printf("Read: %s\n", yytext);
    columns += yyleng;
}

{BASIC_TYPE} {
    printf("Basic type: %s\n", yytext);
    columns += yyleng;
}

{STRING} {
    printf("String: %s\n", yytext);
    columns += yyleng;
}

{SET}|{ELEM} {
    printf("Custom type: %s\n", yytext);
    columns += yyleng;
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

{ARITMETIC_OPERATOR} {
    printf("Aritmetic operator: %s\n", yytext);
    columns += yyleng;
}

{LOGIC_OPERATOR}|">="|"<="|"=="|"&&"|"||" {
    printf("Logic operator: %s\n", yytext);
    columns += yyleng;
}

{LOGIC_OPERATOR}?"=" {
    printf("Assignment: %s\n", yytext);
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