#include "stdio.h"
#include "stdlib.h"
#include "stack.h"

void push(Stack* scope){
    scope->st[++scope->size] = ++scope->nxtScope;
}

void pop(Stack* scope){
    --scope->size;
}

int top(Stack* scope){
    return scope->st[scope->size];
}