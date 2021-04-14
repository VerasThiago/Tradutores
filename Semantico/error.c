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
            printf("%s:%d:%d: error: too few arguments to function ‘%s’\n Expected: %d\n Got: %d\n\n",fileName, e.line, e.column, e.message, (int)strlen(e.expected), (int)strlen(e.got));
        break;

        case MANY_ARGS:
            printf("%s:%d:%d: error: too many arguments to function ‘%s’\n Expected: %d\n Got: %d\n\n",fileName, e.line, e.column, e.message, (int)strlen(e.expected), (int)strlen(e.got));
        break;

        case WRONG_ARGS:
            expected = getArgsList(e.expected);
            got = getArgsList(e.got);
            printf("%s:%d:%d: error: incompatible types for argument of ‘%s’\n Expected: %s(%s)\n Got: %s(%s)\n\n",fileName, e.line, e.column, e.message, e.message, expected, e.message, got);
        break;

        case WRONG_SET_ARGS:
            expected = getArgsListSetIn(e.expected);
            got = getArgsListSetIn(e.got);
            printf("%s:%d:%d: error: incompatible types for argument of ‘%s’\n Expected: %s\n Got: %s\n\n",fileName, e.line, e.column, e.message, expected, got);
        break;

        case MISS_TYPE:
            printf("%s:%d:%d: error: miss type expression\n Expected: %s %s %s\n Got: %s %s %s\n\n",fileName, e.line, e.column, e.expected, e.message, e.expected, e.expected, e.message, e.got);
        break;

        case MISS_TYPE_RETURN:
            printf("%s:%d:%d: error: miss type return of ‘%s’\n Expected: return (%s);\n Got: return (%s);\n\n",fileName, e.line, e.column, e.message, e.expected, e.got);
        break;

        case UNDECLARED_VAR:
            printf("%s:%d:%d: error: ‘%s’ undeclared\n\n",fileName, e.line, e.column, e.message);
        break;

        case UNDECLARED_FUNC:
            printf("%s:%d:%d: error: implicit declaration of function ‘%s’\n\n",fileName, e.line, e.column, e.message);
        break;

        case DUPLICATED_FUNC:
            printf("%s:%d:%d: error: redefinition of ‘%s’\n\n",fileName, e.line, e.column, e.message);
            printf("%s:%s:%s: note: previous definition of ‘%s’ was here\n\n",fileName, e.expected, e.got, e.message);
        break;
        
        case DUPLICATED_VAR:
            printf("%s:%d:%d: error: redeclaration of ‘%s’ with no linkage\n\n",fileName, e.line, e.column, e.message);
            printf("%s:%s:%s: note: previous definition of ‘%s’ was here\n\n",fileName, e.expected, e.got, e.message);
        break;

        case INVALID_FUNC_CALL:
            printf("%s:%d:%d: error: called object ‘%s’ is not a function or function pointer\n\n",fileName, e.line, e.column, e.message);
            printf("%s:%s:%s: note: declared here\n\n",fileName, e.expected, e.got);
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