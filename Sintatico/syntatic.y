%define parse.error verbose
%define parse.lac none
%define api.pure
%debug
%defines

%{

#include "structure.h"
#include "symbols.h"

extern int yylex();
extern Nodo *raiz;
extern Pilha *pilhaParametros;
extern Pilha *pilhaArgumentos;
extern Pilha *pilhaValores;
extern Pilha *pilhaAtribuicao;
extern char *retornoFuncao;
extern char *funcaoAtual;
extern int novoTemporario;
extern int novoLabel;
extern int numeroParametro;
extern char erroGlobal[2000000];

%}

%union {
	Token token;
	Nodo *nodo;
}

%token <token> T_Integer
%token <token> T_Float
%token <token> T_Bool
%token <token> T_Return
%token <token> T_If
%token <token> T_LeftParentheses
%token <token> T_RightParentheses
%token <token> T_Else
%token <token> T_While
%token <token> T_Write
%token <token> T_Read
%token <token> T_Type
%token <token> T_List
%token <token> T_ListType
%token <token> T_ListOperation
%token <token> T_Id
%token <token> T_Op1 
%token <token> T_Op2
%token <token> T_Op3
%token <token> T_assignment
%token <token> T_LeftBrace
%token <token> T_RightBrace
%token <token> T_LeftBracket
%token <token> T_RightBracket
%token <token> T_Semicolon
%token <token> T_Comma

%type <nodo> type_identifier
%type <nodo> expression
%type <nodo> expression_1
%type <nodo> expression_2
%type <nodo> expression_3
%type <nodo> value
%type <nodo> number
%type <nodo> function_call
%type <nodo> array_access
%type <nodo> conditional
%type <nodo> identifiers_list
%type <nodo> variables_declaration
%type <nodo> function_definition
%type <nodo> function_declaration
%type <nodo> function_body
%type <nodo> parameters
%type <nodo> program
%type <nodo> statements
%type <nodo> statement
%type <nodo> return
%type <nodo> loop
%type <nodo> conditional_expression
%type <nodo> while
%type <nodo> read
%type <nodo> write
%type <nodo> parameters_list
%type <nodo> parameter
%type <nodo> arguments_list
%type <nodo> numbers_list
%type <nodo> start

%start start

%%

start:
	program {
		raiz = $$;
	}

program:
	function_definition {
	}
	| function_definition program {
	}
	| variables_declaration program {
	}

function_definition:
	function_declaration parameters function_body {
		numeroParametro = 0;

		ListaNodo *ultimoFilho = $1->filhos;
		while (ultimoFilho->proximo) ultimoFilho = ultimoFilho->proximo;
		int id = ultimoFilho->val->id;

		if (id != -1) {
			Simbolo *simbolo = buscar_simbolo_id(id);
			simbolo->funcao = 1;

			if (pilhaParametros != NULL) {
				simbolo->parametros->elemento = pilhaParametros->elemento;
				simbolo->parametros->tamanho = pilhaParametros->tamanho;
				pilhaParametros = NULL;
			}
		}

	}

function_declaration:
	type_identifier T_Id {
		Simbolo *simbolo = buscar_simbolo_escopo($2.lexema, $2.escopo);
		int id = -1;
		if (simbolo != NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: redeclaração da função %s, primeira ocorrência na linha %d\n", $2.linha, $2.lexema, simbolo->linha);
		} else {
			id = criar_simbolo($2);
			char *tipo = buscar_tipo($1);
			definir_tipo(id, tipo);

			
			funcaoAtual = malloc(strlen($2.lexema) + 1);
			strcpy(funcaoAtual, $2.lexema);
		}

	}

function_body:
	T_LeftBrace statements T_RightBrace {
	}

parameters:
	T_LeftParentheses parameters_list T_RightParentheses {
		pilhaValores = pilha_libera(pilhaValores);

	}
	| T_LeftParentheses T_RightParentheses {
	}

parameters_list:
	parameter T_Comma parameters_list {
		pilhaParametros = pilha_push(pilhaParametros, pilhaValores->elemento->val);
		pilhaValores = pilha_pop(pilhaValores);

	} 
	| parameter {
		pilhaParametros = pilha_push(pilhaParametros, pilhaValores->elemento->val);
		pilhaValores = pilha_pop(pilhaValores);

	}

