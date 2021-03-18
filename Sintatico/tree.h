#ifndef TREE
#define TREE

#include "table.h"

typedef struct TreeNode {
    struct TreeNode* children;
    struct TreeNode* nxt;
    char* rule;
    Symbol* symbol;
} TreeNode;


TreeNode* createNode(char* rule);

void printTree(TreeNode* root, int ident,int *ok);

void freeTree(TreeNode* root);

void printToken(Symbol* s, int ident,int *ok);

TreeNode* root;

#endif