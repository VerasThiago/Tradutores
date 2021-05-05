#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "error.h"
#include "tree.h"
#include "stack.h"
#include "table.h"
#include "semantic.h"
#include "utils.h"

extern TableList tableList;

enum POS{
    DEST,
    ARG1,
    ARG2
};

void checkArgsParmsUtil(char* args, char* params, int line, int column, char* body){
    if(strlen(args) < strlen(params)){
        throwError(newError(line, column, body, params, args, FEW_ARGS));
    } else if(strlen(args) > strlen(params)) {
        throwError(newError(line, column, body, params, args, MANY_ARGS));
    } else if(strcmp(args, params) != 0) {
        throwError(newError(line, column, body, params, args, WRONG_ARGS));
    }
}

void checkArgsParms(TreeNode* root, Symbol* functionSymbol, TreeNode* argumentsList){
    if(!functionSymbol || strcmp(functionSymbol->classType, "function") != 0) return;

    root->codeLine = createTAC(NULL, getFreeRegister(), NULL, NULL, NULL);
    root->type = getTypeID(root->symbol->type);

    int x = 0;
    char *funcParams;
    char argsAsString[100] = "";

    if(functionSymbol->paramsType) {
        funcParams = functionSymbol->paramsType;
    } else {
        funcParams = strdup("");
        pushGarbageCollector(NULL, funcParams);
    }

    checkAndExecForceCastArgs(root, argumentsList, funcParams, &x);
    getTreeArgs(argumentsList, argsAsString);
    checkArgsParmsUtil(argsAsString, funcParams, functionSymbol->line, functionSymbol->column, functionSymbol->body);

    if(functionSymbol){
        TreeNode* paramNode = createTACNode(createTAC("call", functionSymbol->body, getArgsCount(argsAsString), NULL, NULL));
        TreeNode* popNode = createTACNode(createTAC("pop", NULL, root->codeLine->dest, NULL, NULL));
        paramNode->nxt = root->children;
        root->children = paramNode;
        
        popNode->nxt = root->nxt;
        root->nxt = popNode;
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

char* createAndInsertCastNodeUtil(TreeNode* root, char* castFunc){
    TreeNode* intToFloatCastNode = createTACNode(createTAC(castFunc, getFreeRegister(), root->codeLine->dest, NULL, NULL));
    intToFloatCastNode->nxt = root->nxt;
    root->nxt = intToFloatCastNode;
    return strdup(intToFloatCastNode->codeLine->dest);
}

void createAndInsertCastNode(TreeNode* root, TreeNode* castNode, char* castFunc, int pos){
    if(!root) return;
    if(pos == ARG1) free(root->codeLine->arg1), root->codeLine->arg1 = createAndInsertCastNodeUtil(castNode, castFunc);
    else if(pos == ARG2) free(root->codeLine->arg2), root->codeLine->arg2 = createAndInsertCastNodeUtil(castNode, castFunc);
    else if(pos == DEST) free(root->codeLine->dest), root->codeLine->dest = createAndInsertCastNodeUtil(castNode, castFunc);
}

void execForceCastSymbol(TreeNode* root, Symbol* L, TreeNode* R){
    if(getTypeID(L->type) == T_FLOAT && R->type == T_INT){
        R->type = T_FLOAT;
        R->cast = INT_TO_FLOAT;
        createAndInsertCastNode(root, R, getCastFunc(INT_TO_FLOAT), ARG1);
    } else if(getTypeID(L->type) == T_FLOAT && R->type == T_ELEM){
        R->type = T_FLOAT;
        R->cast = ELEM_TO_FLOAT;
    } else if(getTypeID(L->type) == T_INT && R->type == T_FLOAT){
        R->type = T_INT;
        R->cast = FLOAT_TO_INT;
        createAndInsertCastNode(root, R, getCastFunc(FLOAT_TO_INT), ARG1);
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

void checkAndExecForceCastArgs(TreeNode* root, TreeNode* argumentsList, char* argsType, int *idx){
    if(!root || !argsType || !argumentsList) return;

    if(argumentsList->type != -1){
        if(checkSingleCast(argumentsList, argsType[*idx] - '0')) execSingleForceCast(root, argumentsList, argsType[*idx] - '0');
        (*idx)++;
        if(argumentsList->cast != -1){
            if(strcmp(argumentsList->symbol->type, "") == 0){
                char newCastStr[50];
                char* externalCast = getExternalCastString(argumentsList->cast);
                sprintf(newCastStr, "(%s)(%s)", externalCast, argumentsList->symbol->body);
                pushGarbageCollector(NULL, argumentsList->symbol->body);
                argumentsList->symbol->body = strdup(newCastStr);
            } else {
                pushGarbageCollector(NULL, argumentsList->symbol->type);
                argumentsList->symbol->type = getCastString(argumentsList->cast);
            }
        }
    }
    
    if(!startsWith(argumentsList->rule, "expression") && strcmp(argumentsList->rule, "function_call") != 0){
        checkAndExecForceCastArgs(root, argumentsList->children, argsType, idx);
    }
    checkAndExecForceCastArgs(root, argumentsList->nxt, argsType, idx);
}

void checkAndExecForceCast(TreeNode* root, TreeNode* expression, int type){
    if(!expression || expression->type == -1) return;
    if(checkSingleCast(expression, type)) execSingleForceCast(root, expression, type);
    if(expression->cast != -1){
        if(strcmp(expression->symbol->type, "") == 0){
            char newCastStr[50];
            char* externalCast = getExternalCastString(expression->cast);
            sprintf(newCastStr, "(%s)(%s)", externalCast, expression->symbol->body);
            pushGarbageCollector(NULL, expression->symbol->body);
            expression->symbol->body = strdup(newCastStr);
        } else {
            pushGarbageCollector(NULL, expression->symbol->type);
            expression->symbol->type = getCastString(expression->cast);
        }
    }
}

void execCast(TreeNode* root, TreeNode* L, TreeNode* R){
    if (L->type == T_INT && R->type == T_FLOAT){
        L->type = T_FLOAT;
        L->cast = INT_TO_FLOAT;
        createAndInsertCastNode(root, L, getCastFunc(INT_TO_FLOAT), ARG1);
    } else if(L->type == T_FLOAT && R->type == T_INT){
        R->type = T_FLOAT;
        R->cast = INT_TO_FLOAT;
        createAndInsertCastNode(root, R, getCastFunc(INT_TO_FLOAT), ARG2);
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

void execSingleCast(TreeNode* root, TreeNode* L, int castType){
    if (L->type == T_INT && castType == T_FLOAT){
        L->type = T_FLOAT;
        L->cast = INT_TO_FLOAT;
        createAndInsertCastNode(root, L, getCastFunc(INT_TO_FLOAT), ARG1);
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

void execSingleForceCast(TreeNode* root, TreeNode* L, int castType){
    if(L->type == T_FLOAT && castType == T_INT){
        L->type = T_INT;
        L->cast = FLOAT_TO_INT;
        createAndInsertCastNode(root, L, getCastFunc(FLOAT_TO_INT), DEST);
    } else if(L->type == T_FLOAT && castType == T_ELEM){
        L->type = T_ELEM;
        L->cast = FLOAT_TO_ELEM;
    } else if(L->type == T_INT && castType == T_FLOAT){
        L->type = T_FLOAT;
        L->cast = INT_TO_FLOAT;
        createAndInsertCastNode(root, L, getCastFunc(INT_TO_FLOAT), DEST);
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

char *getCastFunc(int castCode){
    char *castFunc;
    if(castCode == ELEM_TO_INT) castFunc = strdup("?");
    else if(castCode == FLOAT_TO_INT) castFunc = strdup("fltoint");
    else if(castCode == INT_TO_FLOAT) castFunc = strdup("inttofl");
    else if(castCode == ELEM_TO_FLOAT) castFunc = strdup("?");
    else if(castCode == INT_TO_ELEM) castFunc = strdup("?");
    else if(castCode == FLOAT_TO_ELEM) castFunc = strdup("?");
    else if(castCode == SET_TO_ELEM) castFunc = strdup("?");
    else if(castCode == ELEM_TO_SET) castFunc = strdup("?");
    else castFunc = strdup("??");
    pushGarbageCollector(NULL, castFunc);
    return castFunc;
}


char *getCastString(int castCode){
    if(castCode == ELEM_TO_INT) return strdup("(int)ELEM");
    else if(castCode == FLOAT_TO_INT) return strdup("(int)FLOAT");
    else if(castCode == INT_TO_FLOAT) return strdup("(float)INT");
    else if(castCode == ELEM_TO_FLOAT) return strdup("(float)ELEM");
    else if(castCode == INT_TO_ELEM) return strdup("(elem)INT");
    else if(castCode == FLOAT_TO_ELEM) return strdup("(elem)FLOAT");
    else if(castCode == SET_TO_ELEM) return strdup("(elem)SET");
    else if(castCode == ELEM_TO_SET) return strdup("(set)ELEM");
    return strdup("??");
}

char *getExternalCastString(int castCode){
    char *castStr;
    if(castCode == ELEM_TO_INT) castStr = strdup("int");
    else if(castCode == FLOAT_TO_INT) castStr = strdup("int");
    else if(castCode == INT_TO_FLOAT) castStr = strdup("float");
    else if(castCode == ELEM_TO_FLOAT) castStr = strdup("float");
    else if(castCode == INT_TO_ELEM) castStr = strdup("elem");
    else if(castCode == FLOAT_TO_ELEM) castStr = strdup("elem");
    else if(castCode == SET_TO_ELEM) castStr = strdup("elem");
    else if(castCode == ELEM_TO_SET) castStr = strdup("set");
    else castStr = strdup("??");
    pushGarbageCollector(NULL, castStr);
    return castStr;
}

void checkMissType(int typeL, int typeR, int line, int column, char* body) {
    if(typeL != typeR){
        char* strTypeL = getIDType(typeL);
        char* strTypeR = getIDType(typeR);
        pushGarbageCollector(NULL, strTypeL);
        pushGarbageCollector(NULL, strTypeR);
        throwError(newError(line, column, body, strTypeL, strTypeR, MISS_TYPE));
    }
    else if(typeL == getTypeID("SET") && strcmp(body, "=") != 0) {
        throwError(newError(line, column, body, "SET", "SET", INVALID_SET_OPERATION));
    }
}

void checkMainFunc() {
    Symbol* s = getSymbol(&tableList, "main", 0);
    if(!s){
        throwError(newError(-1, -1, "", "", "", MISSING_MAIN));
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