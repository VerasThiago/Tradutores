#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"

TreeNode* createNode(char* type){
    TreeNode* node = (TreeNode*) malloc(sizeof(TreeNode));
    node->type = strdup(type);
    return node;
}

void printToken(Symbol* s, int ident, int *ok){
    printf("|");
    for(int i = 0; i < ident; i++) {
        if(ok[i]) printf("|");
        else printf(".");
        printf(" ");
    }
    printf("[%d:%d] %s - %s \n", s->line, s->colum, s->type, s->body);
}

void printRule(char* s, int ident, int *ok){
    printf("|");
    for(int i = 0; i < ident; i++) {
        if(ok[i]) printf("|");
        else printf(".");
        printf(" ");
    }
    printf("├─ %s\n", s);
}

void printTree(TreeNode* root, int ident, int *ok){
    if(!root || !root->type) return;

    printRule(root->type, ident, ok);

    if(root->symbol){
        printToken(root->symbol, ident + 1, ok);
    }
    printTree(root->nxt, ident, ok);
    ok[ident] = 1;
    printTree(root->children, ident + 1, ok);
}

