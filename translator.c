#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

enum statement{NONE, IF, IFFALSE, GOTO};

// Stack Overflow question 1726302
void removeBlanks(char* string){
	char* i = string;
	char* j = string;
	while(*j!=0){
		*i = *j++;
		if(*i!=' ')
			i++;
	}
	*i = 0;
}

int main(int argc, char* argv[]){


	FILE* fin = fopen(argv[1], "r");
	FILE* fout = fopen(argv[2], "w");
	char* line;
	char output[1000000]; //1MB
	int count = 0;
	do{
		count++;

		char* beginning = (char*)malloc(sizeof(char)*100);
		fgets(beginning, 100, fin);
		printf("while %s\n", beginning);
		int stmt = NONE;
		line = beginning;
		//remove blank spaces
		//removeBlanks(line);
		//label
		while(line[0]=='L' && line[2]==':'){ //label
			fprintf(fout, "%5s.3", line);
			line +=3;
		}
		//operator
		char op1[11];
		char op2[11];
		char op3[11];
		char op4[11];
		char op5[11];
		char op6[11];
		op1[0] = 0; //C e tao escroto
		op2[0] = 0;
		op3[0] = 0;
		op4[0] = 0;
		op5[0] = 0;
		op6[0] = 0;
		printf("ops %s %s %s %s %s %s \n", op1, op2, op3, op4, op5, op6);
		sscanf(line, "%s %s %s %s %s %s", op1, op2, op3, op4, op5, op6);
		printf("ops %s %s %s %s %s %s \n", op1, op2, op3, op4, op5, op6);
		//statements?
		if(strcmp(op1, "if")==0){

		}else if(strcmp(op1, "iffalse")==0){

		}else if(strcmp(op1, "goto")==0){

		}
		else{ //variable
			if(op2[0]=='['){
				fprintf(fout, " STVI 0,%d\n", count);
			}
			else if(op2[0]=='='){
				if(isdigit(op5[0])){
					fprintf(fout, " LDCT %s\n", op5);
				}
				if(isdigit(op3[0])){
					fprintf(fout, " LDCT %s\n", op3);
				}
				switch(op4[0]){
					case '+':
						fprintf(fout, " ADDD\n");
						break;
					case '-':
						fprintf(fout, " SUBT\n");
						break;
					case '*':
						fprintf(fout, " MULT\n");
						break;
					case '/':
						fprintf(fout, " DIVI\n");
						break;
					case '[': // '['
						fprintf(fout, " LDLI 0,%d\n", count);
						fprintf(fout, " STVL 0,%d\n", count);
						break;
					default:
						break;
				}
			}
		}
		//operand 1
		//operand 2

		//target

		//
		free(beginning);
	}while(!feof(fin));
	printf("%s\n", output);
}