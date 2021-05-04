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
        printf(" : %s", s->body);
    }
}

void printCodeLine(TAC* codeLine, int ident){    
    printf(" ── %s %s %s %s %s", codeLine->func, codeLine->dest, codeLine->arg1, codeLine->arg2, codeLine->label);
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
    getTreeArgs(root->nxt, ans);

    if(root->type != -1){
        TreeNode* paramNode;
        TreeNode* latstNode = getLatestNxt(root);
        
        if(latstNode->codeLine && latstNode->codeLine->dest) paramNode = createTACNode(createTAC("param", NULL, latstNode->codeLine->dest, NULL, NULL));
        else if(root->symbol->id != -1) paramNode = createTACNode(createTAC("param", NULL, getRegisterFromId(root->symbol->id), NULL, NULL));
        else paramNode = createTACNode(createTAC("param", NULL, root->codeLine->dest, NULL, NULL));

        getLatestNxt(root)-> nxt = paramNode;
    }
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

void generateTACCode(TreeNode* root){
    if(!root) return;
    fclose(fopen(cExtensionToTACExtension(), "w"));

    FILE *out = fopen(cExtensionToTACExtension(), "a");
    fprintf(out, ".table\n.code\n"); 
    fclose(out);

    generateTACCodeUtil(root);
    
    out = fopen(cExtensionToTACExtension(), "a");
    fprintf(out, "\tnop\n"); 
    fclose(out);
}

TreeNode* createTACNode(TAC *codeLine){
    TreeNode* node = createNode("TAC");
    node->codeLine = codeLine;
    return node;
}

TreeNode* getLatestNxt(TreeNode* curr){
    if(!curr) return curr;
    while(curr->nxt) curr = curr->nxt;
    return curr;
}

void buildIfTAC(TreeNode* root, TreeNode* expression, TreeNode* statements){
    if(!expression->codeLine) return;

    char *freeLabel = getFreeLabel("if", -1);
    char *freeEndLabel = getEndLabel(freeLabel);

    TreeNode* freeLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeLabel));
    TreeNode* freeEndLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeEndLabel));
    TreeNode* brzNode = createTACNode(createTAC("brz", freeEndLabel, expression->codeLine->dest, NULL, NULL));

    freeLabelNode->nxt = root->children;
    root->children = freeLabelNode;

    expression->nxt = brzNode;
    brzNode->nxt = statements;

    freeEndLabelNode->nxt = statements->nxt;
    statements->nxt = freeEndLabelNode;
}

void buildIfElseTAC(TreeNode* root, TreeNode* expression, TreeNode* ifStatements, TreeNode* elseStatements){
    if(!expression->codeLine) return;

    char *freeIfLabel = getFreeLabel("if", -1);
    char *freeElseLabel = getFreeLabel("else", -1);
    char *freeElseEndLabel = getEndLabel(freeElseLabel);
    
    TreeNode* ifLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeIfLabel));
    TreeNode* elseLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeElseLabel));
    TreeNode* elseEndLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeElseEndLabel));

    TreeNode* brzNode = createTACNode(createTAC("brz", freeElseLabel, expression->codeLine->dest, NULL, NULL));
    TreeNode* jumpNode = createTACNode(createTAC("jump", NULL, freeElseEndLabel, NULL, NULL));
    
    ifLabelNode->nxt = root->children;
    root->children = ifLabelNode;

    expression->nxt = brzNode;
    brzNode->nxt = ifStatements;

    ifStatements->nxt = jumpNode;
    jumpNode->nxt = elseLabelNode;
    elseLabelNode->nxt = elseStatements;

    elseEndLabelNode->nxt = elseStatements->nxt;
    elseStatements->nxt = elseEndLabelNode;
}

void buildForTAC(TreeNode* root, TreeNode* forExpression, TreeNode* statement){
    if(!forExpression->children->nxt->codeLine) return;
    
    int forLabelId = getFreeLabelId();
    char *freeForLabel = getFreeLabel("for", forLabelId);
    char *freeForEndLabel = getEndLabel(freeForLabel);
    char *freeForPreCheckLabel = getFreeLabel("for_pre_check", forLabelId);
    char *freeForCheckLabel = getFreeLabel("for_check", forLabelId);
    char *freeForAfterStatementLabel = getFreeLabel("for_after_statement", forLabelId);
    char *freeForStatementLabel = getFreeLabel("for_statement", forLabelId);

    TreeNode* forLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeForLabel));
    TreeNode* forEndLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeForEndLabel));
    TreeNode* forPreCheckLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeForPreCheckLabel));
    TreeNode* forCheckLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeForCheckLabel));
    TreeNode* forAfterStatementLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeForAfterStatementLabel));
    TreeNode* forStatementLabelNode = createTACNode(createTAC(NULL, NULL, NULL, NULL, freeForStatementLabel));

    TreeNode* pre = forExpression->children;
    TreeNode* check = pre->nxt;
    TreeNode* after = check->nxt;

    TreeNode* brzNode = createTACNode(createTAC("brz", freeForEndLabel, check->codeLine->dest, NULL, NULL));
    TreeNode* jumpNodeStatement = createTACNode(createTAC("jump", NULL, freeForStatementLabel, NULL, NULL));
    TreeNode* jumpNodeCheck = createTACNode(createTAC("jump", NULL, freeForCheckLabel, NULL, NULL));
    TreeNode* jumpNodeAfterStatement = createTACNode(createTAC("jump", NULL, freeForAfterStatementLabel, NULL, NULL));

    forLabelNode->nxt = root->children;
    root->children = forLabelNode;

    forExpression->children = forPreCheckLabelNode;
    forPreCheckLabelNode->nxt = pre;

    pre->nxt = forCheckLabelNode;
    forCheckLabelNode->nxt = check;

    check->nxt = brzNode;
    brzNode->nxt = jumpNodeStatement;
    jumpNodeStatement->nxt = forAfterStatementLabelNode;
    forAfterStatementLabelNode->nxt = after;

    after->nxt = jumpNodeCheck;

    forExpression->nxt = forStatementLabelNode;
    forStatementLabelNode->nxt = statement;

    statement->nxt = jumpNodeAfterStatement;
    jumpNodeAfterStatement->nxt = forEndLabelNode;
}
