#include "stdio.h"
#include "stdlib.h"
#include <string.h>
#include "error.h"
#include "tree.h"

void throwError(Error e){

    switch(e.code){
        case FEW_ARGS:
        printf("\n[SEMANTIC] [%d,%d] ERROR Few arguments on function %s\n expected: %d\n got: %d\n\n", e.line, e.column, e.message, (int)strlen(e.expected), (int)strlen(e.got));
        break;

        case MANY_ARGS:
        printf("\n[SEMANTIC] [%d,%d] ERROR Many arguments on function %s\n expected: %d\n got: %d\n\n", e.line, e.column, e.message, (int)strlen(e.expected), (int)strlen(e.got));
        break;

        case WRONG_ARGS:
        printf("\n[SEMANTIC] [%d,%d] ERROR Wrong arguments on function %s\n expected: %s(%s)\n got: %s(%s)\n\n", e.line, e.column, e.message, e.message, getArgsList(e.expected), e.message, getArgsList(e.got));
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