%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
int yylex();
void yyerror(const char *s) { fprintf(stderr, "Error: %s\n", s); }
%}

%union {
    double dval;
}

%token <dval> NUMBER
%token SIN COS TAN LOG POW EXP SQRT ASIN ACOS ATAN ABS

%type <dval> expr

%left '+' '-'
%left '*' '/'
%right UMINUS

%%

lines
    : lines expr '\n'    { printf("= %g\n", $2); }
    | lines '\n'
    | /* empty */
    ;

expr
    : expr '+' expr          { $$ = $1 + $3; }
    | expr '-' expr          { $$ = $1 - $3; }
    | expr '*' expr          { $$ = $1 * $3; }
    | expr '/' expr          {
                                  if ($3 == 0.0) {
                                      yyerror("Division by zero");
                                      $$ = 0;
                                  } else {
                                      $$ = $1 / $3;
                                  }
                              }
    | '(' expr ')'           { $$ = $2; }
    | '-' expr %prec UMINUS  { $$ = -$2; }
    | NUMBER                  { $$ = $1; }
    | SIN '(' expr ')'        { $$ = sin($3); }
    | COS '(' expr ')'        { $$ = cos($3); }
    | TAN '(' expr ')'        { $$ = tan($3); }
    | LOG '(' expr ')'        {
                                  if ($3 <= 0.0) {
                                      yyerror("Logarithm of non-positive number");
                                      $$ = 0;
                                  } else {
                                      $$ = log10($3);
                                  }
                              }
    | EXP '(' expr ')'        { $$ = exp($3); }
    | SQRT '(' expr ')'       {
                                  if ($3 < 0.0) {
                                      yyerror("Square root of negative number");
                                      $$ = 0;
                                  } else {
                                      $$ = sqrt($3);
                                  }
                              }
    | ASIN '(' expr ')'       { $$ = asin($3); }
    | ACOS '(' expr ')'       { $$ = acos($3); }
    | ATAN '(' expr ')'       { $$ = atan($3); }
    | ABS '(' expr ')'        { $$ = fabs($3); }
    | POW '(' expr ',' expr ')' { $$ = pow($3, $5); }
    ;

%%

int yylex() {
    int c;

    while ((c = getchar()) == ' ' || c == '\t');

    if (isalpha(c)) {
        char sbuf[100];
        int i = 0;
        do {
            sbuf[i++] = c;
        } while ((c = getchar()) != EOF && isalpha(c));
        ungetc(c, stdin);
        sbuf[i] = '\0';

        if (strcmp(sbuf, "sin") == 0) return SIN;
        if (strcmp(sbuf, "cos") == 0) return COS;
        if (strcmp(sbuf, "tan") == 0) return TAN;
        if (strcmp(sbuf, "log") == 0) return LOG;
        if (strcmp(sbuf, "exp") == 0) return EXP;
        if (strcmp(sbuf, "sqrt") == 0) return SQRT;
        if (strcmp(sbuf, "asin") == 0) return ASIN;
        if (strcmp(sbuf, "acos") == 0) return ACOS;
        if (strcmp(sbuf, "atan") == 0) return ATAN;
        if (strcmp(sbuf, "abs") == 0) return ABS;
        if (strcmp(sbuf, "pow") == 0) return POW;

        yyerror("Unknown function");
        return 0;
    }

    if (isdigit(c) || c == '.') {
        ungetc(c, stdin);
        double val;

        if (scanf("%lf", &val) == 1) {
            yylval.dval = val;
            return NUMBER;
        }
    }

    if (c == EOF) return 0;
    return c;
}

int main() {
    printf("Scientific Calculator (type expressions, one per line):\n");
    return yyparse();
}
