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
    Symbol* s = getSymbol(tableList, body, 0);
    if(!s){
        throwError(newError(line, column, body, "", "", UNDECLARED_FUNC));
    }
    return s;
}

int checkCast(TreeNode* L, TreeNode* R){
    return  (L->type == T_INT && R->type == T_FLOAT)    ||
            (L->type == T_FLOAT && R->type == T_INT)    ||
            (L->type == T_ELEM && R->type == T_INT)     ||
            (L->type == T_INT && R->type == T_ELEM)     ||
            (L->type == T_ELEM && R->type == T_FLOAT)   ||
            (L->type == T_ELEM && R->type == T_SET)     ||
            (L->type == T_SET && R->type == T_ELEM)     ||
            (L->type == T_FLOAT && R->type == T_ELEM);
}

int checkSingleCast(TreeNode* L, int expected){
    return  (L->type == T_INT && expected == T_FLOAT)    ||
            (L->type == T_FLOAT && expected == T_INT)    ||
            (L->type == T_ELEM && expected == T_INT)     ||
            (L->type == T_INT && expected == T_ELEM)     ||
            (L->type == T_ELEM && expected == T_FLOAT)   ||
            (L->type == T_ELEM && expected == T_SET)     ||
            (L->type == T_SET && expected == T_ELEM)     ||
            (L->type == T_FLOAT && expected == T_ELEM);
}

int checkSingleCastSymbol(Symbol* L, int expected){
    if(!L) return 0;
     return (getTypeID(L->type) == T_INT && expected == T_FLOAT)    ||
            (getTypeID(L->type) == T_FLOAT && expected == T_INT)    ||
            (getTypeID(L->type) == T_ELEM && expected == T_INT)     ||
            (getTypeID(L->type) == T_INT && expected == T_ELEM)     ||
            (getTypeID(L->type) == T_ELEM && expected == T_FLOAT)   ||
            (getTypeID(L->type) == T_ELEM && expected == T_SET)     ||
            (getTypeID(L->type) == T_SET && expected == T_ELEM)     ||
            (getTypeID(L->type) == T_FLOAT && expected == T_ELEM);
}

int checkCastSymbol(Symbol* L, TreeNode* R){
    if(!L) return 0;
    return  (getTypeID(L->type) == T_INT && R->type == T_FLOAT)    ||
            (getTypeID(L->type) == T_FLOAT && R->type == T_INT)    ||
            (getTypeID(L->type) == T_ELEM && R->type == T_INT)     ||
            (getTypeID(L->type) == T_INT && R->type == T_ELEM)     ||
            (getTypeID(L->type) == T_ELEM && R->type == T_FLOAT)   ||
            (getTypeID(L->type) == T_ELEM && R->type == T_SET)     ||
            (getTypeID(L->type) == T_SET && R->type == T_ELEM)     ||
            (getTypeID(L->type) == T_FLOAT && R->type == T_ELEM);
}

void execForceCastSymbol(Symbol* L, TreeNode* R){
    if(getTypeID(L->type) == T_FLOAT && R->type == T_INT){
        R->type = T_FLOAT;
        R->cast = INT_TO_FLOAT;
    } else if(getTypeID(L->type) == T_FLOAT && R->type == T_ELEM){
        R->type = T_FLOAT;
        R->cast = ELEM_TO_FLOAT;
    } else if(getTypeID(L->type) == T_INT && R->type == T_FLOAT){
        R->type = T_INT;
        R->cast = FLOAT_TO_INT;
    } else if(getTypeID(L->type) == T_INT && R->type == T_ELEM){
        R->type = T_INT;
        R->cast = ELEM_TO_INT;
    } else if (getTypeID(L->type) == T_ELEM && R->type == T_INT){
        R->type = T_ELEM;
        R->cast = INT_TO_ELEM;
    } else if (getTypeID(L->type) == T_ELEM && R->type == T_FLOAT){
        R->type = T_ELEM;
        R->cast = FLOAT_TO_ELEM;
    } else if (getTypeID(L->type) == T_ELEM && R->type == T_SET){
        R->type = T_ELEM;
        R->cast = SET_TO_ELEM;
    }
}

