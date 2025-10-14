%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(char *);
int yylex(void);

// C declarations are the same
typedef struct { char op[10], arg1[10], arg2[10], result[10]; } Tac;
Tac tac_table[100];
int tac_index = 0;
int temp_count = 0;

void print_code();

// Function to reset our tables for the next line of input
void reset_state() {
    tac_index = 0;
    temp_count = 0;
}

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
%}

/* Token declarations are the same */
%union { char* id; }
%token <id> ID NUM
%token EOL
%type <id> expr term factor
%left '+' '-'
%left '*' '/'
%right UMINUS

%%

program: /* empty */
       | program line
       ;

line: ID '=' expr opt_semi EOL {
          add_tac("=", $3, "", $1);
          print_code();
          reset_state();
      }
    | expr opt_semi EOL {
          printf("\n--- Expression Value is in: %s ---\n", $1);
          print_code();
          reset_state();
      }
    | EOL { /* Allow empty lines */ }
    | error EOL { yyerrok; reset_state(); }
    ;

opt_semi: ';'
        | /* empty */
        ;

/* CORRECTED RULES: Extra semicolons removed from inside the rules */
expr: expr '+' term { $$ = new_temp(); add_tac("+", $1, $3, $$); }
    | expr '-' term { $$ = new_temp(); add_tac("-", $1, $3, $$); }
    | term          { $$ = $1; }
    ;

term: term '*' factor { $$ = new_temp(); add_tac("*", $1, $3, $$); }
    | term '/' factor { $$ = new_temp(); add_tac("/", $1, $3, $$); }
    | factor        { $$ = $1; }
    ;

factor: '(' expr ')'    { $$ = $2; }
      | ID              { $$ = $1; }
      | NUM             { $$ = $1; }
      | '-' factor %prec UMINUS { $$ = new_temp(); add_tac("UMINUS", $2, "", $$); }
      ;

%%

/* The main(), print_code(), and yyerror() functions are unchanged */
int main() {
    printf("Enter an expression (or Ctrl+D to exit):\n");
    yyparse();
    printf("\nExiting.\n");
    return 0;
}

void yyerror(char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

void print_code() {
    int i;
    if (tac_index == 0) return;

    printf("--- THREE-ADDRESS CODE ---\n");
    for (i = 0; i < tac_index; i++) {
        if (strcmp(tac_table[i].op, "UMINUS") == 0 || strcmp(tac_table[i].op, "=") == 0) {
            printf("%s = %s %s\n", tac_table[i].result, tac_table[i].op, tac_table[i].arg1);
        } else {
            printf("%s = %s %s %s\n", tac_table[i].result, tac_table[i].arg1, tac_table[i].op, tac_table[i].arg2);
        }
    }
    printf("\n--- QUADRUPLES ---\n");
    printf("%-10s %-10s %-10s %-10s\n", "Operator", "Arg1", "Arg2", "Result");
    for (i = 0; i < tac_index; i++) {
        printf("%-10s %-10s %-10s %-10s\n", tac_table[i].op, tac_table[i].arg1, tac_table[i].arg2, tac_table[i].result);
    }
    printf("\n--- TRIPLETS ---\n");
    printf("%-5s %-10s %-10s %-10s\n", "Index", "Operator", "Arg1", "Arg2");
    for (i = 0; i < tac_index; i++) {
        char arg1_ref[10], arg2_ref[10];
        if (tac_table[i].arg1[0] == 't') sprintf(arg1_ref, "(%d)", atoi(tac_table[i].arg1 + 1));
        else strcpy(arg1_ref, tac_table[i].arg1);
        if (tac_table[i].arg2[0] == '\0') strcpy(arg2_ref, "");
        else if (tac_table[i].arg2[0] == 't') sprintf(arg2_ref, "(%d)", atoi(tac_table[i].arg2 + 1));
        else strcpy(arg2_ref, tac_table[i].arg2);
        printf("%-5d %-10s %-10s %-10s\n", i, tac_table[i].op, arg1_ref, arg2_ref);
    }
    printf("----------------------------------\n");
}