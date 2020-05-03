%{
#include "y.tab.h"
void yyerror (char *s);
int yylex();
char *str;
%}
%%
"print"					{return print;}
"if"					{return IF;}
"else"					{return ELSE;}
"exit"					{return exit_command;}
[#].*					;
[a-z][_a-z0-9]*			{str=(char*)calloc((strlen(yytext)+1),sizeof(char));strcpy(str,yytext);yylval.id=str;return identifier;}
[-+*/%^=><(){};]		{return yytext[0];}
[0-9]*[.]?[0-9]*		{yylval.num=atof(yytext);return number;}
[ \t\n] 				;
"!="					{return neq;}
"=="					{return eq;}
">="					{return gteq;}
"<="					{return lteq;}
"++"					{return increment;}
"--"					{return decrement;}
.						{ECHO; yyerror ("unexpected character");}

%%
int yywrap (void) {return 1;}