parameter:
	type_identifier T_Id {
		int id = criar_simbolo($2);
		char *tipo = buscar_tipo($1);
		definir_tipo(id, tipo);
		
		Simbolo *simbolo = buscar_simbolo_id(id);
		simbolo->temporario = novoTemporario;
		novoTemporario++;


		pilhaValores = pilha_push(pilhaValores, id);

	}
	| type_identifier T_Id T_LeftBracket T_RightBracket {
		Simbolo *simbolo = buscar_simbolo_escopo($2.lexema, $2.escopo);
		int id = -1;
		if (simbolo != NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: redeclaração da variável %s, primeira ocorrência na linha %d\n", $2.linha, $2.lexema, simbolo->linha);
		} else {
			id = criar_simbolo($2);
			char *tipo = buscar_tipo($1);
			definir_tipo(id, tipo);
			pilhaValores = pilha_push(pilhaValores, id);
		}

	}

type_identifier:
	T_List T_ListType {
	} 
	| T_Type {
	}

statements:
	statement statements {
	}
	| T_LeftBrace statements T_RightBrace {
	}
	| statement {
	}

statement:
	variables_declaration {
	}
	| return {
	}
	| conditional {
	}
	| loop {
	}
	| expression T_Semicolon {
	}
	| read {
	}
	| write {
	}

read:
	T_Read T_Id T_Semicolon {
		Simbolo *simbolo = buscar_simbolo($2.lexema, $2.escopo);
		int id = -1;
		if (simbolo == NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: variável %s sendo usada porém não foi declarada\n", $2.linha, $2.lexema);
		} else {
			if (strcmp($1.lexema, "readInt") == 0) {
				if (strcmp(simbolo->tipo, "int") == 0) {
				} else {
					sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: comando de leitura espera receber variável do tipo int\n", $2.linha);
				}
			} else {
				if (strcmp(simbolo->tipo, "float") == 0) {
				} else {
					sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: comando de leitura espera receber variável do tipo float\n", $2.linha);
				}
			}
		}

		
	}

write:
	T_Write T_Id T_Semicolon {
		Simbolo *simbolo = buscar_simbolo($2.lexema, $2.escopo);
		int id = -1;
		if (simbolo == NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: variável %s sendo usada porém não foi declarada\n", $2.linha, $2.lexema);
		} else {
		}

	}

function_call:
	T_Id T_LeftParentheses arguments_list T_RightParentheses  {
		pilhaValores = pilha_libera(pilhaValores);

		Simbolo *simbolo = buscar_simbolo($1.lexema, 0);
		int id = -1;
		if (simbolo == NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: função %s não foi declarada\n", $1.linha, $1.lexema);
		} else {
			id = simbolo->id;
			if (simbolo->parametros->tamanho != pilhaArgumentos->tamanho) {
				sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: função espera receber %d argumentos mas foi chamada com %d argumentos\n", $1.linha, simbolo->parametros->tamanho, pilhaArgumentos->tamanho);
			} else {
				// o que eu espero receber
				PilhaElemento *parametros = simbolo->parametros->elemento; 
				
				// o que eu recebi
				PilhaElemento *argumentos = pilhaArgumentos->elemento;
				
				int numeroArgumento = 1;

				while (parametros != NULL && argumentos != NULL) {
					Simbolo* parametro = buscar_simbolo_id(parametros->val);
					Simbolo* argumento = buscar_simbolo_id(argumentos->val);

					char *parametroTipo = parametro->tipo;
					char *argumentoTipo = argumento->tipo;

				
					parametros = parametros->proximo;
					argumentos = argumentos->proximo;
					numeroArgumento++;
				}

			}
		}

		pilhaArgumentos = pilha_libera(pilhaArgumentos);


	}
	| T_Id T_LeftParentheses T_RightParentheses  {
		Simbolo *simbolo = buscar_simbolo($1.lexema, 0);
		int id = -1;
		if (simbolo == NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: função %s não foi declarada\n", $1.linha, $1.lexema);
		} else {
			id = simbolo->id;
		}

	}

arguments_list:
	value T_Comma arguments_list  {
		pilhaArgumentos = pilha_push(pilhaArgumentos, pilhaValores->elemento->val);
		pilhaValores = pilha_pop(pilhaValores);

	}
	| value {
		pilhaArgumentos = pilha_push(pilhaArgumentos, pilhaValores->elemento->val);
		pilhaValores = pilha_pop(pilhaValores);

	}

conditional: 
	T_If conditional_expression statements {


	}

loop:
	while conditional_expression T_LeftBrace statements T_RightBrace {



	}

while:
	T_While {

		// label de inicio
		$$->label = novoLabel;
		novoLabel++;

	}

conditional_expression:
	T_LeftParentheses expression T_RightParentheses {

		// label de fim
		$$->label = novoLabel;
		novoLabel++;


	}

return:
	T_Return value T_Semicolon {
		Simbolo *simbolo = buscar_simbolo_id(pilhaValores->elemento->val);
		retornoFuncao = malloc(strlen(simbolo->tipo) + 1);
		strcpy(retornoFuncao, simbolo->tipo);
	}

