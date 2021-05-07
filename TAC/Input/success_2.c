int fibonacci(int n){
    if(n <= 1) return n;
    int left;
    int right;

    left = fibonacci(n - 1);
    right = fibonacci(n - 2);

    return left + right;
}

int fibonacciDP(int n){
    if(n <= 1) return n;
    
    int i;
    int curr;
    int prev;
    int prevPrev;
    prev = 1;
    prevPrev = 0;

    for(i = 2; i <= n; i = i + 1){
        curr = prev + prevPrev;
        prevPrev = prev;
        prev = curr;
    }
    return curr;
}

int main(){
    int x;
    write("Digite o valor para encontrar o fibonnaci: ");
    read(x);
    write("Fibonnaci de ");
    write(x);
    write(" = ");
    writeln(fibonacciDP(x));
} 