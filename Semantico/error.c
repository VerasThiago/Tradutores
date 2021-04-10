#include "stdio.h"
#include "stdlib.h"
#include <string.h>
#include "error.h"
#include "tree.h"
#include "stack.h"

void throwError(Error e){
    char* expected;
    char* got;
    // errors++;
    switch(e.code){
        case FEW_ARGS:
        printf("\n[SEMANTIC] [%d,%d] ERROR Few arguments on function %s\n Expected: %d\n Got: %d\n\n", e.line, e.column, e.message, (int)strlen(e.expected), (int)strlen(e.got));
        break;

        case MANY_ARGS:
        printf("\n[SEMANTIC] [%d,%d] ERROR Many arguments on function %s\n Expected: %d\n Got: %d\n\n", e.line, e.column, e.message, (int)strlen(e.expected), (int)strlen(e.got));
        break;

        case WRONG_ARGS:
            expected = getArgsList(e.expected);
            got = getArgsList(e.got);
            printf("\n[SEMANTIC] [%d,%d] ERROR Wrong arguments on function %s\n Expected: %s(%s)\n Got: %s(%s)\n\n", e.line, e.column, e.message, e.message, expected, e.message, got);
        break;

        case UNDECLARED_VAR:
            printf("\n[SEMANTIC] [%d,%d] ERROR Undeclared variable %s\n\n", e.line, e.column, e.message);
        break;

        case MISS_TYPE:
            printf("\n[SEMANTIC] [%d,%d] ERROR Miss type expression\n Expected: %s %s %s\n Got: %s %s %s\n\n", e.line, e.column, e.expected, e.message, e.expected, e.expected, e.message, e.got);
        break;

        default:
        printf("Unhandled ERROR\n");
        break;
    }

    
}

Error newError(int l, int c, char *m, char *ex, char *g, int code){
    Error e;
    e.line = l;
    e.column = c;
    e.message = strdup(m);
    e.expected = strdup(ex);
    e.got = strdup(g);
    e.code = code;
    return e;
}