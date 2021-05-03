#ifndef _TAC
#define _TAC

#include "tac.h"

typedef struct TAC {
    char* func;
    char* arg1;
    char* arg2;
    char* dest;
} TAC;

TAC* createTAC(char* func, char* dest, char* arg1, char* arg2);
char* getRegisterFromId(int id);
char* getFreeRegister();
char* getFuncFromOperator(char* operator);
void insertFile(TAC* codeLine);

#endif