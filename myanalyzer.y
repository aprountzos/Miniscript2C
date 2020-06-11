%{
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>		
#include "cgen.h"

extern int yylex(void);
extern int line_num;
%}

%union
{	
	char* crepr;
	
}


%token <crepr> TK_IDENT
%token <crepr> TK_NUMBER 
%token <crepr> TK_STRING
%token <crepr> TK_POSINT



%token KW_START
%token KW_CONST
%token KW_VAR
%token KW_VOID
%token KW_NUMBER
%token KW_STRING
%token KW_FUNCTION

%token TK_ASSIGN

%token  KW_BOOLEAN 
%token  KW_TRUE 
%token  KW_FALSE 
%token  KW_IF 
%token  KW_ELSE 
%token  KW_FOR 
%token  KW_WHILE 
%token  KW_BREAK 
%token  KW_CONTINUE 
%token  KW_NOT 
%token  KW_AND 
%token  KW_OR 
%token  KW_RETURN 
%token  KW_NULL 

  
%token  TK_POW 
%token  TK_EQUAL 
%token  TK_DIF 
%token  TK_EQLESS 

%token  KW_READ_STRING 
%token  KW_READ_NUMBER 
%token 	KW_WRITE_STRING 
%token  KW_WRITE_NUMBER 
 




%start program

%type <crepr>  expr array
%type <crepr> command forstate whilestate basic_assign if_body
%type <crepr> const_decl const_decl_list const_decl_list_item const_decl_list_item_id type_spec decl
%type <crepr> var_decl var_decl_list var_decl_list_item var_decl_list_item_id
%type <crepr> decl_list  args  statement statements 
%type <crepr> ifstate  simple_func_call body decls 
%type <crepr> opt_func parames param opt_funcs start_func  statement_list
%type <crepr>  elif 




%left KW_OR
%left KW_AND
%left TK_EQLESS TK_EQUAL TK_DIF '<'
%left '+' '-'
%left '*' '/' '%'
%right TK_POW
%right UMINUS UPLUS
%right KW_NOT




%%


program: decl_list opt_funcs  start_func{

/* We have a successful parse! 
  Check for any errors and generate output. 
*/
	if (yyerror_count == 0) {
    // include the mslib.h file
	  puts(c_prologue); 
	  printf("/* program */ \n\n");
	  printf("%s", $1);
	  printf("%s", $2);
	  printf("%s", $3);
	}
}
;
start_func:
	KW_FUNCTION KW_START '('')' ':' KW_VOID  body   { $$ = template("int main()%s", $7); }
;

opt_funcs:
	%empty { $$ = "";}
	|opt_funcs opt_func  { $$ = template("%s\n%s", $1,$2); }
;
opt_func:
	KW_FUNCTION TK_IDENT '(' parames ')' ':' type_spec  body  { $$ = template("%s %s(%s)%s",$7,$2,$4,$8);}
	|KW_FUNCTION TK_IDENT '(' parames ')' ':' '[' ']' type_spec  body   { $$ = template("%s *%s(%s)%s",$9,$2,$4,$10);}
	
;
parames:
	%empty { $$ = "";}
	|param { $$ = template("%s", $1); }
	|parames ',' param  { $$ = template("%s , %s", $1,$3); }
;
param:
	TK_IDENT ':' type_spec { $$ = template("%s %s", $3,$1); }
	|TK_IDENT'['']' ':' type_spec { $$ = template("%s *%s", $5,$1); }
;


body:
	'{' statements '}' { $$ = template("{\n%s}\n", $2); }
;

expr:
	 expr KW_OR expr 			{ $$ = template("%s || %s", $1, $3);}
	|expr KW_AND expr 			{ $$ = template("%s && %s", $1, $3);}
	|expr TK_EQLESS expr 		{ $$ = template("%s <= %s", $1, $3);}
	|expr '<' expr 				{ $$ = template("%s < %s", $1, $3);}
	|expr TK_DIF expr 			{ $$ = template("%s != %s", $1, $3);}
	|expr TK_EQUAL expr			{ $$ = template("%s == %s", $1, $3);}
	|expr '-' expr 				{ $$ = template("%s - %s", $1, $3);}
	|expr '+' expr				{ $$ = template("%s + %s", $1, $3);}
	|expr '%' expr				{ $$ = template("%s %% %s", $1, $3);}
	|expr '/' expr				{ $$ = template("%s / %s", $1, $3);}
	|expr '*' expr				{ $$ = template("%s * %s", $1, $3);}
	|expr TK_POW expr			{ $$ = template("pow(%s,%s)", $1,$3);}
	|'+' expr %prec	UPLUS		{ $$ = template("+(%s)", $2);}
	|'-' expr %prec	UMINUS		{ $$ = template("-(%s)", $2);}
	|KW_NOT expr			    { $$ = template("!(%s)", $2);}
	|'(' expr ')'				{ $$ = template("(%s)", $2);}
	|TK_NUMBER 					{$$ = template("%s",$1);}
	|TK_POSINT	                {$$ = template("%s",$1);}
	|TK_IDENT 					{$$ = template("%s",$1);}
	|TK_STRING					{$$ = template("%s",$1);}
	|KW_TRUE					{$$ = template("%s","1");}
	|KW_FALSE					{$$ = template("%s","0");}
	|array						{ $$ = template("%s", $1); }
	|simple_func_call			{ $$ = template("%s", $1); }
	
	

