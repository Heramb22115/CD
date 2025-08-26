%{
#include "y.tab.h"
#include <math.h>

%}

%%
[0-9]+\.?|[0-9]*\.[0-9]+ { yylval.dval = atof(yytext); return NUMBER; }
sin { return SIN; }
cos { return COS; }
tan { return TAN; }
log { return LOG; }
[-+*/()\n] { return *yytext; }
[ \t] ; /* Skip whitespace */
. { yyerror("Invalid character"); }
%%

int yywrap(void) {
    return 1;
}
