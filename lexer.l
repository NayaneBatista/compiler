%{
    #include "y.tab.h"
    int countn=0;
    extern int yylineno;

    void print_token(const char* token_name, const char* token_value) {
        printf("Token: %s\tValor: %s\n", token_name, token_value);
    }
%}

%option yylineno

alpha [a-zA-Z]
digit [0-9]
unary "++"|"--"

%%

"imprimir"                  { print_token("PRINTF", yytext); strcpy(yylval.nd_obj.name,(yytext)); return PRINTF; }
"ler"                       { print_token("SCANF", yytext); strcpy(yylval.nd_obj.name,(yytext)); return SCANF; }
"inteiro"                   { print_token("INT", yytext); strcpy(yylval.nd_obj.name,(yytext)); return INT; }
"flutuante"                 { print_token("FLOAT", yytext); strcpy(yylval.nd_obj.name,(yytext)); return FLOAT; }
"caractere"                 { print_token("CHAR", yytext); strcpy(yylval.nd_obj.name,(yytext)); return CHAR; }
"vazio"                     { print_token("VOID", yytext); strcpy(yylval.nd_obj.name,(yytext)); return VOID; }
"retornar"                  { print_token("RETURN", yytext); strcpy(yylval.nd_obj.name,(yytext)); return RETURN; }
"para"	                    { print_token("FOR", yytext); strcpy(yylval.nd_obj.name,(yytext)); return FOR; }
"se"	                    { print_token("IF", yytext); strcpy(yylval.nd_obj.name,(yytext)); return IF; }
"senao"	                    { print_token("ELSE", yytext); strcpy(yylval.nd_obj.name,(yytext)); return ELSE; }
^"#incluir"[ ]*<.+\.h>      { print_token("INCLUDE", yytext); strcpy(yylval.nd_obj.name,(yytext)); return INCLUDE; }
"verdadeiro"                { print_token("TRUE", yytext); strcpy(yylval.nd_obj.name,(yytext)); return TRUE; }
"falso"                     { print_token("FALSE", yytext); strcpy(yylval.nd_obj.name,(yytext)); return FALSE; }
[-]?{digit}+                { print_token("NUMBER", yytext); strcpy(yylval.nd_obj.name,(yytext)); return NUMBER; }
[-]?{digit}+\.{digit}{1,6}  { print_token("FLOAT_NUMBER", yytext); strcpy(yylval.nd_obj.name,(yytext)); return FLOAT_NUMBER; }
{alpha}({alpha}|{digit})*   { print_token("ID", yytext); strcpy(yylval.nd_obj.name,(yytext)); return ID; }
{unary}                     { print_token("UNARY", yytext); strcpy(yylval.nd_obj.name,(yytext)); return UNARY; }
"<="                        { print_token("LE", yytext); strcpy(yylval.nd_obj.name,(yytext)); return LE; }
">="                        { print_token("GE", yytext); strcpy(yylval.nd_obj.name,(yytext)); return GE; }
"=="                        { print_token("EQ", yytext); strcpy(yylval.nd_obj.name,(yytext)); return EQ; }
"!="                        { print_token("NE", yytext); strcpy(yylval.nd_obj.name,(yytext)); return NE; }
">"	                        { print_token("GT", yytext); strcpy(yylval.nd_obj.name,(yytext)); return GT; }
"<"	                        { print_token("LT", yytext); strcpy(yylval.nd_obj.name,(yytext)); return LT; }
"+"                         { print_token("ADD", yytext); strcpy(yylval.nd_obj.name,(yytext)); return ADD; }
"-"                         { print_token("SUBTRACT", yytext); strcpy(yylval.nd_obj.name,(yytext)); return SUBTRACT; }
"/"                         { print_token("DIVIDE", yytext); strcpy(yylval.nd_obj.name,(yytext)); return DIVIDE; }
"*"                         { print_token("MULTIPLY", yytext); strcpy(yylval.nd_obj.name,(yytext)); return MULTIPLY; }
\/\/.*                      { ; }
\/\*(.*\n)*.*\*\/           { ; } 
[ \t]*                      { ; }
[\n]                        { countn++; }
.	                        { print_token("SYMBOL", yytext); return *yytext; }
["].*["]                    { print_token("STRING", yytext); strcpy(yylval.nd_obj.name,(yytext)); return STRING; }
['].[']                     { print_token("CHARACTER", yytext); strcpy(yylval.nd_obj.name,(yytext)); return CHARACTER; }

%%

int yywrap() {
    return 1;
}