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

typedef struct GarbageCollector {
    struct TreeNode* nodeArr[1000];
    char* strArr[1000];
    int nodeSize;
    int strSize;
} GarbageCollector;


enum TYPE_CODE {
    T_INT,
    T_SET,
    T_FLOAT,
    T_ELEM,
    T_EMPTY,
};

TreeNode* createNode(char*);
TreeNode* createIDNode(Symbol*, int, int, char*, int);

void printTree(TreeNode*, int, int*);
void freeTree(TreeNode*);
void printToken(Symbol* s, int, int *);

void getTreeTypeList(TreeNode*, char*);

#endif