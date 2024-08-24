%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <ctype.h>
    #include "lex.yy.c"

    void yyerror(const char *s);
    int yylex();
    void insert_type();
    int search(char *);
    void insert_type();
    void printtree(struct node*);
    void printInorder(struct node *, FILE *);
    void check_declaration(char *);
    void check_return_type(char *);
    int check_types(char *, char *);
    char *get_type(char *);
    int check_data_type(struct node *node);

    struct node* mknode(struct node *left, struct node *right, char *token);

    struct dataType {
        char *id_name;
        char *data_type;
        char *type;
        int line_no;
    } symbolTable[40];

    int count = 0;
    int q;
    char type[10];
    extern int countn;
    struct node *head;
    int sem_errors = 0;
    int label = 0;

    char buff[100];
    char errors[10][100];
    char reserved[10][10] = {
        "inteiro", "flutuante", "caractere", "vazio", "se", "senao", "para", "principal", "retorno", "incluir"
    };

    struct node {
        struct node *left;
        struct node *right;
        char *token;
    };
%}

%union {
    struct var_name {
        char name[100];
        struct node* nd;
    } nd_obj;

    struct var_name2 {
        char name[100];
        struct node* nd;
        char type[5];
    } nd_obj2;
}

%token VOID
%token <nd_obj> CHARACTER MAIN PRINTF SCANF INT FLOAT CHAR FOR IF ELSE TRUE FALSE NUMBER FLOAT_NUMBER ID LE GE EQ NE GT LT STRING ADD MULTIPLY DIVIDE SUBTRACT UNARY INCLUDE RETURN
%type <nd_obj> headers main body return datatype statement arithmetic relop program condition else array_declaration main_declaration function_name function_list function_declaration function_call parameter_list arguments_list
%type <nd_obj2> init value expression

%%

program:
    headers function_list {
        $$.nd = mknode($1.nd, $2.nd, "program");
        head = $$.nd;
    }
;

headers:
    INCLUDE {
        add('H', $1.name, "header", countn);
        $$.nd = mknode(NULL, NULL, $1.name);
    }
    | headers INCLUDE {
        add('H', $2.name, "header", countn);
        $2.nd = mknode(NULL, NULL, $2.name);
        $$.nd = mknode($1.nd, $2.nd, "headers");
    }
    | {
        $$.nd = NULL;
    }
;

main:
    main_declaration '{' body return '}' {
        $$.nd = mknode($1.nd, $3.nd, "principal");
    }
;

main_declaration: 
    datatype MAIN '(' ')' {
        add('F', "principal", $1.name, countn);
    }

function_list:
    function_declaration {
        $$.nd = $1.nd;
    }
    | function_list function_declaration {
        $$.nd = mknode($1.nd, $2.nd, "function_list");
    }

function_declaration:
    function_name '{' body return '}' {
        $$.nd = mknode($1.nd, $3.nd, "function_declaration");
    }
    | main {
        $$.nd = $1.nd;
    }
;

function_name:
    datatype ID '(' parameter_list ')' {
        add('F', $2.name, $1.name, countn);
        $$.nd = mknode($1.nd, $4.nd, $2.name);
    }
;

parameter_list:
     datatype ID {
        add('V', $2.name, $1.name, countn);
    }
    | parameter_list ',' datatype ID {
        add('V', $4.name, $3.name, countn);
    }
    | {
        $$.nd = NULL;
    }
;

function_call:
    ID '(' ')' {
        check_declaration($1.name);
        $$.nd = mknode(NULL, NULL, $1.name);
    }
    | ID '(' arguments_list ')' {
        check_declaration($1.name);
        $$.nd = mknode(NULL, $3.nd, $1.name);
    }
;

arguments_list:
    value {
        $$.nd = mknode(NULL, NULL, $1.name);
    }
    | arguments_list ',' value {
        $$.nd = mknode($1.nd, $3.nd, "arguments_list");
    }
    | {
        $$.nd = NULL;
    }
;

datatype:
    INT {
        insert_type();
    }
    | FLOAT {
        insert_type();
    }
    | CHAR {
        insert_type();
    }
    | VOID {
        insert_type();
    }
;

