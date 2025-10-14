%{
#include "y.tab.h"
#include <stdlib.h>
void yyerror(char *);
%}

%%
[a-zA-Z_][a-zA-Z0-9_]* { yylval.id = strdup(yytext); return ID; }
[0-9]+                  { yylval.id = strdup(yytext); return NUM; }
[-+*/=()]               { return yytext[0]; }
[ \t]                   ; /* Skip whitespace */
\n                      { return EOL; }   /* MODIFIED: Return an End-of-Line token */
<<EOF>>                 { return 0; }     /* ADDED: Proper end-of-file handling */
.                       { yyerror("Invalid character"); }
%%

int yywrap(void) {
    return 1;
}