void execCast(TreeNode* L, TreeNode* R){
    if (L->type == T_INT && R->type == T_FLOAT){
        L->type = T_FLOAT;
        L->cast = INT_TO_FLOAT;
    } else if(L->type == T_FLOAT && R->type == T_INT){
        R->type = T_FLOAT;
        R->cast = INT_TO_FLOAT;
    } else if (L->type == T_ELEM && R->type == T_INT){
        R->type = T_ELEM;
        R->cast = INT_TO_ELEM;
    } else if (L->type == T_INT && R->type == T_ELEM){
        L->type = T_ELEM;
        L->cast = INT_TO_ELEM;
    } else if (L->type == T_ELEM && R->type == T_FLOAT){
        R->type = T_ELEM;
        R->cast = FLOAT_TO_ELEM;
    } else if (L->type == T_FLOAT && R->type == T_ELEM){
        L->type = T_ELEM;
        L->cast = FLOAT_TO_ELEM;
    } else if (L->type == T_SET && R->type == T_ELEM){
        L->type = T_ELEM;
        L->cast = SET_TO_ELEM;
    } else if (L->type == T_ELEM && R->type == T_SET){
        R->type = T_ELEM;
        R->cast = SET_TO_ELEM;
    }
}

void execSingleCast(TreeNode* L, int castType){
    if (L->type == T_INT && castType == T_FLOAT){
        L->type = T_FLOAT;
        L->cast = INT_TO_FLOAT;
    } else if (L->type == T_INT && castType == T_ELEM){
        L->type = T_ELEM;
        L->cast = INT_TO_ELEM;
    } else if (L->type == T_FLOAT && castType == T_ELEM){
        L->type = T_ELEM;
        L->cast = FLOAT_TO_ELEM;
    } else if (L->type == T_SET && castType == T_ELEM){
        L->type = T_ELEM;
        L->cast = SET_TO_ELEM;
    }
}

void execSingleForceCast(TreeNode* L, int castType){
    if(L->type == T_FLOAT && castType == T_INT){
        L->type = T_INT;
        L->cast = FLOAT_TO_INT;
    } else if(L->type == T_FLOAT && castType == T_ELEM){
        L->type = T_ELEM;
        L->cast = FLOAT_TO_ELEM;
    } else if(L->type == T_INT && castType == T_FLOAT){
        L->type = T_FLOAT;
        L->cast = INT_TO_FLOAT;
    } else if(L->type == T_INT && castType == T_ELEM){
        L->type = T_ELEM;
        L->cast = INT_TO_ELEM;
    } else if (L->type == T_ELEM && castType == T_INT){
        L->type = T_INT;
        L->cast = ELEM_TO_INT;
    } else if (L->type == T_ELEM && castType == T_FLOAT){
        L->type = T_FLOAT;
        L->cast = ELEM_TO_FLOAT;
    } else if (L->type == T_ELEM && castType == T_SET){
        L->type = T_SET;
        L->cast = ELEM_TO_SET;
    } else if(L->type == T_SET && castType == T_ELEM){
        L->type = T_ELEM;
        L->cast = SET_TO_ELEM;
    }
}

char *getCastString(int castCode){
    if(castCode == ELEM_TO_INT) return strdup("(int)ELEM");
    if(castCode == FLOAT_TO_INT) return strdup("(int)FLOAT");
    if(castCode == INT_TO_FLOAT) return strdup("(float)INT");
    if(castCode == ELEM_TO_FLOAT) return strdup("(float)ELEM");
    if(castCode == INT_TO_ELEM) return strdup("(elem)INT");
    if(castCode == FLOAT_TO_ELEM) return strdup("(elem)FLOAT");
    if(castCode == SET_TO_ELEM) return strdup("(elem)SET");
    if(castCode == ELEM_TO_SET) return strdup("(set)ELEM");
    return strdup("??");
}

char *getExternalCastString(int castCode){
    if(castCode == ELEM_TO_INT) return strdup("int");
    if(castCode == FLOAT_TO_INT) return strdup("int");
    if(castCode == INT_TO_FLOAT) return strdup("float");
    if(castCode == ELEM_TO_FLOAT) return strdup("float");
    if(castCode == INT_TO_ELEM) return strdup("elem");
    if(castCode == FLOAT_TO_ELEM) return strdup("elem");
    if(castCode == SET_TO_ELEM) return strdup("elem");
    if(castCode == ELEM_TO_SET) return strdup("set");
    return strdup("??");
}

void checkMissType(int typeL, int typeR, int line, int column, char* body) {
    if(typeL != typeR){
        char* strTypeL = getIDType(typeL);
        char* strTypeR = getIDType(typeR);
        pushGarbageCollector(NULL, strTypeL);
        pushGarbageCollector(NULL, strTypeR);
        throwError(newError(line, column, body, strTypeL, strTypeR, MISS_TYPE));
    }
}

void checkMissTypeReturn(int typeL, int typeR, int line, int column, char* body) {
    if(typeL != typeR){
        char* strTypeL = getIDType(typeL);
        char* strTypeR = getIDType(typeR);
        pushGarbageCollector(NULL, strTypeL);
        pushGarbageCollector(NULL, strTypeR);
        throwError(newError(line, column, body, strTypeL, strTypeR, MISS_TYPE_RETURN));
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