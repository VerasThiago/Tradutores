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
    return node;
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

    printTree(root->nxt, ident, ok);
    
    printTree(root->children, ident + 2, ok);
}

void freeTree(TreeNode* root){
    if(!root) return;

    
    freeTree(root->nxt);
    freeTree(root->children);
    
    if(root->symbol){
        free(root->symbol->classType);
        free(root->symbol->type);
        free(root->symbol->body);
    }
    free(root->symbol);
    free(root->rule);
    free(root);

    
}
