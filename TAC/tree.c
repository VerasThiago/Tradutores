#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"
#include "utils.h"
#include "semantic.h"

TreeNode* root;
char tableCode[1000] = "";
GarbageCollector garbageCollector;

TreeNode* createNode(char* rule){
    TreeNode* node = (TreeNode*) malloc(sizeof(TreeNode));
    node->rule = strdup(rule);
    node->children = NULL;
    node->nxt = NULL;
    node->symbol = NULL;
    node->codeLine = NULL;
    node->type = -1;
    node->cast = -1;
    pushGarbageCollector(node, NULL);
    return node;
}

TreeNode* createIDNode(Symbol* s, int line, int column, char* body, int scope){
    TreeNode* node = createNode("value");
    node->symbol = s ? createSymbol(line, column, "variable", s->type, body, scope, -1) :
                       createSymbol(line, column, "variable", "??", body, scope, -1);
    node->type = getTypeID(node->symbol->type);
    return node;
}

void printToken(Symbol* s, int ident){
    printf(" ── [%d:%d] %s", s->line, s->column, s->classType);
    if(strcmp(s->classType, "variable") == 0){
        printf(" : %s %s", s->type, s->body);
    } else if(strcmp(s->classType, s->body) != 0){
        printf(" : %s%s", s->negative ? "-":"", s->body);
    }
}

void printCodeLine(TAC* codeLine, int ident){    
    printf(" ── %s %s %s %s %s", codeLine->func ? codeLine->func: "?", codeLine->dest ? codeLine->dest: "?", codeLine->arg1 ? codeLine->arg1: "?", codeLine->arg2 ? codeLine->arg2: "?", codeLine->label ? codeLine->label: "?");
}

void printRule(char* s, int ident, int *ok){
    for(int i = 0; i < ident; i++) {
        if(ok[i]) printf("|");
        else printf(" ");
        printf(" ");
    }
    printf("├─ %s ", s);
}

void printTree(TreeNode* root, int ident, int *ok){
    if(!root) return;

    // Change to TAC to not display on tree or TAX to display
    if(strcmp(root->rule, "TAC") == 0) {
        printTree(root->children, ident + 2, ok); 
        printTree(root->nxt, ident, ok); 
        return;
    }

    printRule(root->rule, ident, ok);
    ok[ident] = 1;

    if(root->symbol){
        printToken(root->symbol, ident + 1);
    }

    // Change to 0 to not display on tree or 1 to display
    if(0 && root->codeLine && (root->codeLine->func || root->codeLine->label || root->codeLine->dest) ){ 
        printCodeLine(root->codeLine, ident + 1);
    }

    printf("\n");

    printTree(root->children, ident + 2, ok);
    printTree(root->nxt, ident, ok);
    
}


void getTreeArgs(TreeNode* root, char ans[]){
    if(!root) return;

    if(root->type != -1){
        char aux[] = "0";
        aux[0] += root->type;
        strcat(ans, aux);
    }
    
    if(!startsWith(root->rule, "expression") && !startsWith(root->rule, "function_call")){
        getTreeArgs(root->children, ans);
    }

    if(root->type != -1){
        TreeNode* paramNode;
        TreeNode* lastNode = getLastNodeNxt(root);
        
        if(lastNode && lastNode->codeLine && lastNode->codeLine->dest) paramNode = createTACNode(createTAC("param", NULL, lastNode->codeLine->dest, NULL, NULL));
        else if(root->symbol->id != -1) paramNode = createTACNode(createTAC("param", NULL, getRegisterFromId(root->symbol->id), NULL, NULL));
        else paramNode = createTACNode(createTAC("param", NULL, root->codeLine->dest, NULL, NULL));

        if(lastNode) lastNode->nxt = paramNode;
        else root->children = paramNode;
    }

    getTreeArgs(root->nxt, ans);

}

