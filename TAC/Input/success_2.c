int main(){
    int n;
    read(n);
    int x;
    int sum;
    sum = 0;
    int i;
    for(i = 0; i < n ; i = i + 1){
        read(x);
        if(x < 0){
            sum = sum - x;
        } else {
            sum = sum + x;
        }
    }
    writeln(sum);
}