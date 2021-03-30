#ifndef TABLE
#define TABLE


typedef struct Symbol {
    int line;
    int colum;
    char* classType;
    char* type;
    char* body;
    int scope;
    int paramsQnt;
} Symbol;

typedef struct TableList {
    Symbol* arr[10000];
    int size;
} TableList;


void push_back(TableList* tl, Symbol* s);

void printTable(TableList* tl);

Symbol* createSymbol(int line, int colum,char* classType, char* type, char* body);

void freeTable(TableList* tl);

TableList tableList;

#endif