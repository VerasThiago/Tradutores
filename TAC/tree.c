#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"
#include "utils.h"
#include "semantic.h"

TreeNode* root;
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
    node->symbol = s ? createSymbol(line, column, "variable", s->type, body, scope) :
                       createSymbol(line, column, "variable", "??", body, scope);
    node->type = getTypeID(node->symbol->type);
    return node;
}

void printToken(Symbol* s, int ident){
    printf(" ── [%d:%d] %s", s->line, s->column, s->classType);
    if(strcmp(s->classType, "variable") == 0){
        printf(" : %s %s", s->type, s->body);
    } else if(strcmp(s->classType, s->body) != 0){
        printf(" : %s", s->body);
    }
}

void printCodeLine(TAC* codeLine, int ident){    
    printf(" ── %s %s %s %s", codeLine->func, codeLine->dest, codeLine->arg1, codeLine->arg2);
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

    printRule(root->rule, ident, ok);
    ok[ident] = 1;

    if(root->symbol){
        printToken(root->symbol, ident + 1);
    }

    if(root->codeLine && root->codeLine->func){
        printCodeLine(root->codeLine, ident + 1);
    }

    printf("\n");

    printTree(root->children, ident + 2, ok);
    printTree(root->nxt, ident, ok);
    
}

void getTreeTypeList(TreeNode* root, char ans[]){
    if(!root) return;

    if(root->type != -1){
        char aux[] = "0";
        aux[0] += root->type;
        strcat(ans, aux);
    }
    
    if(!startsWith(root->rule, "expression") && strcmp(root->rule, "function_call") != 0){
        getTreeTypeList(root->children, ans);
    }
    getTreeTypeList(root->nxt, ans);
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
    if(root->codeLine && root->codeLine->func) insertFile(root->codeLine);
    generateTACCodeUtil(root->nxt);
}

void generateTACCode(TreeNode* root){
    if(!root) return;
    fclose(fopen(cExtensionToTACExtension(), "w"));

    FILE *out = fopen(cExtensionToTACExtension(), "a");
    fprintf(out, ".table\n.code\nmain:\n"); 
    fclose(out);

    generateTACCodeUtil(root);
    
    out = fopen(cExtensionToTACExtension(), "a");
    fprintf(out, "\treturn 0\n"); 
    fclose(out);
}

TreeNode* createTACNode(TAC *codeLine){
    TreeNode* node = createNode("TAC");
    node->codeLine = codeLine;
    return node;
}

void buildIfTAC(TreeNode* root, TreeNode* expression, TreeNode* statements){
    char *freeLabel = getFreeLabel();
    char *freeEndLabel = getEndLabel(freeLabel);

    root->codeLine = createTAC(NULL, NULL, NULL, NULL, freeLabel);

    TreeNode* brzNode = createTACNode(createTAC("brz", freeEndLabel, expression->codeLine->dest, NULL, NULL));
    expression->nxt = brzNode;
    brzNode->nxt = statements;

    TreeNode* tmp = statements->nxt;

    TreeNode* endLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeEndLabel));
    statements->nxt = endLabelNode;

    endLabelNode->nxt = tmp;
}

void buildIfElseTAC(TreeNode* root, TreeNode* expression, TreeNode* ifStatements, TreeNode* elseStatements){
    /*
    TODO	

    Before:

    ├─ conditional
    |   ├─ expression_relational  ── [6:10] relational operator : INT < INT ── slt $1023 $0 $1
    |   |   ├─ value  ── [6:8] variable : INT x
    |   |   ├─ value  ── [6:12] variable : INT y
    |   ├─ expression_additive  ── [7:12] additive operator : INT + INT ── add $1022 10 20
    |   |   ├─ const  ── [7:9] INT : 10
    |   |   ├─ const  ── [7:14] INT : 20
    |   ├─ expression_additive  ── [9:11] additive operator : INT + INT ── add $1021 1 1
    |   |   ├─ const  ── [9:9] INT : 1
    |   |   ├─ const  ── [9:13] INT : 1

    After

    ├─ conditional - TAC (null) (null) (null) (null) __0
    |   ├─ expression_relational  ── [6:10] relational operator : INT < INT ── slt $1023 $0 $1
    |   |   ├─ value  ── [6:8] variable : INT x
    |   |   ├─ value  ── [6:12] variable : INT y
    |   ├─ TAC brz __0_if_end $1023 (null)  
    |   ├─ expression_additive  ── [7:12] additive operator : INT + INT ── add $1022 10 20
    |   |   ├─ const  ── [7:9] INT : 10
    |   |   ├─ const  ── [7:14] INT : 20
    |   ├─ TAC jump __0_else_end
    |   ├─ TAC (null) (null) (null) (null) __0_if_end
    |   ├─ expression_additive  ── [9:11] additive operator : INT + INT ── add $1021 1 1
    |   |   ├─ const  ── [9:9] INT : 1
    |   |   ├─ const  ── [9:13] INT : 1
    |   ├─ TAC (null) (null) (null) (null) __0_else_end

    */

    // char *freeLabel = getFreeLabel();
    // char *freeEndLabel = getEndLabel(freeLabel);

    // root->codeLine = createTAC(NULL, NULL, NULL, NULL, freeLabel);

    // TreeNode* brzNode = createTACNode(createTAC("brz", freeEndLabel, expression->codeLine->dest, NULL, NULL));
    // expression->nxt = brzNode;
    // brzNode->nxt = statements;

    // TreeNode* tmp = statements->nxt;

    // TreeNode* endLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeEndLabel));
    // statements->nxt = endLabelNode;

    // endLabelNode->nxt = tmp;
}