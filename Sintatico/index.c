#include "structure.h"
#include "symbols.h"
#include "syntatic.tab.h"

int linha = 1;
int coluna, errors, escopo = 0;
char erroGlobal[2000000];
int erroSintatico = 0;
char *codeTAC;
char *tableTAC;
char operacaoTAC;
char *funcaoAtual;

Nodo *raiz;
Pilha *pilhaParametros;
Pilha *pilhaArgumentos;
Pilha *pilhaValores;
Pilha *pilhaAtribuicao;
char *retornoFuncao;
int novoTemporario = 0;
int novoLabel = 0;
int numeroParametro = 0;

int main() {
	yyparse();

	printf("\n");
	mostrar_tabela();
	printf("\n");

	if (erroSintatico == 0 && busca_main() == 0) sprintf(erroGlobal + strlen(erroGlobal),"Função main não foi declarada\n");
	if (erroGlobal[0]) {
		printf("%s", erroGlobal);
	} 

	liberar_tabela();
	pilha_libera(pilhaParametros);
	pilha_libera(pilhaArgumentos);
	pilha_libera(pilhaValores);

	printf("\n");
}

void yyerror (char const *s) {
	erroSintatico = 1;
  sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: %s\n", linha, s);
}