body:
    FOR {
        add('K', $1.name, "Keyword", countn);
        // printf("FORRRRRRRRRRRRRRRRRR %s\n", $1.name);
    } '(' statement ';' condition ';' statement ')' '{' body '}' {
        struct node *temp = mknode($6.nd, $8.nd, "CONDICAO");
        struct node *temp2 = mknode($4.nd, temp, "CONDICAO");
        $$.nd = mknode(temp2, $11.nd, $1.name);
    }
    | IF {
        add('K', $1.name, "Keyword", countn);
    } '(' condition ')' '{' body '}' else {
        struct node *iff = mknode($4.nd, $7.nd, $1.name);
        $$.nd = mknode(iff, $9.nd, "se-senao");
    }
    /* | function_declaration {
        $$.nd = $1.nd;
    }
    | array_declaration {
        $$.nd = $1.nd;
    } */
    | function_call ';' {
        $$.nd = $1.nd;
    }
    | statement ';' {
        $$.nd = $1.nd;
    }
    | body body {
        $$.nd = mknode($1.nd, $2.nd, "statements");
    }
    | PRINTF {
        add('K', $1.name, "Keyword", countn);
    } '(' STRING ')' ';' {
        $$.nd = mknode(NULL, NULL, "imprimir");
    }
    | SCANF {
        add('K', $1.name, "Keyword", countn);
    } '(' STRING ',' '&' ID ')' ';' {
        $$.nd = mknode(NULL, NULL, "ler");
    }
;

else:
    ELSE {
        add('K', $1.name, "Keyword", countn);
    } '{' body '}' {
        $$.nd = mknode(NULL, $4.nd, $1.name);
    }
    | {
        $$.nd = NULL;
    }
;

condition:
    value relop value {
        $$.nd = mknode($1.nd, $3.nd, $2.name);
    }
    | TRUE {
        add('K', $1.name, "Keyword", countn);
        $$.nd = NULL;
    }
    | FALSE {
        add('K', $1.name, "Keyword", countn);
        $$.nd = NULL;
    }
    | {
        $$.nd = NULL;
    }
;

array_declaration:
    datatype ID '[' NUMBER ']' { 
        add('Y', $2.name, $1.name, countn);
        $1.nd = mknode(NULL, NULL, $1.name);
        $$.nd = mknode($1.nd, $2.nd, "array_declaration"); 
    }
;

statement:
    datatype ID {
        add('V', $2.name, $1.name, countn);

    } init {
        $2.nd = mknode(NULL, NULL, $2.name);

        int t = check_types($1.name, $4.type);

        if (t > 0) {
            if (t == 1) {
                struct node *temp = mknode(NULL, $4.nd, "floattoint");
                $$.nd = mknode($2.nd, temp, "declaration");
            }
            else if (t == 2) {
                struct node *temp = mknode(NULL, $4.nd, "inttofloat");
                $$.nd = mknode($2.nd, temp, "declaration");
            }
            else if (t == 3) {
                struct node *temp = mknode(NULL, $4.nd, "chartoint");
                $$.nd = mknode($2.nd, temp, "declaration");
            }
            else if (t == 4) {
                struct node *temp = mknode(NULL, $4.nd, "inttochar");
                $$.nd = mknode($2.nd, temp, "declaration");
            }
            else if (t == 5) {
                struct node *temp = mknode(NULL, $4.nd, "chartofloat");
                $$.nd = mknode($2.nd, temp, "declaration");
            }
            else {
                struct node *temp = mknode(NULL, $4.nd, "floattochar");
                $$.nd = mknode($2.nd, temp, "declaration");
            }
        }
        else {
            $$.nd = mknode($2.nd, $4.nd, "declaration");
        }
    }
    | array_declaration init {
        $2.nd = mknode(NULL, NULL, $2.name);
        int t = check_types($1.name, $2.type);

        if (t > 0) {
            if (t == 1) {
                struct node *temp = mknode(NULL, $2.nd, "floattoint");
                $$.nd = mknode($2.nd, temp, "declaration");
            }
            else if (t == 2) {
                struct node *temp = mknode(NULL, $2.nd, "inttofloat");
                $$.nd = mknode($2.nd, temp, "declaration");
            }
            else if (t == 3) {
                struct node *temp = mknode(NULL, $2.nd, "chartoint");
                $$.nd = mknode($2.nd, temp, "declaration");
            }
            else if (t == 4) {
                struct node *temp = mknode(NULL, $2.nd, "inttochar");
                $$.nd = mknode($2.nd, temp, "declaration");
            }
            else if (t == 5) {
                struct node *temp = mknode(NULL, $2.nd, "chartofloat");
                $$.nd = mknode($2.nd, temp, "declaration");
            }
            else {
                struct node *temp = mknode(NULL, $2.nd, "floattochar");
                $$.nd = mknode($2.nd, temp, "declaration");
            }
        }
        else {
            $$.nd = mknode($2.nd, $2.nd, "declaration");
        }
    }
    | ID {
        check_declaration($1.name);
    } '=' expression {
        $1.nd = mknode(NULL, NULL, $1.name);
        char *id_type = get_type($1.name);

        if (strcmp(id_type, $4.type)) {
            if (!strcmp(id_type, "int")) {
                if (!strcmp($4.type, "float")) {
                    struct node *temp = mknode(NULL, $4.nd, "floattoint");
                    $$.nd = mknode($1.nd, temp, "=");
                }
                else {
                    struct node *temp = mknode(NULL, $4.nd, "chartoint");
                    $$.nd = mknode($1.nd, temp, "=");
                }
            }
            else if (!strcmp(id_type, "float")) {
                if (!strcmp($4.type, "int")) {
                    struct node *temp = mknode(NULL, $4.nd, "inttofloat");
                    $$.nd = mknode($1.nd, temp, "=");
                }
                else {
                    struct node *temp = mknode(NULL, $4.nd, "chartofloat");
                    $$.nd = mknode($1.nd, temp, "=");
                }
            }
            else {
                if (!strcmp($4.type, "int")) {
                    struct node *temp = mknode(NULL, $4.nd, "inttochar");
                    $$.nd = mknode($1.nd, temp, "=");
                }
                else {
                    struct node *temp = mknode(NULL, $4.nd, "floattochar");
                    $$.nd = mknode($1.nd, temp, "=");
                }
            }
        }
        else {
            $$.nd = mknode($1.nd, $4.nd, "=");
        }
    }
    | ID {
        check_declaration($1.name);
    } relop expression {
        $1.nd = mknode(NULL, NULL, $1.name);
        $$.nd = mknode($1.nd, $4.nd, $3.name);
    }
    | ID {
        check_declaration($1.name);
    } UNARY {
        $1.nd = mknode(NULL, NULL, $1.name);
        $3.nd = mknode(NULL, NULL, $3.name);
        $$.nd = mknode($1.nd, $3.nd, "ITERATOR");
    }
    | UNARY ID {
        check_declaration($2.name);
        $1.nd = mknode(NULL, NULL, $1.name);
        $2.nd = mknode(NULL, NULL, $2.name);
        $$.nd = mknode($1.nd, $2.nd, "ITERATOR");
    }
