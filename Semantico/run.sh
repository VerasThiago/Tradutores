bison -d syntatic.y
flex flex.l
gcc -c -g table.c
gcc -c -g tree.c
gcc -c -g stack.c
gcc -c -g error.c
gcc lex.yy.c syntatic.tab.c table.o tree.o stack.o error.o -Wall -ll -g -o bison