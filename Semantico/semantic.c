#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "error.h"
#include "tree.h"
#include "stack.h"
#include "table.h"

#define atoa(x) #x

void checkArgsParms(char* args, char* params, int line, int column, char* body){
    if(strlen(args) < strlen(params)){
        throwError(newError(line, column, body, params, args, FEW_ARGS));
    } else if(strlen(args) > strlen(params)) {
        throwError(newError(line, column, body, params, args, MANY_ARGS));
    } else if(strcmp(args, params) != 0) {
        throwError(newError(line, column, body, params, args, WRONG_ARGS));
    }
}

Symbol* checkVarExist(TableList *tableList, int line, int column, char* body, int scope){
    Symbol* s = getSymbolRecursive(tableList, body, scope, 0);
    if(!s){
        throwError(newError(line, column, body, "", "", UNDECLARED_VAR));
    }
    return s;
}

Symbol* checkFuncExist(TableList *tableList, int line, int column, char* body, int scope){
    Symbol* s = getSymbolRecursive(tableList, body, scope, 1);
    if(!s){
        Symbol* var = getSymbolRecursive(tableList, body, scope, 0);
        if(!var){
            throwError(newError(line, column, body, "", "", UNDECLARED_FUNC));
        } else {
            char redeclaredLine[10]; 
            char redeclaredColumn[10];
            sprintf(redeclaredLine, "%d", var->line);
            sprintf(redeclaredColumn, "%d", var->column);
            throwError(newError(line, column, body, redeclaredLine, redeclaredColumn, INVALID_FUNC_CALL));
        }
    }
    return s;
}

void checkMissType(int typeL, int typeR, int line, int column, char* body) {
    if(typeL != -2 && typeR != -2 && typeL != typeR){
        throwError(newError(line, column, body, getIDType(typeL), getIDType(typeR), MISS_TYPE));
    }
}

Symbol* checkDuplicatedVar(TableList *tableList, int line, int column, char* body, int scope){
    Symbol* s = getSymbol(tableList, body, scope);
    if(!s) s = getSymbol(tableList, body, scope - 1);
    if(s){
        char redeclaredLine[10]; 
        char redeclaredColumn[10];
        sprintf(redeclaredLine, "%d", s->line);
        sprintf(redeclaredColumn, "%d", s->column);
        throwError(newError(line, column, body, redeclaredLine, redeclaredColumn, DUPLICATED_VAR));
    }
    return s;
}

Symbol* checkDuplicatedFunc(TableList *tableList, int line, int column, char* body, int scope){
    Symbol* s = getSymbolRecursive(tableList, body, scope, 1);
    if(s){
        char redeclaredLine[10]; 
        char redeclaredColumn[10];
        sprintf(redeclaredLine, "%d", s->line);
        sprintf(redeclaredColumn, "%d", s->column);
        throwError(newError(line, column, body, redeclaredLine, redeclaredColumn, DUPLICATED_FUNC));
    }
    return s;
}

