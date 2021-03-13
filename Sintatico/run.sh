bison syntatic.y --report=all
gcc -c -o syntatic.tab.o syntatic.tab.c
flex flex.l
gcc -c -o lex.yy.o lex.yy.c
gcc -c -o structure.o structure.c
gcc -c -o symbols.o symbols.c
gcc -c -o index.o index.c
gcc -g -o Sintatico lex.yy.o syntatic.tab.o symbols.o structure.o index.o