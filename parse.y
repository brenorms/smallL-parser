%{
	/*** Definitions ***/

	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	#define REGLEN 10
	#define SYMLEN 10

	extern int yylex();
	extern int yyparse();
	extern FILE* yyin;

	int isVerbose = 0;

	struct Symbol{
		char name[SYMLEN];
		char type[SYMLEN];
		double value;
	}symTab[1000];

	int symCount = 0;
	int quadCount = 0;
	char symAux[SYMLEN];
	int tempVar = 0;
	int labelVar = 0;
	int numif=0;

	int symSearch(char* c);
	void symAdd(char* name, char* type, double value);
	void printSymTab();

	struct Quadruple{
		char operator[REGLEN];
		char operand1[REGLEN];
		char operand2[REGLEN];
		char target[REGLEN];
	}quadTab[1000];

	void quadAdd(char* operator, char* operand1, char* operand2, char* target);
	void printQuadTab();

	void push(char* str);
	char* pop();

	void generateIntermediateCode(FILE* stream);

	struct Stack{
		char* content[1000];
		int top;
	}stk;

	void yyerror(char const *s){
		fprintf(stderr, "ERROR: %s\n", s);
	}
%}

%error-verbose

%union{
	int ival;
	float fval;
	char sval[20];
}

%nonassoc IFX
%token IF
%nonassoc ELSE
%token DO
%token WHILE
%token BREAK
%token OPENBRA
%token CLOSEBRA
%token OPENPAR
%nonassoc CLOSEPAR
%token OPENSQ
%token CLOSESQ
%token SEMICOLON
%token OPMINUS
%token OPADD
%token OPEQUAL
%token OPMUL
%token OPDIV
%token OPNOT
%token OPOR
%token OPAND
%token OPMORE
%token OPLESS
%token TRUE
%token FALSE

%token NUM
%token FACTOR
%token BASIC
%token REAL
%token ID

%type<ival> NUM
%type<sval> FACTOR
%type<sval> BASIC
%type<fval> REAL
%type<sval> ID

%%
//here there be grammar
program:
	block {}
;
block:
	OPENBRA decls stmts CLOSEBRA {}
;
decls:
	decls decl {}
	|
;
decl:
	type ID SEMICOLON {
		if(symSearch($2)==-1)
			symAdd($2, $<sval>1, 0);
		else{
			printf("Error: variable %s is already declared\n", $2);		
		}
	}
;
type:
	type OPENSQ NUM CLOSESQ {}
	| BASIC {}
;

stmts:
	stmts stmt {}
	| 
;

stmt: 
	loc OPEQUAL bool SEMICOLON {
		char* temp = pop();
		quadAdd("=", "", temp, pop());
	}
	| ifstmt %prec IFX{
		numif--;
		quadAdd("Label", pop(), "", "");
	}

	| ifstmt ELSE{
		char str1[SYMLEN];
		labelVar++;
		char str3[SYMLEN]="L_";
		sprintf(str1, "%d", labelVar);
		strcat(str3, str1);
		quadAdd("goto", "", "", str3);
		quadAdd("Label", pop(), "", "");
		push(str3);
	} stmt{
		numif--;
		quadAdd("Label", pop(), "", "");
	}

	| WHILE OPENPAR{
		char str1[SYMLEN];
		char str2[SYMLEN]="L_";
		labelVar++;
		sprintf(str1, "%d", labelVar);
		strcat(str2, str1);
		quadAdd("Label", str2, "", "");
		push(str2);
	} bool{
		char str1[SYMLEN];
		char str2[SYMLEN]="L_";
		labelVar++;
		sprintf(str1, "%d", labelVar);
		strcat(str2, str1);
		quadAdd("iffalse", pop(), "", str2);
		push(str2);
	} CLOSEPAR stmt {
		char* temp = pop();
		quadAdd("goto", "", "", pop());
		quadAdd("Label", temp, "", "");
	}

	| DO{
		char str1[SYMLEN];
		char str2[SYMLEN]="L_";
		labelVar++;
		sprintf(str1, "%d", labelVar);
		strcat(str2, str1);
		quadAdd("Label", str2, "", "");
		push(str2);
	} stmt WHILE OPENPAR bool CLOSEPAR SEMICOLON {
		char* temp = pop();
		quadAdd("if", temp, "", pop());
	}
	| BREAK SEMICOLON {
		char* stack[10];
		int i;
		for(i=0; i<=numif; i++){
			stack[i] = pop();
		}
		i--;
		quadAdd("goto", "", "", stack[i]);
		for(;i>=0; i--){
			push(stack[i]);
		}
	}
	| block
;

ifstmt:
	IF OPENPAR bool CLOSEPAR{
		char str1[SYMLEN];
		char str2[SYMLEN]="L_";
		labelVar++;
		numif++;
		sprintf(str1, "%d", labelVar);
		strcat(str2, str1);
		quadAdd("iffalse", pop(), "", str2);
		push(str2);
	}  stmt
;

