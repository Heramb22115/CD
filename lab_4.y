
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(char *);
int yylex(void);

typedef struct {
    char op[10];
    char arg1[10];
    char arg2[10];
    char result[10];
} Tac;

Tac tac_table[100]; 
int tac_index = 0;
int temp_count = 0; 

char* new_temp() {
    char* temp = (char*)malloc(sizeof(char) * 4);
    sprintf(temp, "t%d", temp_count++);
    return temp;
}

void add_tac(char* op, char* arg1, char* arg2, char* result) {
    strcpy(tac_table[tac_index].op, op);
    strcpy(tac_table[tac_index].arg1, arg1);
    strcpy(tac_table[tac_index].arg2, arg2);
    strcpy(tac_table[tac_index].result, result);
    tac_index++;
}

void print_code();
%}

%union {
    char* id;
}

%token <id> ID NUM
%type <id> expr term factor

%left '+' '-'
%left '*' '/'

%%
line: ID '=' expr ';' { add_tac("=", $3, "", $1); }
    | expr ';'      { /* Expression without assignment */ }
    ;

expr: expr '+' term {
          $$ = new_temp();
          add_tac("+", $1, $3, $$);
      }
    | expr '-' term {
          $$ = new_temp();
          add_tac("-", $1, $3, $$);
      }
    | term          { $$ = $1; }
    ;

term: term '*' factor {
          $$ = new_temp();
          add_tac("*", $1, $3, $$);
      }
    | term '/' factor {
          $$ = new_temp();
          add_tac("/", $1, $3, $$);
      }
    | factor        { $$ = $1; }
    ;

factor: '(' expr ')' { $$ = $2; }
      | ID           { $$ = $1; }
      | NUM          { $$ = $1; }
      ;
%%

void yyerror(char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    printf("Enter an expression (e.g., a = b * c + d;):\n");
    yyparse();
    print_code();
    return 0;
}

void print_code() {
    int i;
    printf("\n--- THREE-ADDRESS CODE ---\n");
    for (i = 0; i < tac_index; i++) {
        printf("%s = %s %s %s\n",
            tac_table[i].result,
            tac_table[i].arg1,
            tac_table[i].op,
            tac_table[i].arg2);
    }
    
    printf("\n--- QUADRUPLES ---\n");
    printf("%-10s %-10s %-10s %-10s\n", "Operator", "Arg1", "Arg2", "Result");
    printf("----------------------------------------\n");
    for (i = 0; i < tac_index; i++) {
        printf("%-10s %-10s %-10s %-10s\n",
            tac_table[i].op,
            tac_table[i].arg1,
            tac_table[i].arg2,
            tac_table[i].result);
    }

    printf("\n--- TRIPLETS ---\n");
    printf("%-5s %-10s %-10s %-10s\n", "Index", "Operator", "Arg1", "Arg2");
    printf("----------------------------------\n");
    for (i = 0; i < tac_index; i++) {
        // For triplets, if an argument is a temporary, we refer to the index that generated it.
        char arg1_ref[10], arg2_ref[10];
        
        // Check if arg1 is a temporary
        if (tac_table[i].arg1[0] == 't') {
            sprintf(arg1_ref, "(%d)", atoi(tac_table[i].arg1 + 1));
        } else {
            strcpy(arg1_ref, tac_table[i].arg1);
        }

        // Check if arg2 is a temporary
        if (tac_table[i].arg2[0] == 't') {
            sprintf(arg2_ref, "(%d)", atoi(tac_table[i].arg2 + 1));
        } else {
            strcpy(arg2_ref, tac_table[i].arg2);
        }

        printf("%-5d %-10s %-10s %-10s\n", i, tac_table[i].op, arg1_ref, arg2_ref);
    }
}