;

init:
    '=' value {
        $$.nd = $2.nd;
        sprintf($$.type, $2.type);
        strcpy($$.name, $2.name);
    }
    | {
        sprintf($$.type, "null");
        $$.nd = mknode(NULL, NULL, "NULL");
        strcpy($$.name, "NULL");
    }
;

expression:
    expression arithmetic expression {
        if (!strcmp($1.type, $3.type)) {
            sprintf($$.type, $1.type);
            $$.nd = mknode($1.nd, $3.nd, $2.name);
        }
        else {
            if (!strcmp($1.type, "int") && !strcmp($3.type, "float")) {
                struct node *temp = mknode(NULL, $1.nd, "inttofloat");
                sprintf($$.type, $3.type);
                $$.nd = mknode(temp, $3.nd, $2.name);
            }
            else if (!strcmp($1.type, "float") && !strcmp($3.type, "int")) {
                struct node *temp = mknode(NULL, $3.nd, "inttofloat");
                sprintf($$.type, $1.type);
                $$.nd = mknode($1.nd, temp, $2.name);
            }
            else if (!strcmp($1.type, "int") && !strcmp($3.type, "char")) {
                struct node *temp = mknode(NULL, $3.nd, "chartoint");
                sprintf($$.type, $1.type);
                $$.nd = mknode($1.nd, temp, $2.name);
            }
            else if (!strcmp($1.type, "char") && !strcmp($3.type, "int")) {
                struct node *temp = mknode(NULL, $1.nd, "chartoint");
                sprintf($$.type, $3.type);
                $$.nd = mknode(temp, $3.nd, $2.name);
            }
            else if (!strcmp($1.type, "float") && !strcmp($3.type, "char")) {
                struct node *temp = mknode(NULL, $3.nd, "chartofloat");
                sprintf($$.type, $1.type);
                $$.nd = mknode($1.nd, temp, $2.name);
            }
            else {
                struct node *temp = mknode(NULL, $1.nd, "chartofloat");
                sprintf($$.type, $3.type);
                $$.nd = mknode(temp, $3.nd, $2.name);
            }
        }
    }
    | value {
        strcpy($$.name, $1.name);
        sprintf($$.type, $1.type);
        $$.nd = $1.nd;
    }
