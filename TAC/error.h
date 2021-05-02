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

enum ERR_CODE {
    FEW_ARGS,
    MANY_ARGS,
    WRONG_ARGS,
    UNDECLARED_VAR,
    UNDECLARED_FUNC,
    DUPLICATED_VAR,
    DUPLICATED_FUNC,
    INVALID_FUNC_CALL,
    INVALID_SET_OPERATION,
    MISS_TYPE,
    MISS_TYPE_RETURN,
    WRONG_SET_ARGS,
    MISSING_MAIN,
};

void throwError(Error);
Error newError(int , int , char*, char*, char*, int );

#endif