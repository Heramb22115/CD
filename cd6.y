%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
void yyerror(const char *s);

struct Quadruple {
    char op[5], arg1[20], arg2[20], result[20];
};
struct Triple {
    char op[5], arg1[20], arg2[20];
};

struct Quadruple q[20];
struct Triple t[20];
int qIndex = 0, tempCount = 1;

char *newTemp() {
    static char temp[10];
    sprintf(temp, "t%d", tempCount++);
    return strdup(temp);
}
%}

%union { char *str; }

%token <str> ID NUM
%token ASSIGN PLUS MINUS MUL DIV LPAREN RPAREN
%left PLUS MINUS
%left MUL DIV
%right UMINUS
%type <str> expr
%start statement

%%
statement:
      ID ASSIGN expr {
          strcpy(q[qIndex].op, "=");
          strcpy(q[qIndex].arg1, $3);
          strcpy(q[qIndex].arg2, "-");
          strcpy(q[qIndex].result, $1);
          qIndex++;

          printf("\nQuadruple Representation:\n");
          printf("Index\tOp\tArg1\tArg2\tResult\n");
          for (int i = 0; i < qIndex; i++)
              printf("%d\t%s\t%s\t%s\t%s\n", i, q[i].op, q[i].arg1, q[i].arg2, q[i].result);

          printf("\nTriple Representation:\n");
          printf("Index\tOp\tArg1\tArg2\n");
          for (int i = 0; i < qIndex; i++)
              printf("%d\t%s\t%s\t%s\n", i, q[i].op, q[i].arg1, q[i].arg2);
      }
    ;

expr:
      expr PLUS expr { /* + */ 
          char *temp = newTemp();
          strcpy(q[qIndex].op, "+");
          strcpy(q[qIndex].arg1, $1);
          strcpy(q[qIndex].arg2, $3);
          strcpy(q[qIndex].result, temp);
          strcpy(t[qIndex].op, "+");
          strcpy(t[qIndex].arg1, $1);
          strcpy(t[qIndex].arg2, $3);
          qIndex++; $$ = temp;
      }
    | expr MINUS expr { /* - */
          char *temp = newTemp();
          strcpy(q[qIndex].op, "-");
          strcpy(q[qIndex].arg1, $1);
          strcpy(q[qIndex].arg2, $3);
          strcpy(q[qIndex].result, temp);
          strcpy(t[qIndex].op, "-");
          strcpy(t[qIndex].arg1, $1);
          strcpy(t[qIndex].arg2, $3);
          qIndex++; $$ = temp;
      }
    | expr MUL expr { /* * */
          char *temp = newTemp();
          strcpy(q[qIndex].op, "*");
          strcpy(q[qIndex].arg1, $1);
          strcpy(q[qIndex].arg2, $3);
          strcpy(q[qIndex].result, temp);
          strcpy(t[qIndex].op, "*");
          strcpy(t[qIndex].arg1, $1);
          strcpy(t[qIndex].arg2, $3);
          qIndex++; $$ = temp;
      }
    | expr DIV expr { /* / */
          char *temp = newTemp();
          strcpy(q[qIndex].op, "/");
          strcpy(q[qIndex].arg1, $1);
          strcpy(q[qIndex].arg2, $3);
          strcpy(q[qIndex].result, temp);
          strcpy(t[qIndex].op, "/");
          strcpy(t[qIndex].arg1, $1);
          strcpy(t[qIndex].arg2, $3);
          qIndex++; $$ = temp;
      }
    | LPAREN expr RPAREN { $$ = $2; }
    | MINUS expr %prec UMINUS {
          char *temp = newTemp();
          strcpy(q[qIndex].op, "~");
          strcpy(q[qIndex].arg1, $2);
          strcpy(q[qIndex].arg2, "-");
          strcpy(q[qIndex].result, temp);
          strcpy(t[qIndex].op, "~");
          strcpy(t[qIndex].arg1, $2);
          strcpy(t[qIndex].arg2, "-");
          qIndex++; $$ = temp;
      }
    | ID  { $$ = strdup($1); }
    | NUM { $$ = strdup($1); }
    ;
%%

void yyerror(const char *s) { fprintf(stderr, "Error: %s\n", s); }

int main() {
    printf("Enter an arithmetic expression:\n");
    yyparse();
    return 0;
}
