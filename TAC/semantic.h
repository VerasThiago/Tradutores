#ifndef SEMANTIC
#define SEMANTIC

int checkCast(TreeNode*, TreeNode*);
int checkCastSymbol(Symbol*, TreeNode*);
int checkSingleCastSymbol(Symbol*, int);

void execCast(TreeNode* root, TreeNode* L, TreeNode* R);
void execSingleCast(TreeNode* root, TreeNode* L, int castType);
void execSingleForceCast(TreeNode* root, TreeNode* L, int castType);
void execForceCastSymbol(TreeNode* root, Symbol* L, TreeNode* R);

void createAndInsertCastNode(TreeNode* root, TreeNode* castNode, char* castFunc, int pos);
char* createAndInsertCastNodeUtil(TreeNode* root, char* castFunc);

int checkSingleCast(TreeNode*, int );
void checkStructureBoolINSet(int , int , int , int , int , int , char*);

Symbol* checkFuncExist(TableList*, int , int , char*, int );
Symbol* checkDuplicatedFunc(TableList*, int , int , char*, int );
Symbol* checkDuplicatedVar(TableList*, int , int , char*, int );

void checkMissType(int, int, int, int, char*);
void checkMissTypeReturn(int, int, int, int, char*);

void checkArgsParmsUtil(char* args, char* params, int line, int column, char* body);
void checkArgsParms(TreeNode* root, Symbol* functionSymbol, TreeNode* argumentsList);
Symbol* checkVarExist(TableList*, int, int, char*, int);

void checkMainFunc();

char *getCastString(int);
char *getExternalCastString(int);
char *getCastFunc(int castCode);

void checkAndExecForceCastArgs(TreeNode* root, TreeNode* argumentsList, char* argsType, int *idx);
void checkAndExecForceCast(TreeNode* root, TreeNode* expression, int type);

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