loc:
	loc OPENSQ bool CLOSESQ{
		char str1[SYMLEN];
		char str2[SYMLEN]="t_";
		sprintf(str1, "%d", tempVar);
		strcat(str2, str1);
		tempVar++;
		quadAdd("*", pop(), "8", str2);

		char str3[SYMLEN]="[";
		strcat(str3, str2);
		strcat(str3, "]");
		push(strcat(pop(), str3));
	} 
	| ID {
		int i;
		if(i=symSearch($1) ==-1)
			printf("Error: undefined variable %s\n", symAux);
		else
			push($1);
	}
;

bool:
	bool OPOR OPOR join{
		char str1[SYMLEN];
		char str2[SYMLEN]="t_";
		sprintf(str1, "%d", tempVar);
		strcat(str2, str1);
		tempVar++;
		quadAdd("||", pop(), pop(), str2);
		push(str2);
	}
	| join{}
;

join:
	join OPAND OPAND equality{
		char str1[SYMLEN];
		char str2[SYMLEN]="t_";
		sprintf(str1, "%d", tempVar);
		strcat(str2, str1);
		tempVar++;
		quadAdd("&&", pop(), pop(), str2);
		push(str2);
	}
	| equality
;

equality:
	equality OPEQUAL OPEQUAL rel{
		char str1[SYMLEN];
		char str2[SYMLEN]="t_";
		sprintf(str1, "%d", tempVar);
		strcat(str2, str1);
		tempVar++;
		quadAdd("==", pop(), pop(), str2);
		push(str2);
	}
	| equality OPNOT OPEQUAL rel{
		char str1[SYMLEN];
		char str2[SYMLEN]="t_";
		sprintf(str1, "%d", tempVar);
		strcat(str2, str1);
		tempVar++;
		quadAdd("!=", pop(), pop(), str2);
		push(str2);
	}
	| rel
;

rel:
	expr OPLESS expr{
		char str1[SYMLEN];
		char str2[SYMLEN]="t_";
		sprintf(str1, "%d", tempVar);
		strcat(str2, str1);
		tempVar++;
		quadAdd("<", pop(), pop(), str2);
		push(str2);
	}
	| expr OPLESS OPEQUAL expr {
		char str1[SYMLEN];
		char str2[SYMLEN]="t_";
		sprintf(str1, "%d", tempVar);
		strcat(str2, str1);
		tempVar++;
		quadAdd("<=", pop(), pop(), str2);
		push(str2);
	}
	| expr OPMORE OPEQUAL expr {
		char str1[SYMLEN];
		char str2[SYMLEN]="t_";
		sprintf(str1, "%d", tempVar);
		strcat(str2, str1);
		tempVar++;
		quadAdd(">=", pop(), pop(), str2);
		push(str2);
	}
	| expr OPMORE expr {
		char str1[SYMLEN];
		char str2[SYMLEN]="t_";
		sprintf(str1, "%d", tempVar);
		strcat(str2, str1);
		tempVar++;
		quadAdd(">", pop(), pop(), str2);
		push(str2);
	}
	| expr {}
;

expr:
	expr OPADD term {
		char str1[SYMLEN];
		char str2[SYMLEN]="t_";
		sprintf(str1, "%d", tempVar);
		strcat(str2, str1);
		tempVar++;
		quadAdd("+", pop(), pop(), str2);
		push(str2);
	}
	| expr OPMINUS term {
		char str1[SYMLEN];
		char str2[SYMLEN]="t_";
		sprintf(str1, "%d", tempVar);
		strcat(str2, str1);
		tempVar++;
		quadAdd("-", pop(), pop(), str2);
		push(str2);
	}   
	| term {}
;

term:
	term OPMUL unary {
		char str1[SYMLEN];
		char str2[SYMLEN]="t_";
		sprintf(str1, "%d", tempVar);
		strcat(str2, str1);
		tempVar++;
		quadAdd("*", pop(), pop(), str2);
		push(str2);
	}  
	| term OPDIV unary {
		char str1[SYMLEN];
		char str2[SYMLEN]="t_";
		sprintf(str1, "%d", tempVar);
		strcat(str2, str1);
		tempVar++;
		quadAdd("/", pop(), pop(), str2);
		push(str2);
	}   
	| unary {}
;

unary:
	OPNOT unary {
		char str1[SYMLEN];
		char str2[SYMLEN]="t_";
		sprintf(str1, "%d", tempVar);
		strcat(str2, str1);
		tempVar++;
		quadAdd("!", "", pop(), str2);
		push(str2);
	}
	| OPMINUS unary {
		char str1[SYMLEN];
		char str2[SYMLEN]="t_";
		sprintf(str1, "%d", tempVar);
		strcat(str2, str1);
		tempVar++;
		quadAdd("-", "", pop(), str2);
		push(str2);
	}
	| factor {}
;

factor:
	OPENPAR bool CLOSEPAR {}
	| loc {
		printf("igual a loc\n");
		char* temp = pop();
		char str1[SYMLEN] = "t_";
		snprintf(str1, SYMLEN, "t_%d", tempVar);
		tempVar++;
		quadAdd("=", "", temp, str1);
		push(str1);
	} 
	| NUM {
		char str[SYMLEN];
		snprintf(str, SYMLEN, "%d", $1);
		push(str);
	}
	| REAL {
		char str[SYMLEN];
		snprintf(str, SYMLEN, "%f", $1);
		push(str);
	}
	| TRUE {
		push("true");
	}
	| FALSE {
		push("false");
	}
