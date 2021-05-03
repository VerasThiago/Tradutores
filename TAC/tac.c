#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tac.h"
#include "utils.h"
#include "tree.h"

int freeIdx = 1023;
extern TreeNode* root;

TAC* createTAC(char* func, char* dest, char* arg1, char* arg2){
    TAC* codeLine = (TAC*) malloc(sizeof(TAC));
    codeLine->func = func ? strdup(func):NULL;
    codeLine->arg1 = arg1 ? strdup(arg1):NULL;
    codeLine->arg2 = arg2 ? strdup(arg2):NULL;
    codeLine->dest = dest ? strdup(dest):NULL;
    return codeLine;
}

char* getFreeRegister(){
    char buffer[5];
    sprintf(buffer, "$%d", freeIdx--);
    char* ret = strdup(buffer);
    pushGarbageCollector(NULL, ret);
    return ret;
}

char* getRegisterFromId(int id){
    char buffer[5];
    sprintf(buffer, "$%d", id);
    char* ret = strdup(buffer);
    pushGarbageCollector(NULL, ret);
    return ret;
}

char* getFuncFromOperator(char* operator){
    char* func;
    if(strcmp(operator, "==") == 0) func = strdup("seq");
    else if(strcmp(operator, "<") == 0) func = strdup("slt");
    else if(strcmp(operator, "<=") == 0) func = strdup("sleq");
    else if(strcmp(operator, "+") == 0) func = strdup("add");
    else if(strcmp(operator, "-") == 0) func = strdup("sub");
    else if(strcmp(operator, "*") == 0) func = strdup("mul");
    else if(strcmp(operator, "/") == 0) func = strdup("div");
    else if(strcmp(operator, "&&") == 0) func = strdup("and");
    else if(strcmp(operator, "||") == 0) func = strdup("or");
    else if(strcmp(operator, "-") == 0) func = strdup("minus");
    else if(strcmp(operator, "!") == 0) func = strdup("not");
    else if(strcmp(operator, "=") == 0) func = strdup("mov");
    else if(strcmp(operator, "write") == 0) func = strdup("print");
    else if(strcmp(operator, "writeln") == 0) func = strdup("println");
    else if(strcmp(operator, "read") == 0) func = strdup("scani");
    else func = strdup("??");
    pushGarbageCollector(NULL, func);
    return func;
}

void insertFile(TAC* codeLine){
    FILE *out = fopen(cExtensionToTACExtension(), "a");
    if(strcmp(codeLine->func, "seq") == 0       ||
        strcmp(codeLine->func, "slt") == 0      ||
        strcmp(codeLine->func, "sleq") == 0     ||
        strcmp(codeLine->func, "add") == 0      ||
        strcmp(codeLine->func, "sub") == 0      ||
        strcmp(codeLine->func, "mul") == 0      ||
        strcmp(codeLine->func, "div") == 0      ||
        strcmp(codeLine->func, "and") == 0      ||
        strcmp(codeLine->func, "or") == 0
    ) {
        fprintf(out, "\t%s %s, %s, %s\n", codeLine->func, codeLine->dest, codeLine->arg1, codeLine->arg2); 
    } else if(
        strcmp(codeLine->func, "minus") == 0    ||
        strcmp(codeLine->func, "not") == 0      ||
        strcmp(codeLine->func, "mov") == 0
    ) {
        fprintf(out, "\t%s %s, %s\n", codeLine->func, codeLine->dest, codeLine->arg1); 
    } else if(
        strcmp(codeLine->func, "print") == 0    ||
        strcmp(codeLine->func, "println") == 0  ||
        strcmp(codeLine->func, "scani") == 0
    ){
        fprintf(out, "\t%s %s\n", codeLine->func, codeLine->arg1); 
    }
    fclose(out);
}