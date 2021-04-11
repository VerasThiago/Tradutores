#ifndef SEMANTIC
#define SEMANTIC

void checkArgsParms(char* args, char* params, int line, int column, char* body);

Symbol* checkVarExist(TableList *tableList, int line, int column, char* body, int scope);

Symbol* checkFuncExist(TableList *tableList, int line, int column, char* body, int scope);

Symbol* checkDuplicatedFunc(TableList *tableList, int line, int column, char* body, int scope);

Symbol* checkDuplicatedVar(TableList *tableList, int line, int column, char* body, int scope);

void checkMissType(int typeL, int typeR, int line, int column, char* body);

#endif