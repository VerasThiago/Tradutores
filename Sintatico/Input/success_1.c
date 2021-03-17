int f(int a, set b, int c){
    exists(a in b);
    if(a == b){
        return 10;
    } else {
        return 20;
    }
}

int main(){
    f(f(a, b, c), b, c);
}