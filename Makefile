





mycomp: myanalyzer.tab.c lex.yy.c
	gcc -o mycompiler lex.yy.c myanalyzer.tab.c cgen.c -lfl

myanalyzer.tab.c: 
	bison -d -v -r all myanalyzer.y

lex.yy.c:
	flex mylexer.l

clean: 
	rm 	myanalyzer.tab.c 
	rm 	myanalyzer.tab.h 
	rm  myanalyzer.output
	rm  mycompiler 
	rm lex.yy.c



	
       