;

%%
/**
 ./compiler <input file> <-v for verbose>
*/
/* // Legacy code: tp1
int main(int argc, char** argv){
	if(argc<2){
		fprintf(stderr, "ERROR: Too few arguments \n");
		return -1;
	}
	yyin = fopen(argv[1], "r");
	if(!yyin){
		fprintf(stderr, "ERROR: Could not find file %s\n", argv[1]);
		return -1;
	}
	char* initBuf;
//	printf("NUM %d ID %d REAL %d\n", NUM, ID, REAL);
	//verbose mode prints the tokens
	if(argc>2 && argv[2][1]=='v' && argv[2][0]=='-'){
		isVerbose = 1;
		printf("TOKENS: ");
		while(yylex()){}
		isVerbose = 0;
		fseek(yyin, 0, 0);
	}
	do{
		yyparse();
	}while(!feof(yyin));
	free(initBuf);
}*/

int symSearch(char* sym){
	int i;
	for(i=0; i<symCount; i++){
		if(strcmp(symTab[i].name, sym)==0)
			return i;
	}
	return -1;
}

void symAdd(char* sym, char* type, double val){
	strcpy(symTab[symCount].name, sym);
	strcpy(symTab[symCount].type, type);
	symTab[symCount].value = val;
	symCount++;
}

void printSymTab(){
	int i;
	for (int i = 0; i < symCount; i++)
	{
		printf("%10s %10s %10f\n", symTab[i].name, symTab[i].type, symTab[i].value);
	}
}

void quadAdd(char* opt, char* op1, char* op2, char* target){
	strcpy(quadTab[quadCount].operator, opt);
	strcpy(quadTab[quadCount].operand1, op1);
	strcpy(quadTab[quadCount].operand2, op2);
	strcpy(quadTab[quadCount].target, target);
	quadCount++;
}

void printQuadTab(){
	int i;
	for (int i = 0; i < quadCount; i++)
	{
		printf("%10s %10s %10s %10s \n", quadTab[i].operator, quadTab[i].operand1, quadTab[i].operand2, quadTab[i].target);
	}
}

void push(char* str){
	stk.top++;
	stk.content[stk.top]=(char*)malloc(strlen(str)+1);
	strcpy(stk.content[stk.top], str);
}

char* pop(){
	if(stk.top==-1){ //panic?
		printf("Error: Stack is empty.\n");
		return NULL;
	}
	char* str = (char*)malloc(strlen(stk.content[stk.top])+1);
	strcpy(str, stk.content[stk.top]);
	stk.top--;
	return str;
}

void generateIntermediateCode(FILE* stream){
	int i;
	char *op, *arg1, *arg2, *tar;
	for(i=0; i<quadCount; i++){
		op = quadTab[i].operator;
		arg1 = quadTab[i].operand1;
		arg2 = quadTab[i].operand2;
		tar = quadTab[i].target;

		if(strcmp(op,"if")==0 || strcmp(op,"iffalse")==0)
			fprintf(stream, "%s %s goto %s\n", op, arg1, tar);
		else if(strcmp(op, "[]")==0)
			fprintf(stream, "%s = %s [ %s ]\n", tar, arg1, arg2);
		else if(tar[0]=='t' && tar[1]=='_')
			fprintf(stream, "%s = %s %s %s\n", tar, arg1, op, arg2);
		else if(strcmp(op,"Label")==0)
			fprintf(stream, "%s: ", arg1);
		else if(strcmp(op, "goto")==0)
			fprintf(stream, "%s %s\n", op, tar);
		else if(strcmp(op, "[]")==0)
			fprintf(stream, "%s = %s [ %s ]\n", tar, arg1, arg2);
		else
			fprintf(stream, "%s %s %s %s\n", tar, arg1, op, arg2);
	}
}

int main(int argc, char** argv){
	if(argc<2){
		fprintf(stderr, "ERROR: Too few arguments \n");
		return -1;
	}
	yyin = fopen(argv[1], "r");
	if(!yyin){
		fprintf(stderr, "ERROR: Could not find file %s\n", argv[1]);
		return -1;
	}
	char* initBuf;
	//	printf("NUM %d ID %d REAL %d\n", NUM, ID, REAL);
	//verbose mode prints the tokens
	if(argc>2 && argv[2][1]=='v' && argv[2][0]=='-'){
		isVerbose = 1;
		printf("TOKENS: ");
		while(yylex()){}
		isVerbose = 0;
		fseek(yyin, 0, 0);
	}
	do{
		stk.top = -1;
		yyparse();
		if(argc>2 && argv[2][1]=='v' && argv[2][0]=='-'){
			printf("Symbol Table: \n");
			printSymTab();
			printf("Quadruple Table: \n");
			printQuadTab();
		}
	}while(!feof(yyin));
	free(initBuf);
	generateIntermediateCode(stdout);
}
