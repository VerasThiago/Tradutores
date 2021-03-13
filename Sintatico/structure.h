#ifndef ESTRUTURAS
#define ESTRUTURAS

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

typedef struct Simbolo Simbolo;
typedef struct ListaSimbolo ListaSimbolo;
typedef struct Token Token;
typedef struct ListaNodo ListaNodo;
typedef struct Nodo Nodo;
typedef struct Pilha Pilha;
typedef struct PilhaElemento PilhaElemento;

char* buscar_token(char*);
Pilha* pilha_push(Pilha*, int);
Pilha* pilha_pop(Pilha*);
Pilha* pilha_libera(Pilha*);
char* alocar_memoria(char*);

struct Token {
	int linha, coluna, escopo;
	char *lexema;
};

struct ListaNodo {
	Nodo *val;
	ListaNodo *proximo;
};

struct Nodo {
	ListaNodo *filhos;
	int temporario;
	int label;
	char* tipo;
	int id;
};

struct Simbolo {
	char token[20];
	char lexema[34];
	int id, linha, coluna, escopo, temporario;
	char *tipo;
	int funcao;
	int vetorLimite;
	Pilha *parametros;
	Pilha *valores;
	Simbolo *proximo;
};

struct ListaSimbolo {
	Simbolo *primeiro;
};

struct Pilha {
	PilhaElemento *elemento;
	int tamanho;
};

struct PilhaElemento {
	int val;
	PilhaElemento *proximo;
};

#endif