#ifndef TREE
#define TREE

#include "table.h"

typedef struct TreeNode {
    struct TreeNode* children;
    struct TreeNode* nxt;
    char* rule;
    Symbol* symbol;
} TreeNode;

typedef struct TreeNodeList {
    struct TreeNode* arr[10000];
    int size;
} TreeNodeList;

void push_back_node(TreeNodeList* tnl, TreeNode* node);

void freeNodeList(TreeNodeList* tnl);

TreeNode* createNode(char* rule);

void printTree(TreeNode* root, int ident,int *ok);

void freeTree(TreeNode* root);

void printToken(Symbol* s, int ident,int *ok);

TreeNode* root;

TreeNodeList treeNodeList;

#endif