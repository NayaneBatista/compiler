%{
    #include "y.tab.h"
    int countn=0;
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
"para"	                    { return FOR; }
"se"	                    { return IF; }
"senao"	                    { return ELSE; }
^"#incluir"[ ]*<.+\.h>      { return INCLUDE; }
"verdadeiro"                { return TRUE; }
"falso"                     { return FALSE; }
[-]?{digit}+                { return NUMBER; }
[-]?{digit}+\.{digit}{1,6}  { return FLOAT_NUM; }
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
"/"                         { return DIVIDE; }
"*"                         { return MULTIPLY; }
\/\/.*                      { ; }
\/\*(.*\n)*.*\*\/           { ; } 
[ \t]*                      { ; }
[\n]                        { countn++; }
.	                        { return *yytext; }
["].*["]                    { return STR; }
['].[']                     { return CHARACTER; }

%%

int yywrap() {
    return 1;
}