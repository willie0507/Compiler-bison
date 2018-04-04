%{
#include <stdio.h>
#include <string.h>
extern int yylex();
extern int yylineno;
int yyerror(char* str){
	fprintf(stderr, "Syntax error: line %d\n", yylineno);
}
int arg_check = 0 ;
%}
%union{
	int integer ;
	char* string ;
}
%token ELSE
%token EXIT
%token INT
%token IF
%token READ
%token RETURN
%token WHILE
%token WRITE
%token <string> ID
%token NUMBER
%token PLUS MINUS
%token MOD
%token MUL DIV
%token EQ
%token NEQ
%token GREAT
%token GE
%token LESS
%token LE
%token OR
%token AND
%token NOT
%token ASSIGHN
%token SEMI
%token COMMA
%token LSB
%token RSB
%token LBB
%token RBB
%%
program: ID LSB RSB function_body {if(arg_check==1) printf("program -> Identifier () function_body\n");}
;
function_body: LBB variable_declarations statements RBB {if(arg_check==1) printf("function_body -> { variable_declarations statements }\n");}
;
variable_declarations: /* empty */ {if(arg_check==1) printf("variable_declarations -> empty\n");} 
| variable_declarations variable_declaration {if(arg_check==1) printf("variable_declarations -> variable_declarations variable_declaration\n");}
;
variable_declaration: INT ID SEMI {if(arg_check==1) printf("variable_declaration -> int Identifier ;\n");}
;
statements: /* empty */ {if(arg_check==1) printf("statements -> empty\n");}
| statements statement {if(arg_check==1) printf("statements -> statements statement\n");}
;
statement: assignment_statement {if(arg_check==1) printf("statement -> assignment_statement\n");}
| compound_statement {if(arg_check==1) printf("statement -> compound_statement\n");}
| if_statement {if(arg_check==1) printf("statement -> if_statement\n");}
| while_statement {if(arg_check==1) printf("statement -> while_statement\n");}
| exit_statement {if(arg_check==1) printf("statement -> exit_statement\n");}
| read_statement {if(arg_check==1) printf("statement -> read_statement\n");}
| write_statement {if(arg_check==1) printf("statement -> write_statement\n");}
;
assignment_statement: ID ASSIGHN arith_expression SEMI {if(arg_check==1) printf("assignment_statement -> Identifier = arith_expression ;\n");}
;
compound_statement: LBB statements RBB {if(arg_check==1) printf("compound_statement -> { statements }\n");}
;
if_statement: IF LSB bool_expression RSB statement {if(arg_check==1) printf("if_statement -> if ( bool_expression ) statement\n");}
| IF LSB bool_expression RSB statement ELSE statement {if(arg_check==1) printf("if_statement -> if ( bool_expression ) statement else statement\n");}
;
while_statement: WHILE LSB bool_expression RSB statement {if(arg_check==1) printf("while_statement -> while ( bool_expression ) statement\n");}
;
exit_statement: EXIT SEMI {if(arg_check==1) printf("exit_statement -> exit ;\n");}
;
read_statement: READ ID SEMI {if(arg_check==1) printf("read_statement -> read Identifier ;\n");}
;
write_statement: WRITE arith_expression SEMI {if(arg_check==1) printf("write_statement -> write arith_expression ;\n");}
;
bool_expression: bool_term {if(arg_check==1) printf("bool_expression -> bool_term\n");}
| bool_expression OR bool_term {if(arg_check==1) printf("bool_expression -> bool_expression || bool_term\n");}
;
bool_term: bool_factor {if(arg_check==1) printf("bool_term -> bool_factor\n");}
| bool_term AND bool_factor {if(arg_check==1) printf("bool_term -> bool_term && bool_factor\n");}
;
bool_factor: bool_primary {if(arg_check==1) printf("bool_factor -> bool_primary\n");}
| NOT bool_primary {if(arg_check==1) printf("bool_factor -> ! bool_primary\n");}
;
bool_primary: arith_expression EQ arith_expression {if(arg_check==1) printf("bool_primary -> arith_expression == arith_expression\n");}
| arith_expression NEQ arith_expression {if(arg_check==1) printf("bool_primary -> arith_expression != arith_expression\n");}
| arith_expression GREAT arith_expression {if(arg_check==1) printf("bool_primary -> arith_expression > arith_expression\n");}
| arith_expression GE arith_expression {if(arg_check==1) printf("bool_primary -> arith_expression >= arith_expression\n");}
| arith_expression LESS arith_expression {if(arg_check==1) printf("bool_primary -> arith_expression < arith_expression\n");}
| arith_expression LE arith_expression {if(arg_check==1) printf("bool_primary -> arith_expression <= arith_expression\n");}
;
arith_expression: arith_term {if(arg_check==1) printf("arith_expression -> arith_term\n");}
| arith_expression PLUS arith_term {if(arg_check==1) printf("arith_expression -> arith_expression + arith_term\n");}
| arith_expression MINUS arith_term {if(arg_check==1) printf("arith_expression -> arith_expression - arith_term\n");}
;
arith_term: arith_factor {if(arg_check==1) printf("arith_term -> arith_factor\n");}
| arith_term MUL arith_factor {if(arg_check==1) printf("arith_term -> arith_term * arith_factor\n");}
| arith_term DIV arith_factor {if(arg_check==1) printf("arith_term -> arith_term / arith_factor\n");}
| arith_term MOD arith_factor {if(arg_check==1) printf("arith_term -> arith_term \% arith_factor\n");}
;
arith_factor: arith_primary {if(arg_check==1) printf("arith_factor -> arith_primary\n");}
| MINUS arith_primary {if(arg_check==1) printf("arith_factor -> - arith_primary\n");}
;
arith_primary: NUMBER {if(arg_check==1) printf("arith_primary -> Integer\n");}
| ID {if(arg_check==1) printf("arith_primary -> Identifier\n");}
| LSB arith_expression RSB {if(arg_check==1) printf("arith_primary -> ( arith_expression )\n");}
;
%%
int main(int argc, char** argv){
	if(argc == 2 && strcmp("-p", argv[1])== 0)
		arg_check = 1 ;
	yyparse() ;

	return 0 ;
}
