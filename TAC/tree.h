#ifndef TREE
#define TREE

#include "table.h"
#include "tac.h"

typedef struct TreeNode {
    struct TreeNode* children;
    struct TreeNode* nxt;
    char* rule;
    Symbol* symbol;
    int type;
    int cast;
    struct TAC* codeLine;
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

TreeNode* createNode(char* rule);
TreeNode* createIDNode(Symbol* s, int line, int column, char* body, int scope);

void printToken(Symbol* s, int ident);
void printCodeLine(TAC* codeLine, int ident);
void printRule(char* s, int ident, int *ok);
void printTree(TreeNode* root, int ident, int *ok);

void freeTree(TreeNode* root);

void getTreeTypeList(TreeNode* root, char ans[]);


TreeNode* createTACNode(TAC *codeLine);
void generateTACCode(TreeNode* root);
void buildIfTAC(TreeNode* root, TreeNode* expression, TreeNode* statements);
void buildIfElseTAC(TreeNode* root, TreeNode* expression, TreeNode* ifStatements, TreeNode* elseStatements);
void buildForTAC(TreeNode* root, TreeNode* forExpression, TreeNode* statement);

#endif