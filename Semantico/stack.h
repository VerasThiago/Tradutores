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

int errors;
int verbose;

char lastType[200];
char fileName[200];

#endif