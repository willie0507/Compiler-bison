%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

extern int yylex();
extern int yylineno;
extern int yylnum;
extern char* yylstr;
extern char* yylstrtmp;

int yyerror(char *str);
void add();
void sub();

int Label_count = 1;
int Label_reg = 0;
int count = -1; // reg start from 0, initial to -1


%}

%union{
	int num;
	char *str;
};

%token <num> NUMBER
%token <str> ID
%token B DECLARE ELSE END EXIT FOR IF IN INTEGER IS LOOP PROCEDURE READ THEN WRITE COLON TWODOT SEMICOLON OP CP 
%token ADD SUB MUL DIV MOD ASSIGN LG GT GE LT LE AND OR NOT CA

%start program

%%
program:
	PROCEDURE ID IS DECLARE begin_data var_decls B begin_text statements END SEMICOLON {}
	;

begin_data:
	/*empty*/	{
		printf("\t.data\n");
	}
	;

var_decls:
	/*empty*/	{}
	| var_decls var_decl {printf("%s:\t.word\t0\n", yylstr)}
	;
	
var_decl:
	ID COLON INTEGER SEMICOLON{
	}
	;

begin_text:
	/*empty*/	{
		printf("\t.text\n");
		printf("main:\n");
	}	
	;	
	
statements:
	/*empty*/	{}
	| statements statement {}
	;
	
statement:
	assignment_stmt {}
	| if_stmt {
		printf("L%d:\t# end if\n", Label_reg);
	}
	| for_stmt {
		printf("L%d:\t# end loop\n",Label_count);
		Label_count++;
	}
	| exit_stmt {
		printf("\tli\t$v0, 10\n");
		printf("\tsyscall\n");
	}
	| read_stmt {
		printf("\tli\t$v0, 5\n");
		printf("\tsyscall\n");
		add();
		printf("\tla\t$t%d, %s\n",count, yylstr);
		printf("\tsw\t$v0, 0($%d)\n", count);
		sub();
	}
	| write_stmt {
		printf("\tmove\t$a0, $t%d\n", count);
		printf("\tli\t$v0, 1\n");
		printf("\tsyscall\n");
	}
	;

assignment_stmt:
	ID{ 
		yylstrtmp = (char*)malloc(sizeof(yylstr));strcpy(yylstrtmp, yylstr); 
	}
	CA arith_expr SEMICOLON {
		add();
		printf("\tla\t$t%d, %s\n", count, yylstrtmp);
		free(yylstrtmp);
		sub();
		printf("\tsw\t$t%d, 0($t%d)\n", count, count+1);
		sub();
	}
	;
	
if_stmt:
	IF bool_expr THEN do_if statements END IF SEMICOLON {
	
	} 
	| IF bool_expr THEN do_if statements ELSE do_else statements END IF SEMICOLON{
	
	}
	;

do_if:
	/*empty*/	{
		printf("\tb\tL%d\n", Label_count+1); //if失敗要跳的label
		printf("L%d:\t# then\n", Label_count); 
		Label_count++;
		Label_reg = Label_count;
	}
	
do_else:
	/*empty*/	{
		printf("\tb\tL%d\n", Label_count+1);
		printf("L%d:\t# else\n",Label_count);
		Label_count++;
		Label_reg = Label_count;
		Label_count++;
	}

for_stmt:
	FOR ID IN arith_expr for_one TWODOT arith_expr for_loop LOOP statements for_end END LOOP SEMICOLON {
		
	}
	;

for_one:
	/*empty*/	{
		add(); //reg t1
		printf("\tla\t$t%d, %s\n", count, yylstr);
		printf("\tsw\t$t%d, 0($t%d)\n", count-1, count);
		sub();
		sub();  //reg沒人拿
		
		printf("L%d:\t# for\n", Label_count);
		Label_count++;
		
		add();  //拿reg t0
		printf("\tla\t$t%d, %s\n", count, yylstr);
		printf("\tlw\t$t%d, 0($t%d)\n", count, count);
	}
	;
	
for_loop:
	/*empty*/	{ // 比較t0 t1 
		printf("\tble\t$t%d, $t%d, L%d\n", count-1, count, Label_count);
		sub();
		sub();
		
		printf("\tb\tL%d\n", Label_count+1);
		printf("L%d:\t# loop\n", Label_count);
		Label_count++;
	}
	;

