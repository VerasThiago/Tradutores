#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "tree.h"
#include "semantic.h"
#include "error.h"

int errors;
int verbose;
char lastType[200];
char fileName[200];
extern GarbageCollector garbageCollector;

/*** Garbage Collector ****/

void freeGarbageCollector() {
    for(int i = 0; i <= garbageCollector.nodeSize; i++){
        if(!garbageCollector.nodeArr[i]) continue;
        TreeNode* root = garbageCollector.nodeArr[i];
        if(root->symbol){
            free(root->symbol->classType);
            free(root->symbol->type);
            free(root->symbol->body);
            free(root->symbol->paramsType);
            free(root->symbol);
        }
        if(root->rule){
            free(root->rule);
        }
        free(root);
    }

    for(int i = 0; i <= garbageCollector.strSize; i++){
        if(garbageCollector.strArr[i]) free(garbageCollector.strArr[i]);
    }
}

void pushGarbageCollector(TreeNode* node, char* str){
    if(node) garbageCollector.nodeArr[++garbageCollector.nodeSize] = node;
    if(str) garbageCollector.strArr[++garbageCollector.strSize] = str;
}

/*** Types convertion ***/

int getTypeID(char* type){
    if (strcmp(type, "INT") == 0) return T_INT;
    if(strcmp(type, "SET") == 0) return T_SET;
    if(strcmp(type, "FLOAT") == 0) return T_FLOAT;
    if (strcmp(type, "ELEM") == 0) return T_ELEM;
    if (strcmp(type, "EMPTY") == 0) return T_SET;
    return -1;
}

char* getIDType(int type){
    if (type == T_INT) return strdup("INT");
    else if(type == T_SET) return strdup("SET");
    else if(type == T_FLOAT) return strdup("FLOAT");
    else if (type == T_ELEM) return strdup("ELEM");
    else if (type == T_EMPTY) return strdup("SET");
    else return strdup("??");
}

/*** Generic Utils ***/

int startsWith(char* a, char* b){
    if(strlen(a) < strlen(b)) return 0;
    for(int i = 0; i < strlen(b); i++) if(a[i] != b[i]) return 0;
    return 1;
}


/*** Args number list to name list ***/

char* getArgsList(char *args){
    char argsList[50] = "";
    char* curr;

    for(int i = 0; i < strlen(args); i++){
        curr = getIDType(args[i] - '0');
        pushGarbageCollector(NULL, curr); 
        if(i) strcat(argsList, ", ");
        strcat(argsList, curr);
    }

    char* ret = strdup(argsList);
    pushGarbageCollector(NULL, ret);
    return ret;
}

char* getArgsListSetIn(char *args){
    if(strlen(args)!= 2) {
        throwError(newError(0, 0, NULL, NULL, NULL, -1));
        return NULL;
    }
    char fullExpression[50];

    char *left = getIDType(args[0] - '0');
    char *right = getIDType(args[0] - '1');

    sprintf(fullExpression, "%s %s %s", left, "IN", right);
    pushGarbageCollector(NULL, left);
    pushGarbageCollector(NULL, right);

    char *ret = strdup(fullExpression);
    pushGarbageCollector(NULL, ret);
    return ret;
}

/*** Cast expression ***/

char* getCastExpression(TreeNode* L, TreeNode* R, char* operator){
    char fullExpression[30];

    char *left = L->cast != -1 ? getCastString(L->cast):getIDType(L->type);
    char *right = R->cast != -1 ? getCastString(R->cast):getIDType(R->type);

    sprintf(fullExpression, "%s %s %s", left, operator, right);
    pushGarbageCollector(NULL, left);
    pushGarbageCollector(NULL, right);

    return strdup(fullExpression);
}

char* getCastExpressionSymbol(Symbol* L, TreeNode* R, char* operator){
    char fullExpression[30];

    char *left = L ? strdup(L->type):"??";
    char *right = R->cast != -1 ? getCastString(R->cast):getIDType(R->type);

    sprintf(fullExpression, "%s %s %s", left, operator, right);
    pushGarbageCollector(NULL, left);
    pushGarbageCollector(NULL, right);

    return strdup(fullExpression);
}