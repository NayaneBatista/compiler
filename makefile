all:
	lex lexer.l
	yacc -v -d parser.y
	gcc -w y.tab.c
	./a.out<input.uai