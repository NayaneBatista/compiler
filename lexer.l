%{
    #include "y.tab.h"
    int countn=0;
    extern int yylineno;
%}

%option yylineno

alpha [a-zA-Z]
digit [0-9]
unary "++"|"--"

%%

"imprimir"                  { strcpy(yylval.nd_obj.name,(yytext)); return PRINTF; }
"ler"                       { strcpy(yylval.nd_obj.name,(yytext)); return SCANF; }
"inteiro"                   { strcpy(yylval.nd_obj.name,(yytext)); return INT; }
"flutuante"                 { strcpy(yylval.nd_obj.name,(yytext)); return FLOAT; }
"caractere"                 { strcpy(yylval.nd_obj.name,(yytext)); return CHAR; }
"vazio"                     { strcpy(yylval.nd_obj.name,(yytext)); return VOID; }
"retornar"                  { strcpy(yylval.nd_obj.name,(yytext)); return RETURN; }
"para"	                    { strcpy(yylval.nd_obj.name,(yytext)); return FOR; }
"se"	                    { strcpy(yylval.nd_obj.name,(yytext)); return IF; }
"senao"	                    { strcpy(yylval.nd_obj.name,(yytext)); return ELSE; }
^"#incluir"[ ]*<.+\.h>      { strcpy(yylval.nd_obj.name,(yytext)); return INCLUDE; }
"verdadeiro"                { strcpy(yylval.nd_obj.name,(yytext)); return TRUE; }
"falso"                     { strcpy(yylval.nd_obj.name,(yytext)); return FALSE; }
[-]?{digit}+                { strcpy(yylval.nd_obj.name,(yytext)); return NUMBER; }
[-]?{digit}+\.{digit}{1,6}  { strcpy(yylval.nd_obj.name,(yytext)); return FLOAT_NUMBER; }
{alpha}({alpha}|{digit})*   { strcpy(yylval.nd_obj.name,(yytext)); return ID; }
{unary}                     { strcpy(yylval.nd_obj.name,(yytext)); return UNARY; }
"<="                        { strcpy(yylval.nd_obj.name,(yytext)); return LE; }
">="                        { strcpy(yylval.nd_obj.name,(yytext)); return GE; }
"=="                        { strcpy(yylval.nd_obj.name,(yytext)); return EQ; }
"!="                        { strcpy(yylval.nd_obj.name,(yytext)); return NE; }
">"	                        { strcpy(yylval.nd_obj.name,(yytext)); return GT; }
"<"	                        { strcpy(yylval.nd_obj.name,(yytext)); return LT; }
"&&"	                    { strcpy(yylval.nd_obj.name,(yytext)); return AND; }
"||"	                    { strcpy(yylval.nd_obj.name,(yytext)); return OR; }
"+"                         { strcpy(yylval.nd_obj.name,(yytext)); return ADD; }
"-"                         { strcpy(yylval.nd_obj.name,(yytext)); return SUBTRACT; }
"/"                         { strcpy(yylval.nd_obj.name,(yytext)); return DIVIDE; }
"*"                         { strcpy(yylval.nd_obj.name,(yytext)); return MULTIPLY; }
\/\/.*                      { ; }
\/\*(.*\n)*.*\*\/           { ; } 
[ \t]*                      { ; }
[\n]                        { countn++; }
.	                        { return *yytext; }
["].*["]                    { strcpy(yylval.nd_obj.name,(yytext)); return STRING; }
['].[']                     { strcpy(yylval.nd_obj.name,(yytext)); return CHARACTER; }

%%

int yywrap() {
    return 1;
}