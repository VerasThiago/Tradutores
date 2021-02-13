#!/bin/bash
flex flex.l
gcc lex.yy.c

ERRORS_QNT=2
i=1
while [ $i -le $ERRORS_QNT ]
do
    ./a.out < "Input/error_$i.c" > "Output/error_$i"
    result=$(diff Expected/error_$i Output/error_$i)
    if [ -z "$result" ]
    then
        echo -e "\e[32mError $i SUCCESS\e[39m"
    else
        echo -e "\e[31mError $i FAILED\e[39m"
    fi
    i=$((i + 1))
done

SUCCESS_QNT=2
i=1
while [ $i -le $SUCCESS_QNT ]
do
    ./a.out < "Input/success_$i.c" > "Output/success_$i"
    result=$(diff Expected/success_$i Output/success_$i)
    if [ -z "$result" ]
    then
        echo -e "\e[32mSuccess $i SUCCESS\e[39m"
    else
        echo -e "\e[31mSuccess $i FAILED\e[39m"
    fi
    i=$((i + 1))
done