;

arithmetic:
    ADD
    | SUBTRACT
    | MULTIPLY
    | DIVIDE
;

relop:
    LT
    | GT
    | LE
    | GE
    | EQ
    | NE
;

value:
    NUMBER {
        strcpy($$.name, $1.name);
        sprintf($$.type, "inteiro");
        add('C', $1.name, "CONST", countn);
        $$.nd = mknode(NULL, NULL, $1.name);
    }
    | FLOAT_NUMBER {
        strcpy($$.name, $1.name);
        sprintf($$.type, "flutuante");
        add('C', $1.name, "CONST", countn);
        $$.nd = mknode(NULL, NULL, $1.name);
    }
    | CHARACTER {
        strcpy($$.name, $1.name);
        sprintf($$.type, "caractere");
        add('C', $1.name, "CONST", countn);
        $$.nd = mknode(NULL, NULL, $1.name);
    }
    | ID {
        strcpy($$.name, $1.name);
        char *id_type = get_type($1.name);
        sprintf($$.type, id_type);
        check_declaration($1.name);
        $$.nd = mknode(NULL, NULL, $1.name);
    }
    | ID '[' expression ']' {
        check_declaration($1.name);
        $$.nd = mknode($1.nd, $3.nd, "array_access"); 
    }
;

return:
    RETURN {
        add('K', $1.name, "Keyword", countn);
    } value ';' {
        check_return_type($3.name);
        $1.nd = mknode(NULL, NULL, "return");
        $$.nd = mknode($1.nd, $3.nd, "RETORNO");
    }
    | {
        $$.nd = NULL;
    }
;

%%

int main() {
    yyparse();

    printf("\n\n");
    printf("\nSIMBOLO\t\t\tTIPO DO DADO\t\tCATEGORIA\t\tLINHA\n");
    printf("___________________________________________________________________________________________\n\n");

    int i = 0;
    for (i = 0; i < count; i++) {
        printf("%-20s\t%-20s\t%-20s\t%5d\t\n",
               symbolTable[i].id_name, symbolTable[i].data_type,
               symbolTable[i].type, symbolTable[i].line_no + 1);
    }
    for (i = 0; i < count; i++) {
        free(symbolTable[i].id_name);
        free(symbolTable[i].type);
    }
    printf("\n\n");
    printtree(head);
    if (sem_errors > 0) {
        printf("Analise semantica completa com %d erros\n", sem_errors);
        for (int i = 0; i < sem_errors; i++) {
            printf("\t - %s", errors[i]);
        }
    } else {
        printf("Analise semantica completa sem erros");
    }
    printf("\n\n");
}

int search(char *type) {
    int i;
    for (i = count - 1; i >= 0; i--) {
        if (strcmp(symbolTable[i].id_name, type) == 0) {
            return -1;
        }
    }
    return 0;
}

void check_declaration(char *c) {
    q = search(c);
    if (!q) {
        sprintf(errors[sem_errors], "Linha %d: Variavel \"%s\" nao declarada antes do uso!\n", countn + 1, c);
        sem_errors++;
    }
}

void check_return_type(char *value) {
    char *main_datatype = get_type("principal");
    char *return_datatype = get_type(value);


    if (strcmp(main_datatype, "desconhecido") == 0 || 
        strcmp(return_datatype, "desconhecido") == 0) {
        sprintf(errors[sem_errors], "Linha %d: Tipo de retorno ou tipo de função principal não encontrado\n", countn + 1);
        sem_errors++;
        return;
    }

    if ((strcmp(main_datatype, "inteiro") == 0 && strcmp(return_datatype, "CONST") == 0) || 
        strcmp(main_datatype, return_datatype) == 0) {
        return;
    } else {
        sprintf(errors[sem_errors], "Linha %d: Tipos de retorno incompatíveis\n", countn + 1);
        sem_errors++;
    }
}

int check_data_type(struct node *node) {
    char *datatype = node->token; 

    if (strcmp(datatype, "int") == 0 ||
        strcmp(datatype, "float") == 0 ||
        strcmp(datatype, "char") == 0 ||
        strcmp(datatype, "void") == 0) {
        return 1;
    } else {
        return 0;
    }
}

