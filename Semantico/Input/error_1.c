set globalSet;

int funcSuave(set s){
    return 0;
}

int naoEhMain(){
    add(1 in globalSet);
    globalSet(10 + 3 / 2); // erro pois chama variavel como função
    if(2 + 3 / 2 > 0){
        funcSuave(10); // erro pois não da pra converter int pra set;
    }
}
