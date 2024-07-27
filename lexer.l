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

"imprimir"                  { return PRINTFF; }
"ler"                       { return SCANFF; }
"inteiro"                   { return INT; }
"flutuante"                 { return FLOAT; }
"caractere"                 { return CHAR; }
"vazio"                     { return VOID; }
"retornar"                  { return RETURN; }
"se"	                    { return IF; }
"senao"	                    { return ELSE; }
"para"	                    { return FOR; }
^"#incluir"[ ]*<.+\.h>      { return INCLUDE; }
"verdadeiro"                { return TRUE; }
"falso"                     { return FALSE; }
[-]?{digit}+                { return NUMBER; }
[-]?{digit}+\.{digit}{1,4}  { return FLOAT_NUMBER; }
{alpha}({alpha}|{digit})*   { return ID; }
{unary}                     { return UNARY; }
"<="                        { return LE; }
">="                        { return GE; }
"=="                        { return EQ; }
"!="                        { return NE; }
">"	                        { return GT; }
"<"	                        { return LT; }
"&&"	                    { return AND; }
"||"	                    { return OR; }
"+"                         { return ADD; }
"-"                         { return SUBTRACT; }
"*"                         { return MULTIPLY; }
"/"                         { return DIVIDE; }
","                         { return COMMA; }
"["                         { return LBRACKET; }
"]"                         { return RBRACKET; }
"("                         { return LPARENTHESIS; }
")"                         { return RPARENTHESIS; }
\/\/.*                      { ; }
\/\*(.*\n)*.*\*\/           { ; } 
[ \t]*                      { ; }
[\n]                        { countn++; }
.	                        { return *yytext; }
["].*["]                    { return STRING; }
['].[']                     { return CHARACTER; }

%%

int yywrap() {
    return 1;
}