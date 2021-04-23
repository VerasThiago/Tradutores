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
    Symbol* arr[1000];
    int size;
} TableList;


void freeTable(TableList* tl);
void printTable(TableList* tl);
void push_back(TableList* tl, Symbol* s);

Symbol* getSymbolStack(TableList *tl, char* body);
Symbol* getSymbol(TableList* tl, char *body, int scope);
Symbol* getClosestFunctionFromLine(TableList* tl, int line);
Symbol* getSymbolRecursive(TableList* tl, char *body, int scope, int func);
Symbol* createSymbol(int line, int column ,char* classType, char* type, char* body, int scope);

#endif