value:
	T_Id {

		Simbolo *simbolo = buscar_simbolo($1.lexema, $1.escopo);
		int id = -1;
		if (simbolo == NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: variável %s sendo usada porém não foi declarada\n", $1.linha, $1.lexema);
		} else {
			id = simbolo->id;
			pilhaValores = pilha_push(pilhaValores, id);
			$$->temporario = simbolo->temporario;
		}

	}
	| number {
		$$ = $1;
	}
	| array_access {
	}
	| function_call {

		$$->temporario = novoTemporario;
		novoTemporario++;

	}
	| T_ListOperation T_LeftParentheses T_Id T_RightParentheses {
		
		Simbolo *simbolo = buscar_simbolo($3.lexema, $3.escopo);
		int id = -1;
		if (simbolo == NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: variável %s sendo usada porém não foi declarada\n", $3.linha, $3.lexema);
		} else {
			id = simbolo->id;
			if (strcmp(simbolo->tipo, "List<int>") != 0 && strcmp(simbolo->tipo, "List<float>") != 0) {
				sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: função %s aceita apenas variável do tipo List\n", $1.linha, $1.lexema);
			}
			
			char tamanho[90];
			sprintf(tamanho, "tamanho_variavel_%s", simbolo->lexema);

			if (strcmp($1.lexema, "Med") == 0 || strcmp($1.lexema, "Md") == 0) {
			}


			$$->temporario = novoTemporario;
			novoTemporario++;

		}

		simbolo = buscar_simbolo($1.lexema, 0);
	}
	| T_Bool {
		int id = criar_simbolo($1);
		Simbolo *simbolo = buscar_simbolo_id(id);
		strcpy(simbolo->token, "bool");
		simbolo->tipo = malloc(strlen("bool") + 1);
		strcpy(simbolo->tipo, "bool");
		pilhaValores = pilha_push(pilhaValores, id);

	}

array_access:
	T_Id T_LeftBracket T_Integer T_RightBracket  {
		Simbolo *simbolo = buscar_simbolo($1.lexema, $1.escopo);
		int id = -1;
		if (simbolo == NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: variável %s sendo usada porém não foi declarada\n", $1.linha, $1.lexema);
		} else {
			id = simbolo->id;
			int posicao = atoi($3.lexema);
			if (posicao < 0 || posicao >= simbolo->vetorLimite) {
				sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: posição %d inválida no vetor %s\n", $1.linha, posicao, $1.lexema);
			}
		}

	}

variables_declaration:
	type_identifier identifiers_list T_Semicolon {
		char *tipo = buscar_tipo($1);
	}

identifiers_list:
	T_Id T_Comma identifiers_list {
		Simbolo *simbolo = buscar_simbolo_escopo($1.lexema, $1.escopo);
		int id = -1;
		if (simbolo != NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: redeclaração da variável %s, primeira ocorrência na linha %d\n", $1.linha, $1.lexema, simbolo->linha);
		} else {
			id = criar_simbolo($1);
			
			simbolo = buscar_simbolo_id(id);
			simbolo->temporario = novoTemporario;
			novoTemporario++;

		}
		
	}
	|
	T_Id T_LeftBracket T_Integer T_RightBracket T_Comma identifiers_list {
		Simbolo *simbolo = buscar_simbolo_escopo($1.lexema, $1.escopo);
		int id = -1;
		if (simbolo != NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: redeclaração da variável %s, primeira ocorrência na linha %d\n", $1.linha, $1.lexema, simbolo->linha);
		} else {
			id = criar_simbolo($1);
			definir_tipo(id, "[]");
			simbolo = buscar_simbolo_id(id);
			simbolo->vetorLimite = atoi($3.lexema);

			simbolo->temporario = novoTemporario;
			novoTemporario++;
		}

	}
	| 
	T_Id T_LeftBracket T_Integer T_RightBracket {
		Simbolo *simbolo = buscar_simbolo_escopo($1.lexema, $1.escopo);
		int id = -1;
		if (simbolo != NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: redeclaração da variável %s, primeira ocorrência na linha %d\n", $1.linha, $1.lexema, simbolo->linha);
		} else {
			id = criar_simbolo($1);
			definir_tipo(id, "[]");
			simbolo = buscar_simbolo_id(id);
			simbolo->vetorLimite = atoi($3.lexema);

			simbolo->temporario = novoTemporario;
			novoTemporario++;
		}

	
	}
	| 
	T_Id {
		Simbolo *simbolo = buscar_simbolo_escopo($1.lexema, $1.escopo);
		int id = -1;
		if (simbolo != NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: redeclaração da variável %s, primeira ocorrência na linha %d\n", $1.linha, $1.lexema, simbolo->linha);
		} else {
			id = criar_simbolo($1);
			simbolo = buscar_simbolo_id(id);
			simbolo->temporario = novoTemporario;
			novoTemporario++;
		}

	}

