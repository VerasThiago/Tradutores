float calcRaiz(float x){
    float L; float R; int i; float ans;
    L = 0; R = x;
    
    for(i = 0; i < 100; i = i + 1){
        float mid;
        mid = (L + R) / 2;
        if(mid * mid <= x){
            ans = mid;
            L = mid;
        } else {
            R = mid;
        }
    }
    return ans;
}

int main(){

    float x;
    write("Digite o valor para encontrar sua raiz: ");
    read(x);
    write("Raiz de ");
    write(x);
    write(" = ");
    writeln(calcRaiz(x));
}