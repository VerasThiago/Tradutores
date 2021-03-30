#ifndef STACK
#define STACK

typedef struct st {
    int st[10000];
    int size;
    int nxtScope;
} Stack;

void push(Stack* scope);
void pop(Stack* scope);
int top(Stack* scope);

Stack stackScope;

int lines, columns, errors;

char lastType[200];

#endif