#include "stdio.h"
#include "stdlib.h"
#include "table.h"
#include<string.h>

void push_back(TableList* tl, Symbol* val){
    tl->arr[++tl->size] = val;
}

void printTable(TableList* tl){
    if(tl->size == -1){
        printf("TABLE DE SIMBOLOS VAIZA\n");
    } else {
        printf("--------------------------------------------------------------------------------------------------------------------\n");
        printf("| %-20s | %-20s | %-20s | %-20s | %-20s |\n", "LINE", "COLUMN", "CLASS", "TYPE", "BODY");
        printf("--------------------------------------------------------------------------------------------------------------------\n");
        for(int i = 0; i <= tl->size; i++){
            printf("| %-20d | %-20d | %-20s | %-20s | %-20s |\n", tl->arr[i]->line, tl->arr[i]->colum, tl->arr[i]->class, tl->arr[i]->type, tl->arr[i]->body);
        }
        printf("--------------------------------------------------------------------------------------------------------------------\n");
    }
}

Symbol* createSymbol(int line, int colum,char* class, char* type, char* body){
    Symbol* ret = (Symbol*) malloc(sizeof(Symbol));
    ret->line = line;
    ret->colum = colum;
    ret->class = strdup(class);
    ret->type = strdup(type);
    ret->body = strdup(body);
    return ret;
}

