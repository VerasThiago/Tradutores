#ifndef TABLE
#define TABLE


typedef struct Symbol {
    int line;
    int column;
    char* classType;
    char* type;
    char* body;
    int scope;
    char* paramsType; // 0 INT 1 FLOAT 2 SET 3 ELEM
} Symbol;

typedef struct TableList {
    Symbol* arr[10000];
    int size;
} TableList;


void push_back(TableList* tl, Symbol* s);

void freeTable(TableList* tl);

void printTable(TableList* tl);

Symbol* createSymbol(int line, int column ,char* classType, char* type, char* body, int scope);

Symbol* getSymbol(TableList* tl, char *body, int scope);

Symbol* getSymbolRecursive(TableList* tl, char *body, int scope, int func);

TableList tableList;

#endif