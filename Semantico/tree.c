#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"
#include "semantic.h"

TreeNode* createNode(char* rule){
    TreeNode* node = (TreeNode*) malloc(sizeof(TreeNode));
    node->rule = strdup(rule);
    node->children = NULL;
    node->nxt = NULL;
    node->symbol = NULL;
    node->type = -1;
    node->cast = -1;
    pushGarbageCollector(node, NULL);
    return node;
}

TreeNode* createIDNode(Symbol* s, int line, int column, char* body, int scope){
    TreeNode* node = createNode("value");
    node->symbol = s ? createSymbol(line, column, "variable", s->type, body, scope) :
                       createSymbol(line, column, "variable", "??", body, scope);
    node->type = getTypeID(node->symbol->type);
    return node;
}

int getTypeID(char* type){
    if (strcmp(type, "INT") == 0) return T_INT;
    if(strcmp(type, "SET") == 0) return T_SET;
    if(strcmp(type, "FLOAT") == 0) return T_FLOAT;
    if (strcmp(type, "ELEM") == 0) return T_ELEM;
    if (strcmp(type, "EMPTY") == 0) return T_SET;
    return -1;
}

char* getCastExpression(TreeNode* L, TreeNode* R, char* operator){
    char fullExpression[30];

    char *left = L->cast != -1? getCastString(L->cast):getIDType(L->type);
    char *right = R->cast != -1? getCastString(R->cast):getIDType(R->type);

    sprintf(fullExpression, "%s %s %s", left, operator, right);
    pushGarbageCollector(NULL, left);
    pushGarbageCollector(NULL, right);

    return strdup(fullExpression);
}

char* getCastExpressionSymbol(Symbol* L, TreeNode* R, char* operator){
    char fullExpression[30];

    char *left = L? strdup(L->type):"??";
    char *right = R->cast != -1? getCastString(R->cast):getIDType(R->type);

    sprintf(fullExpression, "%s %s %s", left, operator, right);
    pushGarbageCollector(NULL, left);
    pushGarbageCollector(NULL, right);

    return strdup(fullExpression);
}

char* getIDType(int type){
    if (type == T_INT) return strdup("INT");
    else if(type == T_SET) return strdup("SET");
    else if(type == T_FLOAT) return strdup("FLOAT");
    else if (type == T_ELEM) return strdup("ELEM");
    else if (type == T_EMPTY) return strdup("SET");
    else return strdup("??");
}

char* getArgsList(char *args){
    char* argsList;
    char* curr;
    char* tmp;
    argsList = "";

    for(int i = 0; i < strlen(args); i++){
        curr = getIDType(args[i] - '0');
        
        if(i){
            tmp = (char *) malloc(3 + strlen(argsList)+ strlen(curr) );
            strcpy(tmp, argsList);
            strcat(tmp, ", ");
        } else {
            tmp = (char *) malloc(1 + strlen(argsList)+ strlen(curr) );
            strcpy(tmp, argsList);
        }

        strcat(tmp, curr);
        argsList = tmp;
    }
    return argsList;
}

char* getArgsListSetIn(char *args){
    char* argsList;
    char* curr;
    char* tmp;
    argsList = "";

    for(int i = 0; i < strlen(args); i++){
        curr = getIDType(args[i] - '0');
        
        if(i){
            tmp = (char *) malloc(3 + strlen(argsList)+ strlen(curr) );
            strcpy(tmp, argsList);
            strcat(tmp, " IN ");
        } else {
            tmp = (char *) malloc(1 + strlen(argsList)+ strlen(curr) );
            strcpy(tmp, argsList);
        }

        strcat(tmp, curr);
        argsList = tmp;
    }
    return argsList;
}

void printToken(Symbol* s, int ident, int *ok){
    printf(" ── [%d:%d] %s", s->line, s->column, s->classType);
    if(strcmp(s->classType, "variable") == 0){
        printf(" : %s %s", s->type, s->body);
    } else if(strcmp(s->classType, s->body) != 0){
        printf(" : %s", s->body);
    }
}

void printRule(char* s, int ident, int *ok){
    for(int i = 0; i < ident; i++) {
        if(ok[i]) printf("|");
        else printf(" ");
        printf(" ");
    }
    printf("├─ %s ", s);
}

void printTree(TreeNode* root, int ident, int *ok){
    if(!root) return;

    printRule(root->rule, ident, ok);
    ok[ident] = 1;

    if(root->symbol){
        printToken(root->symbol, ident + 1, ok);
    }

    printf("\n");

    printTree(root->children, ident + 2, ok);
    printTree(root->nxt, ident, ok);
    
}

void getTreeTypeList(TreeNode* root, char ans[]){
    if(!root) return;

    if(root->type != -1){
        char aux[] = "0";
        aux[0] += root->type;
        strcat(ans, aux);
    }
    
    if(!startsWith(root->rule, "expression")){
        getTreeTypeList(root->children, ans);
    }
    getTreeTypeList(root->nxt, ans);
}

void checkAndExecForceCastArgs(TreeNode* root, char argsType[], int *idx){
    if(!root) return;

    if(root->type != -1){
        if(checkSingleCast(root, argsType[*idx] - '0')) execSingleForceCast(root, argsType[*idx] - '0');
        (*idx)++;
        if(root->cast != -1){
            if(strcmp(root->symbol->type, "") == 0){
                char newCastStr[50];
                char* externalCast = getExternalCastString(root->cast);
                sprintf(newCastStr, "(%s)(%s)", externalCast, root->symbol->body);
                pushGarbageCollector(NULL, root->symbol->body);
                root->symbol->body = strdup(newCastStr);

                pushGarbageCollector(NULL, externalCast);
            } else {
                pushGarbageCollector(NULL, root->symbol->type);
                root->symbol->type = getCastString(root->cast);
            }
        }
    }
    
    if(!startsWith(root->rule, "expression")){
        checkAndExecForceCastArgs(root->children, argsType, idx);
    }
    checkAndExecForceCastArgs(root->nxt, argsType, idx);
}

void checkAndExecForceCast(TreeNode* L, int type){
    if(!L || L->type == -1) return;
    if(checkSingleCast(L, type)) execSingleForceCast(L, type);
    if(L->cast != -1){
        if(strcmp(L->symbol->type, "") == 0){
            char newCastStr[50];
            char* externalCast = getExternalCastString(L->cast);
            sprintf(newCastStr, "(%s)(%s)", externalCast, L->symbol->body);
            pushGarbageCollector(NULL, L->symbol->body);
            L->symbol->body = strdup(newCastStr);

            pushGarbageCollector(NULL, externalCast);
        } else {
            pushGarbageCollector(NULL, L->symbol->type);
            L->symbol->type = getCastString(L->cast);
        }
    }
}

int startsWith(char* a, char* b){
    if(strlen(a) < strlen(b)) return 0;
    for(int i = 0; i < strlen(b); i++) if(a[i] != b[i]) return 0;
    return 1;
}

void freeTree(TreeNode* root){
    if(!root) return;

    freeTree(root->children);
    freeTree(root->nxt);
    
    if(root->symbol){
        free(root->symbol->classType);
        free(root->symbol->type);
        free(root->symbol->body);
        free(root->symbol);
    }
    if(root->rule){
        free(root->rule);
    }
    free(root);

    
}

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