;
array:
	TK_IDENT '[' expr ']' {$$ = template("%s[%s]",$1,$3);}
;

command:
	basic_assign ';' { $$ = template("%s;\n",$1); }
	|array TK_ASSIGN expr ';' { $$ = template("%s = %s;\n", $1,$3); }
	|KW_RETURN ';'{$$=template("return;\n");}
	|KW_RETURN expr ';'{$$=template("return %s;\n",$2);}
	|KW_BREAK ';' {$$ = template("break;\n");}
	|KW_CONTINUE ';'{$$ = template("continue;\n");}
	|ifstate { $$ = template("%s",$1); }
	|forstate { $$ = template("%s",$1); }
	|whilestate { $$ = template("%s",$1); }
	|simple_func_call ';' { $$ = template("%s;\n", $1); }
	

;
ifstate:
	KW_IF '(' expr ')' if_body {$$=template("if(%s)%s",$3,$5);}
	|KW_IF '(' expr ')'if_body KW_ELSE elif {$$=template("if(%s)%selse %s",$3,$5,$7);}
	
;


elif:
	%empty { $$ = template("{\n\n}\n");}
	|ifstate {$$=template("%s",$1);}
	|body {$$=template("%s\n",$1);}
;
forstate:
	KW_FOR '(' basic_assign  ';' expr ';' basic_assign ')' if_body  {$$=template("for(%s;%s;%s)%s\n",$3,$5,$7,$9);}
;
basic_assign:
	 TK_IDENT TK_ASSIGN expr { $$ = template("%s = %s", $1, $3); }
;
whilestate:
		KW_WHILE '(' expr ')' if_body {$$=template("while(%s)%s\n",$3,$5);}
;


if_body:
	statement { $$ = template("{\n%s}", $1); }
	| '{' statements'}'  { $$ = template("{\n%s}", $2); }

;

statements:
	%empty { $$ = "";}
	|statement_list { $$ = template("%s", $1); }
;

statement_list:
	statement { $$ = template("%s", $1); }
	|statement statement_list   { $$ = template("%s%s", $1,$2); }
;
statement:
	command  { $$ = template("%s", $1); }
	|decl	{ $$ = template("%s", $1); }
	
;





simple_func_call:
	TK_IDENT '(' args ')' { $$ = template("%s(%s)", $1, $3); }
	
;
args:
	%empty { $$ = "";}
	|expr { $$ = $1;}
	|args ',' expr { $$ = template("%s,%s", $1, $3);}
;


decl_list:
	%empty { $$ = "";}
	|decls
;
	
decls:
	decl { $$ = $1; }
	|decls decl { $$ = template("%s%s", $1,$2); }
;	
decl:
	var_decl { $$ = template("%s\n", $1); }
	|const_decl { $$ = template("%s\n", $1); }
;


const_decl:
KW_CONST const_decl_list ':' type_spec ';' { $$ = template("const %s %s;", $4, $2); }
;
const_decl_list: 
const_decl_list ',' const_decl_list_item { $$ = template("%s, %s", $1, $3); }
| const_decl_list_item 
;
const_decl_list_item: 
const_decl_list_item_id TK_ASSIGN expr { $$ = template("%s =%s", $1, $3);}
;
const_decl_list_item_id: TK_IDENT { $$ = $1; } 
| TK_IDENT '['']' { $$ = template("*%s", $1); }
;
var_decl_list_item_id: TK_IDENT { $$ = $1; } 
| TK_IDENT '['']' { $$ = template("*%s", $1); }
| array { $$ = $1; } 
;




var_decl:
KW_VAR var_decl_list ':' type_spec ';' { $$ = template("%s %s;", $4, $2); }
;
var_decl_list: 
var_decl_list ',' var_decl_list_item { $$ = template("%s, %s", $1, $3); }
| var_decl_list_item 
;
var_decl_list_item: 
var_decl_list_item_id TK_ASSIGN expr { $$ = template("%s =%s", $1, $3);}
|var_decl_list_item_id  { $$ = $1; } 
;



type_spec: KW_NUMBER { $$ = "double"; }
|KW_BOOLEAN { $$ = "int"; }
| KW_STRING { $$ = "char*" ;}
| KW_VOID { $$ = "void"; }
;




%%

int main () {
	
  if ( yyparse() != 0 )
    printf("Rejected!\n");
}