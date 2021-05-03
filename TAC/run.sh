bison -d syntatic.y
flex flex.l
gcc -c -g -std=gnu99 utils.c
gcc -c -g -std=gnu99 table.c
gcc -c -g -std=gnu99 tree.c
gcc -c -g -std=gnu99 stack.c
gcc -c -g -std=gnu99 error.c
gcc -c -g -std=gnu99 semantic.c
gcc -c -g -std=gnu99 tac.c  
gcc lex.yy.c syntatic.tab.c utils.o table.o tree.o stack.o error.o semantic.o tac.o -Wall -g -o bison