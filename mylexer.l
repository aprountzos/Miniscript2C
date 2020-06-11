%{
  #include <assert.h>
  #include <stdio.h>
  #include <string.h>
  #include "myanalyzer.tab.h"
  #include "cgen.h"
  
 
  int line_num = 1;


%}

ID      [a-zA-Z_][0-9a-zA-Z_]*
DIGIT   [0-9]
POSINT  [0]|([1-9]{DIGIT}*)
DECIMAL ("."{POSINT})|({POSINT}("."{POSINT}?)?)
NUMBER   {DECIMAL}([eE][+-]?{POSINT})?
symbol  ("."|","|" "|"-"|"+"|"*"|"/"|":"|"_"|"$"|"!"|"#"|"@"|"&"|"~"|"^"|"("|")"|"="|"!")
escape  ("\\n"|"\\t"|"\\r"|"\\\\"|"\\\'"|"\\\"")
common  ([a-z]|[A-Z]|[0-9]|{symbol})
STRING  ("\"")({common}*{escape}*{common}*)*("\"")|("\'")({common}*{escape}*{common}*)*("\'") 


%x comment

%%

  
  /* keywords*/
start         {/*printf("Line %d: Found the KW_START: %s\n", line_num, yytext); */return KW_START;}
const 				{/*printf("Line %d: Found the KW_CONST: %s\n", line_num, yytext); */return KW_CONST;}
var						{/*printf("Line %d: Found the KW_VAR: %s\n", line_num, yytext); */return KW_VAR;}
void          {/*printf("Line %d: Found the KW_VOID: %s\n", line_num, yytext); */return KW_VOID;}
number        {/*printf("Line %d: Found the KW_NUMBER: %s\n", line_num, yytext); */return KW_NUMBER;}
string        {/*printf("Line %d: Found the KW_STRING: %s\n", line_num, yytext); */return KW_STRING;}
function      {/*printf("Line %d: Found the KW_FUNCTION: %s\n", line_num, yytext); */return KW_FUNCTION;}
boolean       {/*printf("Line %d: Found the KW_BOOLEAN: %s\n", line_num, yytext); */return KW_BOOLEAN;}
true          {/*printf("Line %d: Found the KW_TRUE: %s\n", line_num, yytext); */return KW_TRUE;}
false         {/*printf("Line %d: Found the KW_FALSE: %s\n", line_num, yytext); */return KW_FALSE;}
if            {/*printf("Line %d: Found the KW_IF: %s\n", line_num, yytext); */return KW_IF;}
else          {/*printf("Line %d: Found the KW_ELSE: %s\n", line_num, yytext); */return KW_ELSE;}
for           {/*printf("Line %d: Found the KW_FOR: %s\n", line_num, yytext); */return KW_FOR;}
while         {/*printf("Line %d: Found the KW_WHILE: %s\n", line_num, yytext); */return KW_WHILE;}
break         {/*printf("Line %d: Found the KW_BREAK: %s\n", line_num, yytext); */return KW_BREAK;}
continue      {/*printf("Line %d: Found the KW_CONTINUE: %s\n", line_num, yytext); */return KW_CONTINUE;}
not           {/*printf("Line %d: Found the KW_NOT: %s\n", line_num, yytext); */return KW_NOT;}
and           {/*printf("Line %d: Found the KW_AND: %s\n", line_num, yytext); */return KW_AND;}
or            {/*printf("Line %d: Found the KW_OR: %s\n", line_num, yytext); */return KW_OR;}
return        {/*printf("Line %d: Found the KW_RETURN: %s\n", line_num, yytext); */return KW_RETURN;}
null          {/*printf("Line %d: Found the KW_NULL: %s\n", line_num, yytext); */return KW_NULL;}



