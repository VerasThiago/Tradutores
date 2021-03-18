bison -d syntatic.y
flex flex.l
gcc -c table.c
gcc -c tree.c
gcc -c stack.c
gcc lex.yy.c syntatic.tab.c table.o tree.o stack.o -Wall -ll -o bison