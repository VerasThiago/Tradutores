#ifndef TREE
#define TREE

#include "table.h"

typedef struct TreeNode {
    struct TreeNode* children;
    struct TreeNode* nxt;
    char* type;
    Symbol* symbol;
} TreeNode;


TreeNode* createNode(char* type);

void printTree(TreeNode* root, int ident,int *ok);

void printToken(Symbol* s, int ident,int *ok);

TreeNode* root;

#endif