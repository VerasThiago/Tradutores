#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "error.h"
#include "tree.h"
#include "stack.h"
#include "table.h"
#include "semantic.h"

void checkArgsParms(char* args, char* params, int line, int column, char* body){
    if(strlen(args) < strlen(params)){
        throwError(newError(line, column, body, params, args, FEW_ARGS));
    } else if(strlen(args) > strlen(params)) {
        throwError(newError(line, column, body, params, args, MANY_ARGS));
    } else if(strcmp(args, params) != 0) {
        throwError(newError(line, column, body, params, args, WRONG_ARGS));
    }
}

void checkStructureBoolINSet(int left, int right, int expectedLeft, int expectedRight, int line, int column, char* body){
    if(left != expectedLeft || right != expectedRight){
        char expected[30];
        char got[30];
        sprintf(got, "%d%d", left, right);
        sprintf(expected, "%d%d", expectedLeft, expectedRight);
        throwError(newError(line, column, body, expected, got, WRONG_SET_ARGS));
    }
}

Symbol* checkVarExist(TableList *tableList, int line, int column, char* body, int scope){
    Symbol* s = getSymbolStack(tableList, body);
    if(s) return s;
    throwError(newError(line, column, body, "", "", UNDECLARED_VAR));
    return NULL;
}

Symbol* checkFuncExist(TableList *tableList, int line, int column, char* body, int scope){
    Symbol* var = getSymbolStack(tableList, body);
    if(var && strcmp(var->classType, "function") != 0){
        char redeclaredLine[10]; 
        char redeclaredColumn[10];
        sprintf(redeclaredLine, "%d", var->line);
        sprintf(redeclaredColumn, "%d", var->column);
        throwError(newError(line, column, body, redeclaredLine, redeclaredColumn, INVALID_FUNC_CALL));
        return var;
    }
    Symbol* s = getSymbolRecursive(tableList, body, 0, 1);
    if(!s){
        throwError(newError(line, column, body, "", "", UNDECLARED_FUNC));
    }
    return s;
}

int checkCast(TreeNode* L, TreeNode* R){
    return  (L->type == T_INT && R->type == T_FLOAT) || (L->type == T_FLOAT && R->type == T_INT);
}

int checkCastSymbol(Symbol* L, TreeNode* R){
    if(!L) return 0;
    return  (getTypeID(L->type) == T_INT && R->type == T_FLOAT) || (getTypeID(L->type) == T_FLOAT && R->type == T_INT);
}

void execCastSymbol(Symbol* L, TreeNode* R){
    if(getTypeID(L->type) == T_INT){
        R->type = T_INT;
        R->cast = FLOAT_TO_INT;
    } else {
        R->type = T_FLOAT;
        R->cast = INT_TO_FLOAT;
    }
}

void execCast(TreeNode* L, TreeNode* R){
    if(L->type == T_INT && R->type == T_FLOAT){
        L->type = T_FLOAT;
        L->cast = INT_TO_FLOAT;
    } else if(L->type == T_FLOAT && R->type == T_INT){
        R->type = T_FLOAT;
        R->cast = INT_TO_FLOAT;
    }
}

char *getCastString(int castCode){
    if(castCode == INT_TO_FLOAT) return strdup("(float)INT");
    if(castCode == FLOAT_TO_INT) return strdup("(int)FLOAT");
}

void checkMissType(int typeL, int typeR, int line, int column, char* body) {
    if(typeL != typeR){
        throwError(newError(line, column, body, getIDType(typeL), getIDType(typeR), MISS_TYPE));
    }
}

Symbol* checkDuplicatedVar(TableList *tableList, int line, int column, char* body, int scope){
    Symbol* s = getSymbol(tableList, body, scope);
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
    Symbol* s = getSymbol(tableList, body, scope);
    if(s){
        char redeclaredLine[10]; 
        char redeclaredColumn[10];
        sprintf(redeclaredLine, "%d", s->line);
        sprintf(redeclaredColumn, "%d", s->column);
        throwError(newError(line, column, body, redeclaredLine, redeclaredColumn, DUPLICATED_FUNC));
    }
    return s;
}