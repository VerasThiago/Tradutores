#ifndef SEMANTIC
#define SEMANTIC

int checkCast(TreeNode*, TreeNode*);
int checkCastSymbol(Symbol*, TreeNode*);
int checkSingleCastSymbol(Symbol*, int);

void execCast(TreeNode*, TreeNode*);
void execSingleCast(TreeNode*, int );
void execSingleForceCast(TreeNode*, int);
void execForceCastSymbol(Symbol*, TreeNode*);

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

void checkAndExecForceCastArgs(TreeNode*, char[], int * );
void checkAndExecForceCast(TreeNode*, int);

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