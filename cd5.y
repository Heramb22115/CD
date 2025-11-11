%{
#include <stdio.h>
#include <stdlib.h>

int yylex();
void yyerror(const char *s);
int valid = 1;   // flag to track if expression is valid
%}

%token NUMBER

%left '+' '-'
%left '*' '/'

%%
input :
      E '\n'    { 
          if (valid) printf("Valid expression.\n");
          valid = 1;  /* Reset flag for next input */
      }
    ;

E : E '+' T
  | E '-' T
  | T
  ;

T : T '*' F
  | T '/' F
  | F
  ;

F : '(' E ')'
  | NUMBER
  ;
%%

void yyerror(const char *s) {
    valid = 0;
    printf("Error: syntax error\n");
}

int main() {
    printf("Enter an arithmetic expression:\n");
    yyparse();
    return 0;
}

