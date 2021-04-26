set globalSet;

int funcSuave(set s, int a, int b){
    return 0;
}

int naoEhMain(){
    add(1 in globalSet);
    globalSet(10 + 3 / 2); // erro pois chama variavel como função
    if(2 + 3 / 2 > 0){
        funcSuave(10, globalSet, 10); // erro pois não da pra converter int pra set e nem set pra int (args 1 e 2);
    }
}

// error pois falta func main