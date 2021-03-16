bison -d syntatic.y
flex flex.l
gcc -o bison lex.yy.c syntatic.tab.c -Wall -ll 