void getTreeParamsAndAssignPos(TreeNode* root, char ans[], int *idx){
    if(!root) return;

    if(root->type != -1){
        char aux[] = "0";
        aux[0] += root->type;
        strcat(ans, aux);
        root->symbol->paramPos = *idx;
        (*idx)++;
    }
    
    if(!startsWith(root->rule, "expression") && !startsWith(root->rule, "function_call")){
        getTreeParamsAndAssignPos(root->children, ans, idx);
    }
    getTreeParamsAndAssignPos(root->nxt, ans, idx);
}


void freeTree(TreeNode* root){
    if(!root) return;

    freeTree(root->children);
    freeTree(root->nxt);
    
    if(root->symbol){
        free(root->symbol->classType);
        free(root->symbol->type);
        free(root->symbol->body);
        free(root->symbol);
    }
    if(root->rule){
        free(root->rule);
    }
    free(root);
}

void generateTACCodeUtil(TreeNode* root){
    if(!root) return;
    if(root->codeLine && root->codeLine->label) insertFile(root->codeLine);
    generateTACCodeUtil(root->children);
    if(root->codeLine && root->codeLine->func && strcmp(root->codeLine->func, "call") != 0) insertFile(root->codeLine);
    generateTACCodeUtil(root->nxt);
    if(root->codeLine && root->codeLine->func && strcmp(root->codeLine->func, "call") == 0) insertFile(root->codeLine);
}

char* printStringTacCode(){
    char *printCode = strdup( 
        "__printf:\n"
        "\tmov $1022, 0\n"
        "__while:\n"
        "\tmov $1023, #1\n"
        "\tmov $1023, $1023[$1022]\n"
        "\tprint $1023\n"
        "\tsub $1023, $1022, #0\n"
        "\tadd $1022, $1022, 1\n"
        "\tbrnz __while, $1023\n"
        "\treturn\n"
        "\t\n"
        "__printfln:\n"
        "\tcall __printf, 2\n"
        "\tprintln\n"
        "\treturn\n"
    );
    pushGarbageCollector(NULL, printCode);
    return printCode;
}

void generateTACCode(TreeNode* root){
    if(!root) return;
    fclose(fopen(cExtensionToTACExtension(), "w"));

    FILE *out = fopen(cExtensionToTACExtension(), "a");
    fprintf(out, ".table\n%s.code\n%s", tableCode, printStringTacCode()); 
    fclose(out);

    generateTACCodeUtil(root);

    out = fopen(cExtensionToTACExtension(), "a");
    fprintf(out, "main:\n\tcall __0_main, 0\n"); 
    fclose(out);
}

TreeNode* createTACNode(TAC *codeLine){
    TreeNode* node = createNode("TAC");
    node->codeLine = codeLine;
    return node;
}

TreeNode* getLastNodeNxt(TreeNode* curr){
    if(!curr) return curr;
    while(curr->nxt) curr = curr->nxt;
    return curr;
}

//TODO: Remove this gambiarra (save to file and concat into TAC code)
void writeTableVar(char* type, int id, char* content){
    char aux[300] = "";
    if(strcmp(type, "str") == 0){
        sprintf(aux, "\tchar %s [] = %s\n", getFreeLabel(type, id), content);
    } else return;
    strcat(tableCode, aux);
}

void buildPrintStringTAC(TreeNode* root, char* op){


    if(root->symbol->body[0] == '\''){
        TreeNode* printNode = createTACNode(createTAC("print", NULL, root->symbol->body, NULL, NULL));
        root->children = printNode;
        return;
    }
    
    writeTableVar("str", root->symbol->id, root->symbol->body);

    char *freeRegister = getFreeRegister();

    TreeNode* param1Node = createTACNode(createTAC("param", NULL, intToStr(strlen(root->symbol->body) - 2), NULL, NULL));
    TreeNode* movNode = createTACNode(createTAC("mov", freeRegister, getLabelAddress(getFreeLabel("str", root->symbol->id)), NULL, NULL));
    TreeNode* param2Node = createTACNode(createTAC("param", NULL, freeRegister, NULL, NULL));
    TreeNode* callNode = createTACNode(createTAC("call", op, "2", NULL, NULL));

    root->children = param1Node;
    param1Node->nxt = movNode;
    movNode->nxt = param2Node;
    param2Node->nxt = callNode;
}

