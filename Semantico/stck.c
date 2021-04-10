#include <stdio.h>
#include <stdlib.h>

typedef struct st {
    int st[10000];
    int size;
    int nxtScope;
} Stack;

void push(Stack* scope){
    scope->st[++scope->size] = ++scope->nxtScope;
}

void pop(Stack* scope){
    --scope->size;
}

int top(Stack* scope){
    return scope->st[scope->size];
}

int main(){

    Stack s;
    s.size = s.nxtScope = -1;
    push(&s);
    printf("%d\n", top(&s));
    push(&s);
    printf("%d\n", top(&s));
    push(&s);
    printf("%d\n", top(&s));
    push(&s);
    printf("%d\n", top(&s));
    

}