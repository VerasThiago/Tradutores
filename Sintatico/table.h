#ifndef TABLE
#define TABLE


typedef struct sy {
    int line;
    int colum;
    char* type;
    char* body;
    int scope;
    int paramsQnt;
} Symbol;

typedef struct tl {
    Symbol arr[10000];
    int size;
} TableList;


void push_back(TableList* tl, Symbol s);

void printTable(TableList* tl);

Symbol createSymbol(int line, int colum, char* type, char* body);

#endif