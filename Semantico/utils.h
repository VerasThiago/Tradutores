#ifndef UTILS
#define UTILS

#include "tree.h"

int getTypeID(char*);
char* getIDType(int);

int startsWith(char*, char*);

char* getArgsList(char*);
char* getArgsListSetIn(char*);

char* getCastExpression(TreeNode*, TreeNode*, char*);
char* getCastExpressionSymbol(Symbol*, TreeNode*, char*);

void freeGarbageCollector();
void pushGarbageCollector(TreeNode*, char*);

#endif