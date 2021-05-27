## Notes pós correção

- O GCC apresentou 1 warnings ao gerar o programa, utilizadas as flags -g e -Wall.

- O arquivo 'error_1.c' tem um erro quanto a chamada com tipos incompatíveis. O local do erro apontado é o local da declaração da função e não onde ela foi chamada.

- O arquivo 'error_2.c' tem um erro léxico com o apontamento de coluna deslocada em várias posições.

* nossos testes: falhou na execução do código gerado; o código gerado executa com warnings.

* erro não identificado pelo analisador semântico (return sem argumento quando o tipo da função é int).

* dá a localização errada para chamada incompatível de funções.

* apresenta falha de segmentação ao gerar os nós da expressão float op = 1 +;.

Léxico:

- Faltou apenas a validação dos caracteres especiais de escape.

Sintático: 

- Nenhuma observação.

Semântico:

- Nenhuma observação.

## Meu ponto

- Precisava tirar 0.7 pro MS nesse, então nao me dediquei

- Teoricamente fiz tudo menos set e elem (mas eu dei uns revert de ultima hora e n testei então se pa isso deu um monte de bug que ela falo ali)

- É isso