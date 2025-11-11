%{
#include <stdio.h>
#include <stdlib.h>
int yylex(void);
void yyerror(const char *s);
%}

%union {
    int ival;
}

%token <ival> NUMBER
%type <ival> E T F
%%

program:
    | program line
;

line:
    '\n'        { printf("> "); }
    | E '\n'    { 
                    printf("= %d\n", $1); 
                    printf("> ");
                }
    | error '\n' { 
                    printf("> ");
                }
;

E   : E '+' T   { $$ = $1 + $3; }
    | E '-' T   { $$ = $1 - $3; }
    | T         { $$ = $1; }
    ;

T   : T '*' F   { $$ = $1 * $3; }
    | T '/' F   { 
                    if ($3 == 0) {
                        yyerror("Division by zero");
                        $$ = 0;
                    } else {
                        $$ = $1 / $3;
                    }
                }
    | F         { $$ = $1; }
    ;

F   : '(' E ')' { $$ = $2; }
    | NUMBER    { $$ = $1; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    printf("Enter an arithmetic expression (Ctrl+D to quit):\n");
    printf("> ");
    yyparse();
    return 0;
}