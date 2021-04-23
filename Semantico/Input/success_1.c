int a;
float b;
set s;
elem el;

int f2() {
    int d;
    float c;
    a + b * b / d - c;
    (a + b) * el;
    1.52 + 3.001 * -4.5;
    return 10;
}

elem el2;

int f(int x, float y, elem j){
    return x / y > el == 2;
}

int func3() {
    (a != b || 1+2 > 3) && 5.5 * 7 == 35;
    f(1, 2, el2) >= f(2, 3, 1);
    !f(5, el, el) || f(6,  3, 1) != 33.33;
    return (1 * 2) + 44.5;
}

elem el3;

int test_set_expression() {
    set s;
    elem el;
    el = EMPTY;
    int boolean;
    boolean = is_set(remove(1 in s));
    boolean = is_set(exists(a in s));
}

int funcFor(){
    forall(a in s) {
        a + b * 13;
        remove(a in s);
    }
    forall(a in add(1 in add(2 in add(2 in s)))) write('\n');
}

int main(){
    writeln("oi");
}