for_end:
	/*empty*/	{
		add();
		printf("\tla\t$t%d, %s\n", count, yylstr);
		printf("\tlw\t$t%d, 0($t%d)\n", count, count);
		add();
		printf("\tli\t$t%d, 1\n", count);
		printf("\tadd\t$t%d, $t%d, $t%d\n", count-1, count-1, count);
		printf("\tla\t$t%d, %s\n", count, yylstr);
		printf("\tsw\t$t%d, 0($t%d)\n", count-1, count);
		sub();
		sub();
		printf("\tb\tL%d\n", Label_count-2);
	}
	;
	
exit_stmt:
	EXIT SEMICOLON {
		
	}
	;
	
read_stmt:
	READ ID SEMICOLON {
	
	}
	;
	
write_stmt:
	WRITE arith_expr SEMICOLON	{
		
	}
	;
	
bool_expr:
	bool_term	{
		
	}
	| bool_expr OR bool_term {
		
	}
	;
	
bool_term:
	bool_factor	{
		
	}
	| bool_term AND bool_factor	{
		
	}
	;
	
bool_factor:
	bool_primary {
		
	}
	| NOT bool_primary	{
		printf("\tnot\t$t%d, $t%d\n", count-1, count);
		sub();
	}
	;

//判斷式(=, <>, >, >=, <, <=)	
bool_primary:
	arith_expr ASSIGN arith_expr	{
		printf("\tbeq\t$t%d, $t%d, L%d\n", count-1, count, Label_count);
		sub();//釋放第1個
		sub();//釋放第2個
	}
	| arith_expr LG arith_expr	{
		printf("\tbne\t$t%d, $t%d, L%d\n", count-1, count, Label_count);
		sub();
		sub();
	}
	| arith_expr GT arith_expr	{
		printf("\tbgt\t$t%d, $t%d, L%d\n", count-1, count, Label_count);
		sub();
		sub();
	}
	| arith_expr GE arith_expr	{
		printf("\tbge\t$t%d, $t%d, L%d\n", count-1, count, Label_count);
		sub();
		sub();
	}
	| arith_expr LT arith_expr	{
		printf("\tblt\t$t%d, $t%d, L%d\n", count-1, count, Label_count);
		sub();
		sub();
	}
	| arith_expr LE arith_expr	{
		printf("\tble\t$t%d, $t%d, L%d\n", count-1, count, Label_count);
		sub();
		sub();
	}
	| OP bool_expr CP	{
		
	}
	;

//加減	
arith_expr:
	arith_term	{
		
	}
	| arith_expr ADD arith_term	{
		printf("\tadd\t$t%d, $t%d, $t%d\n", count-1, count-1, count);
		sub();
	}
	| arith_expr SUB arith_term	{
		printf("\tsub\t$t%d, $t%d, $t%d\n", count-1, count-1, count);
		sub();
	}
	;
	
//乘除	
arith_term:
	arith_factor	{

	}
	| arith_term MUL arith_factor	{
		printf("\tmul\t$t%d, $t%d, $t%d\n", count-1, count-1, count);
		sub();
	}
	| arith_term DIV arith_factor	{
		printf("\tdiv\t$t%d, $t%d, $t%d\n", count-1, count-1, count);
		sub();
	}
	| arith_term MOD arith_factor	{
		printf("\tmod\t$t%d $t%d,, $t%d\n", count-1, count-1, count);
		sub();
	}
	;

//負號	
arith_factor:
	arith_primary	{
		
	}
	| SUB arith_primary	{
		printf("\tneg\t$t%d, $t%d\n", count, count);
		sub();
	}
	;

	
arith_primary:
	NUMBER {
		add();
		printf("\tli\t$t%d, %d\n", count, yylnum);
	}
	| ID {
		add();//拿一個reg
		printf("\tla\t$t%d, %s\n", count, yylstr);
		printf("\tlw\t$t%d, 0($t%d)\n",count, count);
	}
		
	| OP arith_expr CP {
		
	}
	;
	

%%

void add(){count++;}
void sub(){count--;}

int main(){	
	yyparse();		
	return 0;		
}
	
int yyerror(char *str){		
	fprintf(stderr, "Syntax error: line %d\n", yylineno);		
}