{POSINT}      {/*printf("Line %d: Found the TK_NUMBER: %s\n", line_num, yytext); */yylval.crepr = strdup(yytext); return TK_POSINT;}
{NUMBER}      {/*printf("Line %d: Found the TK_NUMBER: %s\n", line_num, yytext); */yylval.crepr = strdup(yytext); return TK_NUMBER;}
{STRING}      {/*printf("Line %d: Found the TK_STRING: %s\n", line_num, yytext); */yylval.crepr = strdup(yytext); return TK_STRING;}
{ID}          {/*printf("Line %d: Found the TK_IDENT: %s\n", line_num, yytext); */yylval.crepr = strdup(yytext); return TK_IDENT;}
    
  /*OPERATORS (and,not,or on keywords)*/
"="		        {/*printf("Line %d: Found the TK_ASSIGN: %s\n", line_num, yytext); */return TK_ASSIGN;}
"+"           {/*printf("Line %d: Found the TK_PLUS: %s\n", line_num, yytext); */return '+';}
"-"           {/*printf("Line %d: Found the TK_MINUS: %s\n", line_num, yytext); */return '-';}
"*"           {/*printf("Line %d: Found the TK_MUL: %s\n", line_num, yytext); */return '*';}
"/"           {/*printf("Line %d: Found the TK_DIV: %s\n", line_num, yytext); */return '/';}
"%"           {/*printf("Line %d: Found the TK_MOD: %s\n", line_num, yytext); */return '%';}
"**"          {/*printf("Line %d: Found the TK_POW: %s\n", line_num, yytext); */return TK_POW;}
"=="          {/*printf("Line %d: Found the TK_EQUAL: %s\n", line_num, yytext); */return TK_EQUAL;}
"!="          {/*printf("Line %d: Found the TK_DIF: %s\n", line_num, yytext); */return TK_DIF;}
"<"           {/*printf("Line %d: Found the TK_LESS: %s\n", line_num, yytext); */return '<';}
"<="          {/*printf("Line %d: Found the TK_EQLESS: %s\n", line_num, yytext); */return TK_EQLESS;}

 /*DELIMITERS */
":"		        {/*printf("Line %d: Found the TK_PUNCT_COLON: %s\n", line_num, yytext); */return ':';}
","           {/*printf("Line %d: Found the TK_PUNCT_COMMA: %s\n", line_num, yytext); */return ',';}
";"						{/*printf("Line %d: Found the TK_PUNCT_SEMI: %s\n", line_num, yytext); */return ';';}
"["						{/*printf("Line %d: Found the TK_BRACKET_LEFT: %s\n", line_num, yytext); */return '[';}
"]"						{/*printf("Line %d: Found the TK_BRACKET_RIGHT: %s\n", line_num, yytext); */return ']';}
"("						{/*printf("Line %d: Found the TK_PAREN_LEFT: %s\n", line_num, yytext); */return '(';}
")"						{/*printf("Line %d: Found the TK_PAREN_RIGHT: %s\n", line_num, yytext); */return ')';}
"{"						{/*printf("Line %d: Found the TK_BRACE_LEFT: %s\n", line_num, yytext); */return '{';}
"}"						{/*printf("Line %d: Found the TK_BRACE_RIGHT: %s\n", line_num, yytext); */return '}';}




"//"[^\n]*  	/* eat line comments */

"/*"					BEGIN(comment);
<comment>[^*\n]*        /* eat anything that's not a '*' */
<comment>"*"+[^*/\n]*   /* eat up '*'s not followed by ')'s */
<comment>\n             ++line_num;
<comment>"*"+"/"        BEGIN(INITIAL) ;


[ \r\t]				/* skip whitespace */
\n 						++line_num;
<<EOF>> 			return EOF;

.             { yyerror("Line %d: Lexical error: unrecognized literal '%s'\n",line_num, yytext); }

%%
 /* 
int main ()
{
  int token;
  while ( (token = yylex()) != EOF ){
    ///*printf("Line %d Token %d: %s\n", line_num, token, yytext);
  }
}
*/
