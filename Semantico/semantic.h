#ifndef SEMANTIC
#define SEMANTIC

void checkArgsParms(char* args, char* params, int line, int column, char* body);

Symbol* checkVarExist(TableList *tableList, int line, int column, char* body, int scope);

int checkCast(TreeNode* L, TreeNode* R);

int checkCastSymbol(Symbol* L, TreeNode* R);

void execCast(TreeNode* L, TreeNode* R);

void execCastSymbol(Symbol* L, TreeNode* R);

void checkStructureBoolINSet(int left, int right, int expectedLeft, int expectedRight, int line, int column, char* body);

Symbol* checkFuncExist(TableList *tableList, int line, int column, char* body, int scope);

Symbol* checkDuplicatedFunc(TableList *tableList, int line, int column, char* body, int scope);

Symbol* checkDuplicatedVar(TableList *tableList, int line, int column, char* body, int scope);

char *getCastString(int castCode);

void checkMissType(int typeL, int typeR, int line, int column, char* body);

enum CAST_CODE {
    INT_TO_FLOAT,
    FLOAT_TO_INT,
};

#endif