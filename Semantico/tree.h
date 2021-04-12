#ifndef TREE
#define TREE

#include "table.h"

typedef struct TreeNode {
    struct TreeNode* children;
    struct TreeNode* nxt;
    char* rule;
    Symbol* symbol;
    int type;
    int cast;
} TreeNode;

typedef struct TreeNodeList {
    struct TreeNode* arr[1000];
    int size;
} TreeNodeList;

void push_back_node(TreeNodeList* tnl, TreeNode* node);

void freeNodeList(TreeNodeList* tnl);

TreeNode* createNode(char* rule);

void printTree(TreeNode* root, int ident,int *ok);

void freeTree(TreeNode* root);

void printToken(Symbol* s, int ident,int *ok);

void getTreeTypeList(TreeNode* root, char* ans);

int getTypeID(char* type);

char* getIDType(int ID);

char* getArgsList(char *args);

int startsWith(char* a, char* b);

char* getCastExpression(TreeNode* L, TreeNode* R, char* operator);

TreeNode* root;

TreeNodeList treeNodeList;

enum TYPE_CODE {
    T_INT,
    T_SET,
    T_FLOAT,
    T_ELEM,
    T_EMPTY,
};

#endif