#ifndef _TAC
#define _TAC

#include "tac.h"

typedef struct TAC {
    char* func;
    char* arg1;
    char* arg2;
    char* dest;
    char* label;
} TAC;

TAC* createTAC(char* func, char* dest, char* arg1, char* arg2, char* label);
char* getRegisterFromId(int id);
char* getParamFromPos(int id);
char* getArgsCount(char *args);
char* getFreeRegister();
int getFreeLabelId();
char* getFreeLabel(char* name, int id);
char* getEndLabel(char* label);
char* getFuncFromOperator(char* operator);
void insertFile(TAC* codeLine);

#endif