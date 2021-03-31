// Teste de todas as estruturas
// Declaracao global
int a;
float b;
set c;
elem el;


int test_aritmetic_expression() {
    a + b * c / d - k;
    (a + b) * c;
    a + (-b * (c - d));
    +a + (-(-b));
    1.52 + 3.001 * -4.5;
    return;
}

elem el2;

int test_relational_expression() {
    (a > b);
    (a != b) || (a == c);
    (a != b || 1+2 > 3) && 5.5 * 7 == 35;
    !a && !b && 1 >= 2;
    f(1, 2, b);
    f(1, 2) >= f(2, 3);
    !f(5) || f(6) != 33.33;
    1 + 3 * -f(1,2);
    return (1 * 2) + 44.5;
}

elem el3;

int test_set_expression() {
    set s;
    elem el;
    el = EMPTY;
    boolean = 12 in s;
    add(b in s);
    add(23.3 in s);
    add(!f(2.5) in s);
    add( exists(a in b) in add(1 + 2 in b));
    add(1 in add(2 in add(5 in add(8 in s))));
    remove(b in s);
    remove(23.3 in s);
    remove(!f(2.5) in s);
    exists(b in s);
    exists(b in add(1 in add( 2 in add (3 in remove(4 in s)))));
    exists(a in add(exists(b in s) in s));
    boolean = 4 in add(1 in add(2 in s));
    boolean = is_set(s);
    // boolean = is_set(add(1 in s));
    boolean = !is_set(a);
    boolean = !is_set(a) || is_set(b);
    forall(a in s) {
        a + b * c;
        remove(a in s);
    }
    forall(a in add(1 in add(2 in add(2 in s)))) write('\n');
    forall(a in s) if (a == 1) {
        writeln("oi");
    } else {
        write("tchau");
    }
}

int test_if_stmt() {
    if(simpleif){
        int i;
        a = 0;
    }
    if(simpleifelse){
        a = 5;
        b = 12 in s;
    }
    else{
        a = b = 0;
    }
    if(ifinline_with_some_relational < 1 && !a)
        writeln('\t');
    if(f( (1 + 2) - b, 3 / (((3))), exists(b in add(1 in add(2 in s)))) && 2 > 3 || 4){
        write("puts");
        write('\n');
    }
}


// Arquivo teste de escopo: https://pastebin.com/CV7MqzTp
// Resposta dos escopos: https://pastebin.com/vN2sZ2YD (Nao contando escopo de parametros)
