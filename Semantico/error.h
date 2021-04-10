#ifndef ERROR
#define ERROR

typedef struct er {
    int line;
    int column;
    char *message;
    char *expected;
    char *got;
    int code;
} Error;

void throwError(Error e);

Error newError(int l, int c, char *m, char *ex, char *g, int code);

enum ERR_CODE {
    FEW_ARGS,
    MANY_ARGS,
    WRONG_ARGS,
    UNDECLARED_VAR,
    MISS_TYPE,
};

#endif