int check_types(char *type1, char *type2) {
    if (!strcmp(type2, "null")) {
        return -1;
    }

    if (!strcmp(type1, type2)) {
        return 0;
    }

    if (!strcmp(type1, "int") && !strcmp(type2, "float")) {
        return 1;
    }
    if (!strcmp(type1, "float") && !strcmp(type2, "int")) {
        return 2;
    }
    if (!strcmp(type1, "int") && !strcmp(type2, "char")) {
        return 3;
    }
    if (!strcmp(type1, "char") && !strcmp(type2, "int")) {
        return 4;
    }
    if (!strcmp(type1, "float") && !strcmp(type2, "char")) {
        return 5;
    }
    if (!strcmp(type1, "char") && !strcmp(type2, "float")) {
        return 6;
    }

    if (type2 == NULL) {

        if (strcmp(type1, "int") == 0 || 
            strcmp(type1, "float") == 0 ||
            strcmp(type1, "char") == 0 ||
            strcmp(type1, "void") == 0) {
            return 1;
        } else {
            return 0;
        }
    }
}

char *get_type(char *var) {
    for (int i = 0; i < count; i++) {
        if (!strcmp(symbolTable[i].id_name, var)) {
            return symbolTable[i].data_type;
        }
    }

    return "desconhecido";
}

void add(char c, char *nome, char *tipo, int linha) {
    if (c == 'V') {
        for (int i = 0; i < 10; i++) {
            if (!strcmp(reserved[i], strdup(yytext))) {
                sprintf(errors[sem_errors], "Linha %d: Nome da variavel \"%s\" eh uma palavra reservada!\n", linha + 1, nome);
                sem_errors++;
                return;
            }
        }
    }

    q = search(yytext);
    if (q == 0) {
        if (c == 'H') {
            symbolTable[count].id_name = strdup(nome);
            symbolTable[count].data_type = strdup(tipo);
            symbolTable[count].line_no = linha;
            symbolTable[count].type = strdup("Header");
            count++;
        } else if (c == 'K') {
            symbolTable[count].id_name = strdup(nome);
            symbolTable[count].data_type = strdup("N/A");
            symbolTable[count].line_no = linha;
            symbolTable[count].type = strdup("Palavra-chave");
            count++;
        } else if (c == 'V') {
            symbolTable[count].id_name = strdup(nome);
            symbolTable[count].data_type = strdup(tipo);
            symbolTable[count].line_no = linha;
            symbolTable[count].type = strdup("Variável");
            count++;
        } else if (c == 'C') {
            symbolTable[count].id_name = strdup(nome);
            symbolTable[count].data_type = strdup(tipo);
            symbolTable[count].line_no = linha;
            symbolTable[count].type = strdup("Constante");
            count++;
        } else if (c == 'F') {
            symbolTable[count].id_name = strdup(nome);
            symbolTable[count].data_type = strdup(tipo);
            symbolTable[count].line_no = linha;
            symbolTable[count].type = strdup("Function");
            count++;
        } else if (c == 'Y') {
            symbolTable[count].id_name = strdup(nome);
            symbolTable[count].data_type = strdup(tipo);
            symbolTable[count].line_no = linha;
            symbolTable[count].type = strdup("Array");
            count++;
        }
    }
}

struct node* mknode(struct node *left, struct node *right, char *token) {
    struct node *newnode = (struct node *)malloc(sizeof(struct node));
    char *newstring = (char *)malloc(strlen(token) + 1);
    strcpy(newstring, token);
    newnode->left = left;
    newnode->right = right;
    newnode->token = newstring;
    return newnode;
}

void printInorder(struct node *tree, FILE *file) {
    if (tree == NULL) {
        fprintf(file, "null");
        return;
    }

    fprintf(file, "{\n");
    fprintf(file, "  \"token\": \"%s\",\n", tree->token);
    fprintf(file, "  \"left\": ");
    printInorder(tree->left, file);
    fprintf(file, ",\n");
    fprintf(file, "  \"right\": ");
    printInorder(tree->right, file);
    fprintf(file, "\n}");
}

void printtree(struct node* tree) {
    FILE *file = fopen("arvore_sintatica.json", "w");
    if (file == NULL) {
        fprintf(stderr, "Erro ao abrir o arquivo!\n");
        return;
    }

    printInorder(tree, file);
    fprintf(file, "\n");

    fclose(file);
    printf("Abstract Syntax Tree salva em 'arvore_sintatica.json'.\n");
}

void insert_type() {
    strcpy(type, yytext);
}

void yyerror(const char *s) {
    report_error(s, "Erro de sintaxe");
    fprintf(stderr, "Erro! %s (linha %d)\n", s, yylineno);
    exit(1);
}

void report_error(const char *type, const char *msg) {
    fprintf(stderr, "Erro! %s (linha %d): %s\n", type, yylineno, msg); 
}