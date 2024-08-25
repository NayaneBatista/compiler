# 💻 Sobre o Compiler

Este projeto foi desenvolvido pela dupla de discentes Nayane Batista e [Yuri Alves](https://github.com/yuripiresalves), ambos do Bacharel em Informática (UEM) ministrados pelo professor Felippe Fernandes. ♥

Trata-se da implementação de um compilador simples capaz de realizar as análises léxica, sintática e semântica em arquivos _.uai_, uma linguagem própria construída em português que se baseia na estrutura da linguagem C.

## 🚧 Principais Funcionalidades

- Impressão da lista de tokens, tabela de símbolos e árvore sintática;
- Suporte a estrutura de decisão (se/senao);
- Suporte a estrutura de repetição (laço para);
- Suporte a operações aritméticas e de lógica relacional;
- Manipulação de vetores;
- Chamada de funções;
- Checagem de tipos e declarações prévias de variáveis.

## 🗣 Tecnologias e Ferramentas

- Lex/Flex
- Yacc/Bison
- _Visual Studio Code_

## 🛠️ Como executar

```bash
lex lexer.l

yacc -v -d parser.y

gcc -w y.tab.c

./a.out<input.uai
```

OU

```bash
make
```
