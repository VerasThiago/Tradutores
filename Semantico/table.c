#include "stdio.h"
#include "stdlib.h"
#include "table.h"
#include<string.h>

void push_back(TableList* tl, Symbol* val){
    tl->arr[++tl->size] = val;
}

void printTable(TableList* tl){
    printf(" -----------------------------------------------------------------------------------------------------------\n");
    printf("| %-15s | %-15s | %-15s | %-15s | %-15s | %-15s |\n", "LINE", "COLUMN", "CLASS", "TYPE", "SCOPE", "BODY");
    printf(" -----------------------------------------------------------------------------------------------------------\n");
    if(tl->size == -1){
        printf("|                                                                                                           |\n");
        printf(" -----------------------------------------------------------------------------------------------------------\n");

    } else {
        for(int i = 0; i <= tl->size; i++){
            printf("| %-15d | %-15d | %-15s | %-15s | %-15d | %-15s |\n", tl->arr[i]->line, tl->arr[i]->colum, tl->arr[i]->classType, tl->arr[i]->type, tl->arr[i]->scope, tl->arr[i]->body);
        }
        printf(" -----------------------------------------------------------------------------------------------------------\n");
    }
}

Symbol* createSymbol(int line, int colum,char* classType, char* type, char* body, int scope){
    Symbol* ret = (Symbol*) malloc(sizeof(Symbol));
    ret->scope = scope;
    ret->line = line;
    ret->colum = colum;
    ret->classType = strdup(classType);
    ret->type = strdup(type);
    ret->body = strdup(body);
    ret->paramsType = NULL;
    return ret;
}

Symbol* getFuncSymbol(TableList* tl, char *body, int scope){
    for(int i = 0; i <= tl->size; i++){
        if(strcmp(tl->arr[i]->body, body) == 0 && scope == tl->arr[i]->scope) return tl->arr[i];
    }
    return NULL;
}

void freeTable(TableList* tl){
    for(int i = 0; i <= tl->size; i++){
        free(tl->arr[i]->classType);
        free(tl->arr[i]->type);
        free(tl->arr[i]->body);
        free(tl->arr[i]);
    }
}
