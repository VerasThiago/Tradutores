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
    int id;
    int paramPos;
} Symbol;

typedef struct TableList {
    Symbol* arr[1000];
    int size;
} TableList;


void freeTable(TableList*);
void printTable(TableList*);
void pushTable(TableList*, Symbol*);
int getFreeStrId();

Symbol* getSymbolStack(TableList*, char*);
Symbol* getSymbol(TableList*, char*, int);
Symbol* getClosestFunctionFromLine(TableList*, int);
Symbol* getSymbolRecursive(TableList*, char *, int, int);
Symbol* createSymbol(int, int, char*, char*, char*, int, int);

#endif