expression:
	T_Id T_assignment expression {

		Simbolo *simbolo = buscar_simbolo($1.lexema, $1.escopo);
		int id = -1;
		if (simbolo == NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: variável %s sendo usada porém não foi declarada\n", $1.linha, $1.lexema);
		} else {
			id = simbolo->id;

			$$->temporario = simbolo->temporario;

		}

	}
	| array_access T_assignment expression {
	}
	| expression_1 {
		$$ = $1;
	}
	| T_Id T_assignment T_LeftBrace numbers_list T_RightBrace {

		Simbolo *simbolo = buscar_simbolo($1.lexema, $1.escopo);
		int id = -1;
		if (simbolo == NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: variável %s sendo usada porém não foi declarada\n", $1.linha, $1.lexema);
		} else {
			id = simbolo->id;
			if (simbolo->tipo[0] != 'L' && simbolo->vetorLimite == -1) {
				sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: a variável %s deve ser do tipo List ou vetor\n", $1.linha, $1.lexema);
			}

			simbolo->valores = pilha_libera(simbolo->valores);

			PilhaElemento *atribuicoes = 	pilhaAtribuicao->elemento;		

			char tipo[9];
			if (simbolo->tipo[0] == 'L') {
				if (simbolo->tipo[5] == 'i') strcpy(tipo, "int");
				else strcpy(tipo, "float");
			} else {
				strcpy(tipo, simbolo->tipo);
			}

			int falha = 0;
			int i = 0;


			while (atribuicoes != NULL) {
				Simbolo* numero = buscar_simbolo_id(atribuicoes->val);
				
				if (falha == 0 && strcmp(tipo, "float") != 0 && strcmp(tipo, numero->tipo) != 0) {
					falha = 1;
					sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: a variável %s espera receber valores do tipo %s\n", $1.linha, $1.lexema, tipo);
				}

				simbolo->valores = pilha_push(simbolo->valores, numero->id);
	

				atribuicoes = atribuicoes->proximo;
				i++;
			}
			
			pilhaAtribuicao = pilha_libera(pilhaAtribuicao);

			$$->temporario = simbolo->temporario;

		}

	}

expression_1:
	expression_2 T_Op1 expression_1 {

		$$->temporario = novoTemporario;
		novoTemporario++;

		if ($2.lexema[0] == '<') {
		} else if ($2.lexema[0] == '>') {
		} else if ($2.lexema[0] == '=') {
		}

	} 
	| expression_2 {
		$$ = $1;
	}

expression_2:
	expression_3 T_Op2 expression_2 {

		$$->temporario = novoTemporario;
		novoTemporario++;

		if ($2.lexema[0] == '+') {
		} else if ($2.lexema[0] == '-') {
		} else if ($2.lexema[0] == '&') {
		} else if ($2.lexema[0] == '|') {
		}

	}
	| expression_3 {
		$$ = $1;
	}

expression_3:
	expression_3 T_Op3 value {

		$$->temporario = novoTemporario;
		novoTemporario++;

		if ($2.lexema[0] == '*') {
		} else if ($2.lexema[0] == '/') {
		}

	}
	| value {
		$$ = $1;
	}

numbers_list:
	number T_Comma numbers_list {
		pilhaAtribuicao = pilha_push(pilhaAtribuicao, pilhaValores->elemento->val);
		pilhaValores = pilha_pop(pilhaValores);

	}
	| number {
		pilhaAtribuicao = pilha_push(pilhaAtribuicao, pilhaValores->elemento->val);
		pilhaValores = pilha_pop(pilhaValores);

		$$ = $1;
	}

number:
	T_Integer {
		int id = criar_simbolo($1);
		Simbolo *simbolo = buscar_simbolo_id(id);
		strcpy(simbolo->token, "int");
		simbolo->tipo = malloc(strlen("int") + 1);
		strcpy(simbolo->tipo, "int");
		pilhaValores = pilha_push(pilhaValores, id);


		$$->temporario = novoTemporario;
		novoTemporario++;

		simbolo->temporario = $$->temporario;


	}
	| T_Float {
		int id = criar_simbolo($1);
		Simbolo *simbolo = buscar_simbolo_id(id);
		strcpy(simbolo->token, "float");
		simbolo->tipo = malloc(strlen("float") + 1);
		strcpy(simbolo->tipo, "float");
		pilhaValores = pilha_push(pilhaValores, id);


		$$->temporario = novoTemporario;
		novoTemporario++;

		simbolo->temporario = $$->temporario;


	}

%%
