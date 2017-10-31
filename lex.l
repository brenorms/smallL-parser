/*** Definition ***/
%{
/* code to be copied */

//#define YYSTYPE char*
#include "parse.tab.h"
#include <stdio.h>
extern YYSTYPE yylval;
extern int isVerbose;
%}

%option noyywrap

/*** Rules ***/
%%
"{" {if(isVerbose) printf("< OPENBRA, %s >\n", yytext);return OPENBRA;}
"}" {if(isVerbose) printf("< CLOSEBRA, %s >\n", yytext);return CLOSEBRA;}
"(" {if(isVerbose) printf("< OPENPAR, %s >\n", yytext);return OPENPAR;}
")" {if(isVerbose) printf("< CLOSEPAR, %s >\n", yytext);return CLOSEPAR;}
"[" {if(isVerbose) printf("< OPENSQ, %s >\n", yytext);return OPENSQ;}
"]" {if(isVerbose) printf("< CLOSESQ, %s >\n", yytext); return CLOSESQ;}

"int"|"bool"|"float" {if(isVerbose) printf("< BASIC, %s >\n", yytext);strcpy(yylval.sval, yytext); return BASIC;}

"true" {if(isVerbose) printf("< TRUE, %s >\n", yytext); return TRUE;}
"false" {if(isVerbose) printf("< FALSE, %s >\n", yytext); return FALSE;}

"if" {if(isVerbose) printf("< IF, %s >\n", yytext);return IF;}
"else" {if(isVerbose) printf("< ELSE, %s >\n", yytext);return ELSE;}
"while" {if(isVerbose) printf("< WHILE, %s >\n", yytext);return WHILE;}
"do" {if(isVerbose) printf("< DO, %s >\n", yytext); return DO;}
"break" {if(isVerbose) printf("< BREAK , %s >\n", yytext); return BREAK;}

"+" {if(isVerbose) printf("< OPADD, %s >\n", yytext);return OPADD;}
"-" {if(isVerbose) printf("< OPMINUS, %s >\n", yytext);return OPMINUS;}
"=" {if(isVerbose) printf("< OPEQUAL, %s >\n", yytext);return OPEQUAL;}

"|" {if(isVerbose) printf("< OPOR, %s >\n", yytext); return OPOR;}
"&" {if(isVerbose) printf("< OPAND, %s >\n", yytext); return OPAND;}
"!" {if(isVerbose) printf("< OPNOT, %s >\n", yytext);return OPNOT;}
">" {if(isVerbose) printf("< OPMORE, %s >\n", yytext); return OPMORE;}
"<" {if(isVerbose) printf("< OPLESS , %s >\n", yytext); return OPLESS;}

";" {if(isVerbose) printf("< SEMICOLON, %s >\n", yytext);return SEMICOLON;}
"*" {if(isVerbose) printf("< OPMUL, %s >\n", yytext); return OPMUL;}
"/" {if(isVerbose) printf("< OPDIV, %s >\n", yytext); return OPDIV;}
[a-z|A-Z][a-z|A-Z|0-9]* {if(isVerbose) printf("< ID, %s >\n", yytext);strcpy(yylval.sval, yytext); return ID;}
[0-9]+ {if(isVerbose) printf("< NUM, %s >\n", yytext);yylval.ival = atoi(yytext); return NUM;}
[0-9]+"."[0-9]+ {if(isVerbose) printf("< REAL, %s >\n", yytext);yylval.fval = strtof(yytext, NULL); return REAL;}
.|\n {/* ignore the rest */}
%%

/*** Code section ***/
/*
int main(int argc, char* argv[]){
	int ntoken, vtoken;
	printf("argv: %s\n", argv[1]);
	yyin = fopen(argv[1], "r");
	ntoken = yylex();
	printf("TYPE %d ID %d SEMICOLON %d OPEQUAL %d NUM %d REAL %d OPADD %d OPENBRA %d CLOSEBRA %d\n",
		 TYPE, ID, SEMICOLON, OPEQUAL, NUM, REAL, OPADD, OPENBRA, CLOSEBRA);
	while(ntoken){
//		printf("ntoken: %d\n", ntoken);	
		printf("token %d yytext %s\n", ntoken, yytext);
		ntoken = yylex();
	
	}
}*/