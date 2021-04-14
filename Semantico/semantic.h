#ifndef SEMANTIC
#define SEMANTIC

void checkArgsParms(char* args, char* params, int line, int column, char* body);

Symbol* checkVarExist(TableList *tableList, int line, int column, char* body, int scope);

int checkCast(TreeNode* L, TreeNode* R);

int checkCastSymbol(Symbol* L, TreeNode* R);

int checkSingleCastSymbol(Symbol* L, int expected);

void execCast(TreeNode* L, TreeNode* R);

void execForceCastSymbol(Symbol* L, TreeNode* R);

void execSingleForceCast(TreeNode* L, int castType);

int checkSingleCast(TreeNode* L, int expected);

void execSingleCast(TreeNode* L, int castType);

void checkStructureBoolINSet(int left, int right, int expectedLeft, int expectedRight, int line, int column, char* body);

Symbol* checkFuncExist(TableList *tableList, int line, int column, char* body, int scope);

Symbol* checkDuplicatedFunc(TableList *tableList, int line, int column, char* body, int scope);

Symbol* checkDuplicatedVar(TableList *tableList, int line, int column, char* body, int scope);

char *getCastString(int castCode);

void checkMissType(int typeL, int typeR, int line, int column, char* body);
void checkMissTypeReturn(int typeL, int typeR, int line, int column, char* body);

char *getExternalCastString(int castCode);

enum CAST_CODE {
    INT_TO_FLOAT,
    INT_TO_ELEM,
    FLOAT_TO_INT,
    FLOAT_TO_ELEM,
    ELEM_TO_INT,
    ELEM_TO_FLOAT,
    ELEM_TO_SET,
    SET_TO_ELEM,
};

#endif