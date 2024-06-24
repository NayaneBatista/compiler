%{
    #include "y.tab.h"
    int line_count = 0;
%}

%option yylineno

alpha [a-zA-Z]
digit [0-9]
unary "++"|"--"

%%

"printf"                        { return PRINTFF; }
"scanf"                         { return SCANFF; }
"int"                           { return INT; }
"float"                         { return FLOAT; }
"char"                          { return CHAR; }
"void"                          { return VOID; }
"return"                        { return RETURN; }
"for"	                        { return FOR; }
"if"	                        { return IF; }
"else"	                        { return ELSE; }
"switch"	                    { return SWITCH; }
"case"	                        { return CASE; }
"break"	                        { return BREAK; }
^"#include"[ ]*<.+\.h>          { return INCLUDE; }
"true"                          { return TRUE; }
"false"                         { return FALSE; }
[-]?{digit}+                    { return NUMBER; }
[-]?{digit}+\.{digit}{1,6}      { return FLOAT_NUMBER; }
{alpha}({alpha}|{digit})*       { return ID; }
{unary}                         { return UNARY; }
"<="                            { return LE; }
">="                            { return GE; }
"=="                            { return EQ; }
"!="                            { return NE; }
">"	                            { return GT; }
"<"	                            { return LT; }
"="	                            { return ASSIGN; }
"&&"	                        { return AND; }
"||"	                        { return OR; }
"+"                             { return ADD; }
"-"                             { return SUB; }
"/"                             { return DIVIDE; }
"*"                             { return MULTIPLY; }
\/\/.*                          { ; }
\/\*(.*\n)*.*\*\/               { ; }
[ \t]*                          { ; }
[\n]                            { line_count++; }
.	                            { return *yytext; }
["].*["]                        { return STR; }
['].[']                         { return CHARACTER; }

%%

int yywrap() {
    return 1;
}