void buildIfTAC(TreeNode* root, TreeNode* expression, TreeNode* statements){
    if(!expression->codeLine) return;

    char *freeIfLabel = getFreeLabel("if", -1);
    char *freeEndLabel = getEndLabel(freeIfLabel);

    TreeNode* ifLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeIfLabel));
    TreeNode* endLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeEndLabel));
    TreeNode* brzNode = createTACNode(createTAC("brz", freeEndLabel, getLastNodeNxt(expression)->codeLine->dest, NULL, NULL));

    root->children = ifLabelNode;
    ifLabelNode->children = expression;

    getLastNodeNxt(expression)->nxt = brzNode;
    brzNode->nxt = statements;

    ifLabelNode->nxt = endLabelNode;
}

void buildIfElseTAC(TreeNode* root, TreeNode* expression, TreeNode* ifStatements, TreeNode* elseStatements){
    if(!expression->codeLine) return;

    int getFreeId = getFreeLabelId();
    char *freeIfLabel = getFreeLabel("if", getFreeId);
    char *freeElseLabel = getFreeLabel("else", getFreeId);
    char *freeElseEndLabel = getEndLabel(freeElseLabel);
    
    TreeNode* ifLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeIfLabel));
    TreeNode* elseLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeElseLabel));
    TreeNode* elseEndLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeElseEndLabel));

    TreeNode* brzNode = createTACNode(createTAC("brz", freeElseLabel, getLastNodeNxt(expression)->codeLine->dest, NULL, NULL));
    TreeNode* jumpNode = createTACNode(createTAC("jump", NULL, freeElseEndLabel, NULL, NULL));
    
    root->children = ifLabelNode;
    ifLabelNode->children = expression;
    ifLabelNode->nxt = elseLabelNode;
    elseLabelNode->nxt = elseEndLabelNode;

    getLastNodeNxt(expression)->nxt = brzNode;
    brzNode->nxt = ifStatements;

    getLastNodeNxt(ifStatements)->nxt = jumpNode;
   
    elseLabelNode->children = elseStatements;
    
}

void buildForTAC(TreeNode* root, TreeNode* pre, TreeNode* check, TreeNode* after, TreeNode* statement){

    int forLabelId = getFreeLabelId();

    char *freeForLabel = getFreeLabel("for", forLabelId);
    char *freeForPreCheckLabel = getFreeLabel("for_pre_check", forLabelId);
    char *freeForCheckLabel = getFreeLabel("for_check", forLabelId);
    char *freeForStatementLabel = getFreeLabel("for_statement", forLabelId);
    char *freeForAfterStatementLabel = getFreeLabel("for_after_statement", forLabelId);
    char *freeForEndLabel = getEndLabel(freeForLabel);

    TreeNode* forLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeForLabel));
    TreeNode* forPreCheckLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeForPreCheckLabel));
    TreeNode* forCheckLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeForCheckLabel));
    TreeNode* forStatementLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeForStatementLabel));
    TreeNode* forAfterStatementLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeForAfterStatementLabel));
    TreeNode* forEndLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeForEndLabel));


    TreeNode* brzNode = createTACNode(createTAC("brz", freeForEndLabel, check->codeLine->dest, NULL, NULL));
    TreeNode* jumpNodeCheck = createTACNode(createTAC("jump", NULL, freeForCheckLabel, NULL, NULL));

    forLabelNode->nxt = root->children;
    root->children = forLabelNode;

    getLastNodeNxt(forLabelNode)->nxt = forPreCheckLabelNode;
    forPreCheckLabelNode->nxt = pre;

    getLastNodeNxt(pre)->nxt = forCheckLabelNode;
    forCheckLabelNode->nxt = check;

    getLastNodeNxt(check)->nxt = brzNode;
    brzNode->nxt = statement;
    getLastNodeNxt(statement)->nxt = forAfterStatementLabelNode;
    forAfterStatementLabelNode->nxt = after;
    getLastNodeNxt(after)->nxt = jumpNodeCheck;
    jumpNodeCheck->nxt = forEndLabelNode;

}
