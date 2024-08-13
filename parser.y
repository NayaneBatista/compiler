// parser.y
%{
    #include<stdio.h>
    #include<string.h>
    #include<stdlib.h>
    #include<ctype.h>
    #include"lex.yy.c"
    void yyerror(const char *s);
    int yylex();
    int yywrap();
    void add(char);
    void insert_type();
    int search(char *);
    void insert_type();
    void printtree(struct node*);
    void printInorder(struct node *, FILE *);
    struct node* mknode(struct node *left, struct node *right, char *token);

    struct dataType {
        char * id_name;
        char * data_type;
        char * type;
        int line_no;
    } symbolTable[40];
    int count=0;
    int q;
    char type[10];
    extern int countn;
    struct node *head;
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
} 

%token VOID 
%token <nd_obj> CHARACTER PRINTF SCANF INT FLOAT CHAR FOR IF ELSE TRUE FALSE NUMBER FLOAT_NUM ID LE GE EQ NE GT LT AND OR STR ADD MULTIPLY DIVIDE SUBTRACT UNARY INCLUDE RETURN 
%type <nd_obj> headers main body return datatype expression statement init value arithmetic relop program condition else

%%

program: headers main '(' ')' '{' body return '}' { $2.nd = mknode($6.nd, $7.nd, "principal"); $$.nd = mknode($1.nd, $2.nd, "programa"); head = $$.nd; } 
;

headers: INCLUDE { add('H'); } { $$.nd = mknode(NULL, NULL, $1.name); }
| headers INCLUDE { add('H'); } { $2.nd = mknode(NULL, NULL, $2.name); $$.nd = mknode($1.nd, $2.nd, "headers"); } 
;

main: datatype ID { add('K'); }
;

datatype: INT { insert_type(); }
| FLOAT { insert_type(); }
| CHAR { insert_type(); }
| VOID { insert_type(); }
;

body: FOR { add('K'); } '(' statement ';' condition ';' statement ')' '{' body '}' { struct node *temp = mknode($6.nd, $8.nd, "CONDICAO"); struct node *temp2 = mknode($4.nd, temp, "CONDICAO"); $$.nd = mknode(temp2, $11.nd, $1.name); }
| IF { add('K'); } '(' condition ')' '{' body '}' else { struct node *iff = mknode($4.nd, $7.nd, $1.name); 	$$.nd = mknode(iff, $9.nd, "se-senao"); }
| statement ';' { $$.nd = $1.nd; }
| body body { $$.nd = mknode($1.nd, $2.nd, "statements"); }
| PRINTF { add('K'); } '(' STR ')' ';' { $$.nd = mknode(NULL, NULL, "imprimir"); }
| SCANF { add('K'); } '(' STR ',' '&' ID ')' ';' { $$.nd = mknode(NULL, NULL, "ler"); }
;

else: ELSE { add('K'); } '{' body '}' { $$.nd = mknode(NULL, $4.nd, $1.name); }
| { $$.nd = NULL; }
;

condition: value relop value { $$.nd = mknode($1.nd, $3.nd, $2.name); }
| TRUE { add('K'); $$.nd = NULL; }
| FALSE { add('K'); $$.nd = NULL; }
| { $$.nd = NULL; }
;

statement: datatype ID { add('V'); } init { $2.nd = mknode(NULL, NULL, $2.name); $$.nd = mknode($2.nd, $4.nd, "declaracao"); }
| ID '=' expression { $1.nd = mknode(NULL, NULL, $1.name); $$.nd = mknode($1.nd, $3.nd, "="); }
| ID relop expression { $1.nd = mknode(NULL, NULL, $1.name); $$.nd = mknode($1.nd, $3.nd, $2.name); }
| ID UNARY { $1.nd = mknode(NULL, NULL, $1.name); $2.nd = mknode(NULL, NULL, $2.name); $$.nd = mknode($1.nd, $2.nd, "ITERADOR"); }
| UNARY ID { $1.nd = mknode(NULL, NULL, $1.name); $2.nd = mknode(NULL, NULL, $2.name); $$.nd = mknode($1.nd, $2.nd, "ITERADOR"); }
;

init: '=' value { $$.nd = $2.nd; }
| { $$.nd = mknode(NULL, NULL, "NULL"); }
;

expression: expression arithmetic expression { $$.nd = mknode($1.nd, $3.nd, $2.name); }
| value { $$.nd = $1.nd; }
;

arithmetic: ADD 
| SUBTRACT 
| MULTIPLY
| DIVIDE
;

relop: LT
| GT
| LE
| GE
| EQ
| NE
;

value: NUMBER { add('C'); $$.nd = mknode(NULL, NULL, $1.name); }
| FLOAT_NUM { add('C'); $$.nd = mknode(NULL, NULL, $1.name); }
| CHARACTER { add('C'); $$.nd = mknode(NULL, NULL, $1.name); }
| ID { $$.nd = mknode(NULL, NULL, $1.name); }
;

return: RETURN { add('K'); } value ';' { $1.nd = mknode(NULL, NULL, "return"); $$.nd = mknode($1.nd, $3.nd, "RETORNO"); }
| { $$.nd = NULL; }
;

%%

int main() {
    yyparse();

    printf("\n\n");
	printf("\nSIMBOLO			TIPO DO DADO			TIPO			LINHA \n");
	printf("___________________________________________________________________________________________\n\n");

	int i=0;
	for(i=0; i<count; i++) {
		printf("%-20s\t%-20s\t%-20s\t%5d\t\n", symbolTable[i].id_name, symbolTable[i].data_type, symbolTable[i].type, symbolTable[i].line_no + 1);
	}
	for(i=0;i<count;i++){
		free(symbolTable[i].id_name);
		free(symbolTable[i].type);
	}
	printf("\n\n");
	printtree(head); 
	printf("\n\n");
}

int search(char *type) {
	int i;
	for(i=count-1; i>=0; i--) {
		if(strcmp(symbolTable[i].id_name, type)==0) {
			return -1;
			break;
		}
	}
	return 0;
}

void add(char c) {
    q=search(yytext);
	if(q==0) {
		if(c=='H') {
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup(type);
			symbolTable[count].line_no=countn;
			symbolTable[count].type=strdup("Header");
			count++;
		}
		else if(c=='K') {
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("N/A");
			symbolTable[count].line_no=countn;
			symbolTable[count].type=strdup("Palavra-chave\t");
			count++;
		}
		else if(c=='V') {
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup(type);
			symbolTable[count].line_no=countn;
			symbolTable[count].type=strdup("Variável");
			count++;
		}
		else if(c=='C') {
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("CONST");
			symbolTable[count].line_no=countn;
			symbolTable[count].type=strdup("Constante");
			count++;
		}
    }
}

struct node* mknode(struct node *left, struct node *right, char *token) {	
	struct node *newnode = (struct node *)malloc(sizeof(struct node));
	char *newstr = (char *)malloc(strlen(token)+1);
	strcpy(newstr, token);
	newnode->left = left;
	newnode->right = right;
	newnode->token = newstr;
	return(newnode);
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
  fprintf(stderr, "\nErro na linha %d: %s\n", yylineno, s);
  exit(1);
}