#ifndef STACK
#define STACK

typedef struct st {
    int st[10000];
    int size;
    int nxtScope;
} Stack;

void push(Stack*);
void pop(Stack*);
int top(Stack*);

#endif