all: compiler

parse.tab.c parse.tab.h: parse.y
	bison -d parse.y

lex.yy.c: lex.l parse.tab.h
	flex lex.l

compiler: lex.yy.c parse.tab.c parse.tab.h
	gcc -o compiler parse.tab.c lex.yy.c -lfl
