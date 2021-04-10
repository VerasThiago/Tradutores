#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"

TreeNode* createNode(char* rule){
    TreeNode* node = (TreeNode*) malloc(sizeof(TreeNode));
    node->rule = strdup(rule);
    node->children = NULL;
    node->nxt = NULL;
    node->symbol = NULL;
    node->type = -1;
    return node;
}

int getTypeID(char* type){
    if (strcmp(type, "INT") == 0) {
        return 0;
    } else if(strcmp(type, "SET") == 0) {
        return 1;
    } else if(strcmp(type, "FLOAT") == 0) {
        return 2;
    } else if (strcmp(type, "ELEM") == 0) {
        return 3;
    } else {
        return -1;
    }
}

void printToken(Symbol* s, int ident, int *ok){
    printf(" ── [%d:%d] %s", s->line, s->colum, s->classType);
    if(strcmp(s->classType, s->body))
        printf(" : %s", s->body);
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

void getParamsType(TreeNode* root, char ans []){
    if(!root) return;

    if(root->type != -1){
        char aux[4][7] = {"0", "1", "2", "3"};
        strcat(ans, aux[root->type]);
    }
    getParamsType(root->children, ans);
    getParamsType(root->nxt, ans);
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

void freeNodeList(TreeNodeList* tnl) {
    for(int i = 0; i <= tnl->size; i++){
        if(!tnl->arr[i]) continue;
        TreeNode* root = tnl->arr[i];
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
}

void push_back_node(TreeNodeList* tnl, TreeNode* node){
    tnl->arr[++tnl->size] = node;
}
