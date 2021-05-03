int main(){
    int x;
    int y;
    read(x);
    read(y);
    if(x < y){
        writeln(x + 90000);
    } else if(y < x) {
        writeln(y - 350000);
    } else {
        writeln(157);
    }
}