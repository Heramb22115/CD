%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex();
void yyerror(const char *s);
/* Structures for Quadruple and Triple representation */
struct Quadruple {
    char op[5];
    char arg1[10];
    char arg2[10];
    char result[10];
};
struct Triple {
    char op[5];
    char arg1[10];
    char arg2[10];
};
struct Quadruple q[20];
struct Triple t[20];
int qIndex = 0;
int tempCount = 1;
char *newTemp() {
    static char temp[5];
    sprintf(temp, "t%d", tempCount++);
    return strdup(temp);
}
%}

%union {
    char *str;
}

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
        /* Generate Quadruple for assignment */
        strcpy(q[qIndex].op, "=");
        strcpy(q[qIndex].arg1, $3); /* Source (result of expr) */
        strcpy(q[qIndex].arg2, "-");
        strcpy(q[qIndex].result, $1); /* Destination (ID) */

        /* --- FIX 1: Added Triple generation for assignment --- */
        strcpy(t[qIndex].op, "=");
        strcpy(t[qIndex].arg1, $3);
        strcpy(t[qIndex].arg2, $1);

        qIndex++;

        /* --- Print both tables --- */
        printf("\nQuadruple Representation:\n");
        printf("Index\tOp\tArg1\tArg2\tResult\n");
        for (int i = 0; i < qIndex; i++) {
            printf("%d\t%s\t%s\t%s\t%s\n", i, q[i].op, q[i].arg1, q[i].arg2, q[i].result);
        }

        printf("\nTriple Representation:\n");
        printf("Index\tOp\tArg1\tArg2\n");
        /* --- FIX 2: Changed print loop to use Triple array 't' --- */
        for (int i = 0; i < qIndex; i++) {
            printf("%d\t%s\t%s\t%s\n", i, t[i].op, t[i].arg1, t[i].arg2);
        }
        
        /* Free dynamically allocated strings */
        free($1);
        free($3);
    }
    ;

expr:
    expr PLUS expr {
        char *temp = newTemp();
        strcpy(q[qIndex].op, "+");
        strcpy(q[qIndex].arg1, $1);
        strcpy(q[qIndex].arg2, $3);
        strcpy(q[qIndex].result, temp);

        strcpy(t[qIndex].op, "+");
        strcpy(t[qIndex].arg1, $1);
        strcpy(t[qIndex].arg2, $3);
        
        qIndex++;
        $$ = temp;
        free($1); free($3);
    }
    | expr MINUS expr {
        char *temp = newTemp();
        strcpy(q[qIndex].op, "-");
        strcpy(q[qIndex].arg1, $1);
        strcpy(q[qIndex].arg2, $3);
        strcpy(q[qIndex].result, temp);
        
        strcpy(t[qIndex].op, "-");
        strcpy(t[qIndex].arg1, $1);
        strcpy(t[qIndex].arg2, $3);
        
        qIndex++;
        $$ = temp;
        free($1); free($3);
    }
    | expr MUL expr {
        char *temp = newTemp();
        strcpy(q[qIndex].op, "*");
        strcpy(q[qIndex].arg1, $1);
        strcpy(q[qIndex].arg2, $3);
        strcpy(q[qIndex].result, temp);
        
        strcpy(t[qIndex].op, "*");
        strcpy(t[qIndex].arg1, $1);
        strcpy(t[qIndex].arg2, $3);
        
        qIndex++;
        $$ = temp;
        free($1); free($3);
    }
    | expr DIV expr {
        char *temp = newTemp();
        strcpy(q[qIndex].op, "/");
        strcpy(q[qIndex].arg1, $1);
        strcpy(q[qIndex].arg2, $3);
        strcpy(q[qIndex].result, temp);
        
        strcpy(t[qIndex].op, "/");
        strcpy(t[qIndex].arg1, $1);
        strcpy(t[qIndex].arg2, $3);
        
        qIndex++;
        $$ = temp;
        free($1); free($3);
    }
    | LPAREN expr RPAREN {
        $$ = $2; /* Pass the result of the inner expression */
    }
    | MINUS expr %prec UMINUS {
        char *temp = newTemp();
        strcpy(q[qIndex].op, "~"); /* Using ~ for Unary Minus */
        strcpy(q[qIndex].arg1, $2);
        strcpy(q[qIndex].arg2, "-");
        strcpy(q[qIndex].result, temp);
        
        strcpy(t[qIndex].op, "~");
        strcpy(t[qIndex].arg1, $2);
        strcpy(t[qIndex].arg2, "-");
        
        qIndex++;
        $$ = temp;
        free($2);
    }
    | ID { 
        $$ = $1; /* $1 is strdup'd in lexer */
    }
    | NUM { 
        $$ = $1; /* $1 is strdup'd in lexer */
    }
    ;

%%
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    printf("Enter an arithmetic expression (e.g., a = b * c + d):\n");
    yyparse();
    return 0;
}