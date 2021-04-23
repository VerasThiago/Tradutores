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

void pushGarbageCollector(TreeNode* node, char* str);

void freeGarbageCollector();

TreeNode* createNode(char* rule);

void printTree(TreeNode* root, int ident,int *ok);

void freeTree(TreeNode* root);

void printToken(Symbol* s, int ident,int *ok);

void getTreeTypeList(TreeNode* root, char* ans);

int getTypeID(char* type);

char* getIDType(int ID);

char* getArgsList(char *args);

char* getArgsListSetIn(char *args);

int startsWith(char* a, char* b);

char* getCastExpression(TreeNode* L, TreeNode* R, char* operator);

char* getCastExpressionSymbol(Symbol* L, TreeNode* R, char* operator);

TreeNode* createIDNode(Symbol* s, int line, int column, char* body, int scope);

void checkAndExecForceCastArgs(TreeNode* root, char argsType[], int *idx);

void checkAndExecForceCast(TreeNode* L, int type);

enum TYPE_CODE {
    T_INT,
    T_SET,
    T_FLOAT,
    T_ELEM,
    T_EMPTY,
};

#endif