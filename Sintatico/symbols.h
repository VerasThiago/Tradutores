#ifndef TABELA
#define TABELA

#include "structure.h"

int criar_simbolo(Token);
char* buscar_tipo(Nodo*);
void definir_tipo(int, char*);
void mostrar_tabela();
void liberar_tabela();
int busca_main();
Simbolo* buscar_simbolo(char*, int);
Simbolo* buscar_simbolo_escopo(char*, int);
Simbolo* buscar_simbolo_id(int);

void yyerror (char const *);

#endif