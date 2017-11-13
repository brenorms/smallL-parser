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

int searchVar(char vars[1000][11], int size, char* name){
	int i = 0;
	while(i<size && strcmp(vars[i], name)!=0){
		i++;
	}
	return i;
}

int main(int argc, char* argv[]){


	FILE* fin = fopen(argv[1], "r");
	FILE* fout = fopen(argv[2], "w");
	char* line;
	char output[1000000]; //1MB
	int count = 0;
	char vars[1000][11];
	do{

		char* beginning = (char*)malloc(sizeof(char)*100);
		fgets(beginning, 100, fin);
		int stmt = NONE;
		int index;
		line = beginning;
		//remove blank spaces
		//removeBlanks(line);
		//label
		while(line[0]=='L' && line[2]==':'){ //label
			fprintf(fout, "%.3s NOOP\n", line);
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
		sscanf(line, "%s %s %s %s %s %s", op1, op2, op3, op4, op5, op6);
		//statements?
		if(strcmp(op1, "if")==0 || strcmp(op1, "iffalse")==0){
			if(isdigit(op2[0])){
				fprintf(fout, " LDCT %s\n", op2);
			}
			else{
				index = searchVar(vars, count, op2);
				if(index==count){
					strcpy(vars[index], op2);
					count++;
				}
				fprintf(fout, " LDVL %d\n", index);
			}
			if(isdigit(op4[0])){
				index = searchVar(vars, count, op4);
				if(index==count){
					strcpy(vars[index], op4);
					count++;
				}
				fprintf(fout, " LDCT %s\n", op4);
			}
			else{
				index = searchVar(vars, count, op4);
				if(index==count){
					strcpy(vars[index], op4);
					count++;
				}
				fprintf(fout, " LDVL %d\n", index);
			}
			
			if(strcmp(op3, "==")==0){
				fprintf(fout, " EQUA\n");
			}else if(strcmp(op3, "!=")==0){
				fprintf(fout, " DIFF\n");
			}else if(strcmp(op3, ">=")==0){
				fprintf(fout, " GEQU\n");
			}else if(strcmp(op3, ">")==0){
				fprintf(fout, " GRTR\n");
			}else if(strcmp(op3, "<=")==0){
				fprintf(fout, " LEQU\n");
			}else if(strcmp(op3, "<")==0){
				fprintf(fout, " LESS\n");
			}
			if(strcmp(op1, "if")==0)
				fprintf(fout, " LNOT\n");
			fprintf(fout, " JUMP %s\n", op6);
		}else if(strcmp(op1, "goto")==0){
			fprintf(fout, " JUMP %s\n", op2);
		}
		else{ //variable
			if(op2[0]=='['){
				index = searchVar(vars, count, op1);
				if(index==count){
					strcpy(vars[index], op1);
					count++;
				}
				if(isdigit(op3[0])){
					fprintf(fout, " STVI %d,%s\n", index, op3);
				}
				else{
					int index2 = searchVar(vars, count, op3);
					if(index2==count){
						strcpy(vars[index], op3);
						count++;
					}
					fprintf(fout, " STVI %d,%d\n", index, index2);
				}
			}
			else if(op2[0]=='='){
				if(isdigit(op5[0])){
					index = searchVar(vars, count, op5);
					if(index==count){
						strcpy(vars[index], op5);
						count++;
					}
					fprintf(fout, " LDCT %s\n", op5);
				}
				if(isdigit(op3[0])){
					index = searchVar(vars, count, op3);
					if(index==count){
						strcpy(vars[index], op3);
						count++;
					}
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
						index = searchVar(vars, count, op3);
						if(index==count){
							strcpy(vars[index], op3);
							count++;
						}
						fprintf(fout, " LDLI 0,%d\n", index);
						fprintf(fout, " STVL 0,%d\n", index);
						break;
					default:
						break;
				}
				index = searchVar(vars, count, op1);
				if(index==count){
					strcpy(vars[index], op1);
					count++;
				}
				fprintf(fout, " STVL 0,%d\n", index);
			}
		}
		//operand 1
		//operand 2

		//target

		//
		free(beginning);
	}while(!feof(fin));
}
