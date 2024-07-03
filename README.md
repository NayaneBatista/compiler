## Para executar

yacc -v -d parser.y
lex lexer.l
gcc y.tab.c
./a.out<input.uai