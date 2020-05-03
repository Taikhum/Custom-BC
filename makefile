custom-bc: lex.yy.c y.tab.c
	gcc -g lex.yy.c y.tab.c -o custom-bc

lex.yy.c: y.tab.c custom-bc.l
	lex custom-bc.l

y.tab.c: custom-bc.y
	yacc -d custom-bc.y

clean:
	rm -rf lex.yy.c y.tab.c y.tab.h custom-bc custom-bc.dSYM

