%{
void yyerror (char *s);
int yylex();
#include <stdio.h>     /* C declarations used in actions */
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>

typedef struct symbols_struct{
	char name[30];
	double val;
	int flag;  //precision
}symbols;

int var_count=0;
int if_flag=0;
int cond_f=1;
int prior_if=0;
symbols symbol_table[100];
double symbolVal(char name[]);
void updateSymbolVal(char name[], double val);
double power(double val1, double val2);
float modulus(float val1, float val2);
%}

%union {double num; char* id;}         /* Yacc definitions */
%start line
%token print
%token IF
%token ELSE
%token lteq
%token gteq
%token eq
%token neq
%token increment
%token decrement
%token exit_command
%token <num> number
%token <id> identifier
%type <num> line exp term
%type <id> assignment
%type <num> IF

%right '='
%left '<' '>' gteq lteq eq neq
%left '+''-'
%left '*''/''%'
%right '^'
%left '(' ')'
%%

/* descriptions of expected inputs     corresponding actions (in C) */

line   	: assignment ';'					{;}
		| ifstmnt line '}' 				{cond_f=1;}
		| ifstmnt line '}' 				{cond_f=1;} 
			ifstmnt_else line '}'			{cond_f=1;}
		| exit_command ';'					{exit(EXIT_SUCCESS);}
		| '=' exp ';'						{if(cond_f==1){printf("%f\n", $2);}}
		| print exp ';'						{if(cond_f==1){printf("%f\n", $2);}}
		| line assignment ';'				{;}
		| line '=' exp ';'					{if(cond_f==1){printf("%f\n", $3);}}
		| line print exp ';'				{if(cond_f==1){printf("%f\n", $3);}}
		| line exit_command ';'				{if(cond_f==1){exit(EXIT_SUCCESS);}}
		| line ifstmnt line '}' 			{cond_f=1;}
		| line ifstmnt line '}' {cond_f=1;} ifstmnt_else line '}'	{cond_f=1;}
        ;

assignment : identifier '=' exp  			{if(cond_f==1){updateSymbolVal($1,$3); }}
			| identifier '+''=' exp       	{if(cond_f==1){updateSymbolVal($1,symbolVal($1) + $4);}}
	       	| identifier '-''=' exp        	{if(cond_f==1){updateSymbolVal($1,symbolVal($1) - $4);}}
	       	| identifier '*''=' exp        	{if(cond_f==1){updateSymbolVal($1,symbolVal($1) * $4);}}
	       	| identifier '/''=' exp        	{if(cond_f==1){updateSymbolVal($1,symbolVal($1) / $4);}}
	       	| identifier '%''=' exp			{if(cond_f==1){updateSymbolVal($1,symbolVal($1)-(symbolVal($1)/$4)*$4);}}
	       	;

ifstmnt : IF exp '{'  	{ 	if(cond_f==1)
								{
									if_flag=1;
									if($2){
										if_flag=1;
									}else{
										cond_f=0;
										if_flag=0;
									}
								}
							}
ifstmnt_else :	ELSE '{' 	{		
									if(if_flag==0)
									{
										
									}
									else
									{
										cond_f=0;
									}
									if_flag=1;
								}
			;

exp    	: term                  		{if(cond_f==1){$$ = $1;}}
		| '-' term						{if(cond_f==1){$$ = -1*$2;}}
		| exp '+' exp         			{if(cond_f==1){$$ = $1 + $3;}}
       	| exp '-' exp          			{if(cond_f==1){$$ = $1 - $3;}}
       	| exp '*' exp          			{if(cond_f==1){$$ = $1 * $3;}}
       	| exp '/' exp          			{if(cond_f==1){$$ = $1 / $3;}}
       	| exp '>' exp          			{if(cond_f==1){$$ = $1 > $3;}}
       	| exp '<' exp          			{if(cond_f==1){$$ = $1 < $3;}}
       	| exp '%' exp					{if(cond_f==1){$$ = modulus($1,$3);}}
       	| exp gteq exp          		{if(cond_f==1){$$ = $1 >= $3;}}
       	| exp lteq exp          		{if(cond_f==1){$$ = $1 <= $3;}}
       	| exp eq exp          			{if(cond_f==1){$$ = $1 == $3;}}
       	| exp neq exp          			{if(cond_f==1){$$ = $1 != $3;}}
       	| '(' exp ')'           		{if(cond_f==1){$$ = $2;}}
       	;

term   	: number                	{if(cond_f==1){$$ = $1;}}
		| identifier				{if(cond_f==1){$$ = symbolVal($1);} }	
		| identifier increment		{if(cond_f==1){$$ = symbolVal($1); updateSymbolVal($1,symbolVal($1)+1);}}
		| identifier decrement		{if(cond_f==1){$$ = symbolVal($1); updateSymbolVal($1,symbolVal($1)-1);}}
		| increment identifier 		{if(cond_f==1){updateSymbolVal($2,symbolVal($2)+1); $$ = symbolVal($2);}}
		| decrement identifier 		{if(cond_f==1){updateSymbolVal($2,symbolVal($2)-1); $$ = symbolVal($2);}}
        ;

%%                     /* C code */



float modulus(float v1, float v2)
{
	float ans = v1 - ((int)(v1/v2)*v2);
	return ans;
}

/*double power(double v1, double v2)
{
	double result = pow(v1,v2); 
	return result;
}*/

/* returns the value of a given symbol */
double symbolVal(char name[])
{
	//printf("collecting value of %s\n",name);
	int flag=0;
	for ( int i=0; i<var_count ;i++)
	{
		if(strcmp(symbol_table[i].name,name)==0)
		{
			//printf("value found %f\n",symbol_table[i].val);
			return symbol_table[i].val;
		}
	}
	//printf("value not found, setting value to 0\n");
	updateSymbolVal(name,0);
	return 0;
}

/* updates the value of a given symbol */
void updateSymbolVal(char name[], double val)
{
	//printf("updating value of %s to %f\n",name,val);
	int flag=1;
	for ( int i=0; i<var_count ;i++)
	{
		if(strcmp(symbol_table[i].name,name)==0)
		{
			symbol_table[i].val = val;
			flag=0;
			//printf("updated value of %s to %f\n",symbol_table[i].name,symbol_table[var_count].val);
			break;
		}
	}
	if(flag)
	{
		strcpy(symbol_table[var_count].name,name);
		symbol_table[var_count].val = val;
		var_count++;
		//printf("updated value of %s to %f\n",symbol_table[var_count].name,symbol_table[var_count].val);
	}
}

int main (void) {
	/* init symbol table */
	int i;
	for(i=0; i<100; i++) {
		strcpy(symbol_table[i].name," ");
		symbol_table[i].val= 0;
	}
	return yyparse ( );
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 

