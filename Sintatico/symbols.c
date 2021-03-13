#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "symbols.h"
#include "structure.h"

ListaSimbolo *tabelaSimbolo;
int id = 0;

int criar_simbolo(Token t) {
	Simbolo *simbolo = (Simbolo*) malloc(sizeof(Simbolo));
	strcpy(simbolo->token, buscar_token(t.lexema));
	strcpy(simbolo->lexema, t.lexema);
	simbolo->linha = t.linha;
	simbolo->coluna = t.coluna;
	simbolo->proximo = NULL;
	simbolo->tipo = NULL;
	simbolo->temporario = -1;
	simbolo->vetorLimite = -1;
	simbolo->parametros = (Pilha*) malloc(sizeof(Pilha));
	simbolo->valores = (Pilha*) malloc(sizeof(Pilha));
	simbolo->parametros->elemento = NULL;
	simbolo->parametros->tamanho = 0;
	simbolo->escopo = t.escopo;
	simbolo->funcao = 0;
	simbolo->id = id++;

	if (tabelaSimbolo == NULL) {
		tabelaSimbolo = (ListaSimbolo*) malloc(sizeof(ListaSimbolo));
		tabelaSimbolo->primeiro = simbolo;
	} else {
		Simbolo *aux = tabelaSimbolo->primeiro;
		while (aux->proximo != NULL) aux = aux->proximo;
		aux->proximo = simbolo;
	}

	return simbolo->id;
}

char* buscar_tipo(Nodo *n) {
  char *tipo;			
  if (n->filhos->proximo != NULL) {
    // novo tipo List <>
    tipo = malloc(strlen(n->filhos->val->tipo) + strlen(n->filhos->proximo->val->tipo) + 1);
    strcpy(tipo, n->filhos->val->tipo);
    strcat(tipo, n->filhos->proximo->val->tipo);
  } else {
    // tipo padrão da linguagem
    tipo = malloc(strlen(n->filhos->val->tipo) + 1);
    strcpy(tipo, n->filhos->val->tipo);
  }

  return tipo;
}

void definir_tipo(int id, char *tipo) {
	Simbolo *simbolo = buscar_simbolo_id(id);
	simbolo->tipo = malloc(strlen(tipo) + 1);
	strcpy(simbolo->tipo, tipo);
}

Simbolo* buscar_simbolo_id(int id) {
	Simbolo *simbolo = tabelaSimbolo->primeiro;
	while (simbolo->id != id) simbolo = simbolo->proximo;
	return simbolo;
}

Simbolo* buscar_simbolo(char *s, int escopo) {
	if (tabelaSimbolo == NULL) return NULL;

	Simbolo *simbolo = tabelaSimbolo->primeiro;
	int escopo_busca = escopo;
	while (escopo_busca >= 0) {
		while (simbolo != NULL && !(strcmp(simbolo->lexema, s) == 0 && simbolo->escopo == escopo_busca)) {
			simbolo = simbolo->proximo;
		}
		if (simbolo != NULL) break;
		simbolo = tabelaSimbolo->primeiro;
		escopo_busca--;
	}

	if (escopo_busca == -1) simbolo = NULL;
	return simbolo;
}

Simbolo* buscar_simbolo_escopo(char *s, int escopo) {
	if (tabelaSimbolo == NULL) return NULL;

	Simbolo *simbolo = tabelaSimbolo->primeiro;
	while (simbolo != NULL && !(strcmp(simbolo->lexema, s) == 0 && simbolo->escopo == escopo)) {
		simbolo = simbolo->proximo;
	}

	return simbolo;
}

void mostrar_tabela() {
	printf("Tabela de Símbolos\n\n");
	printf(" Linha |       Identificador       |       Token       |                 Lexema              |   Escopo   \n");
	printf("-----------------------------------------------------------------------------------------------------------\n");
	if (tabelaSimbolo != NULL) {
		Simbolo *simbolo = tabelaSimbolo->primeiro;
		while (simbolo != NULL) {
			printf("%6d | %25d | %17s | %35s | %5d \n", simbolo->linha, simbolo->id, simbolo->token, simbolo->lexema, simbolo->escopo);
			simbolo = simbolo->proximo;
		}
	}
}

void liberar_tabela() {
	if (tabelaSimbolo != NULL) {
		Simbolo *prev = tabelaSimbolo->primeiro;
		Simbolo *prox = prev->proximo;
		while (prox != NULL) {
			free(prev);
			prev = prox;
			prox = prox->proximo;
		}

		free(prev);
	}
}

int busca_main() {
	if (tabelaSimbolo != NULL) {
		Simbolo *simbolo = tabelaSimbolo->primeiro;
		while (simbolo != NULL) {
			if (strcmp(simbolo->lexema, "main") == 0 && simbolo->funcao == 1) {
				return 1;
			}
			simbolo = simbolo->proximo;
		}
	}
	return 0;
}