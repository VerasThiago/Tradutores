#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tac.h"
#include "utils.h"
#include "tree.h"

int freeLabel = 0;
int freeIdx = 0;
extern TreeNode* root;

TAC* createTAC(char* func, char* dest, char* arg1, char* arg2, char* label){
    TAC* codeLine = (TAC*) malloc(sizeof(TAC));
    codeLine->func = func ? strdup(func):NULL;
    codeLine->arg1 = arg1 ? strdup(arg1):NULL;
    codeLine->arg2 = arg2 ? strdup(arg2):NULL;
    codeLine->dest = dest ? strdup(dest):NULL;
    codeLine->label = label ? strdup(label):NULL;
    return codeLine;
}

char* getFreeRegister(){
    char buffer[5];
    sprintf(buffer, "$%d", freeIdx++);
    char* ret = strdup(buffer);
    pushGarbageCollector(NULL, ret);
    return ret;
}

int getFreeLabelId(){
    return freeLabel++;
}

char* getFreeLabel(char* name, int id){
    char buffer[50];
    if(name) {
        if(strcmp(name, "main") == 0 || id == -2) return name;
        if(id != -1) sprintf(buffer, "__%d_%s", id, name);
        else sprintf(buffer, "__%d_%s", freeLabel++, name);
    } else {
        if(id != -1) sprintf(buffer, "__%d", id);
        else sprintf(buffer, "__%d", freeLabel++);
    }
    char* ret = strdup(buffer);
    pushGarbageCollector(NULL, ret);
    return ret;
}

char* getLabelAddress(char* name){
    char buffer[50];
    sprintf(buffer, "&%s", name);
    char* ret = strdup(buffer);
    pushGarbageCollector(NULL, ret);
    return ret;
}

char* getEndLabel(char* label){
    char buffer[50];
    sprintf(buffer, "%s_end", label);
    char* ret = strdup(buffer);
    pushGarbageCollector(NULL, ret);
    return ret;
}

char* buildVarTacString(char* body, int scope){
    char buffer[50];
    sprintf(buffer, "%s_%d", body, scope);
    char* ret = strdup(buffer);
    pushGarbageCollector(NULL, ret);
    return ret;
}

char* getArgsCount(char *args){
    char buffer[5];
    sprintf(buffer, "%d", (int)strlen(args));
    char* ret = strdup(buffer);
    pushGarbageCollector(NULL, ret);
    return ret;
}

char* getParamFromPos(int id){
    char buffer[5];
    sprintf(buffer, "#%d", id);
    char* ret = strdup(buffer);
    pushGarbageCollector(NULL, ret);
    return ret;
}

char* getFuncFromOperator(char* operator, int *swap){
    char* func;
    if(strcmp(operator, "==") == 0) func = strdup("seq");
    else if(strcmp(operator, "!=") == 0) func = strdup("seq");
    else if(strcmp(operator, "<") == 0) func = strdup("slt");
    else if(strcmp(operator, "<=") == 0) func = strdup("sleq");
    else if(strcmp(operator, ">=") == 0) func = strdup("sleq"), *swap = 1;
    else if(strcmp(operator, ">") == 0) func = strdup("slt"),   *swap = 1;
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
    else if(strcmp(operator, "readi") == 0) func = strdup("scani");
    else if(strcmp(operator, "readf") == 0) func = strdup("scanf");
    else func = strdup("??");
    pushGarbageCollector(NULL, func);
    return func;
}

void insertFile(TAC* codeLine){
    FILE *out = fopen(cExtensionToTACExtension(), "a");
    if(codeLine->label){
        fprintf(out, "%s:\n", codeLine->label); 
    } else if(
        strcmp(codeLine->func, "seq") == 0       ||
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
        strcmp(codeLine->func, "mov") == 0      ||
        strcmp(codeLine->func, "call") == 0     ||
        strcmp(codeLine->func, "inttofl") == 0  ||
        strcmp(codeLine->func, "fltoint") == 0  ||
        strcmp(codeLine->func, "brz") == 0 
    ) {
        fprintf(out, "\t%s %s, %s\n", codeLine->func, codeLine->dest, codeLine->arg1); 
    } else if(
        strcmp(codeLine->func, "print") == 0    ||
        strcmp(codeLine->func, "println") == 0  ||
        strcmp(codeLine->func, "jump") == 0     ||
        strcmp(codeLine->func, "return") == 0   ||
        strcmp(codeLine->func, "scani") == 0    ||
        strcmp(codeLine->func, "scanf") == 0    ||
        strcmp(codeLine->func, "pop") == 0      ||
        strcmp(codeLine->func, "minus") == 0    ||
        strcmp(codeLine->func, "not") == 0      ||
        strcmp(codeLine->func, "param") == 0    
        
    ){
        fprintf(out, "\t%s %s\n", codeLine->func, codeLine->arg1); 
    }
    fclose(out);
}