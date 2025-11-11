%{
#include "y.tab.h"
#include <stdlib.h>
%}

%%
[0-9]+      { return NUMBER; }
[ \t]       ;        /* Ignore spaces and tabs */
\n          { return '\n'; }
"+"         { return '+'; }
"-"         { return '-'; }
"*"         { return '*'; }
"/"         { return '/'; }
"("         { return '('; }
")"         { return ')'; }
.           { printf("Invalid character: %s\n", yytext); }
%%

int yywrap() { return 1; }

//commands
lex cd5.l          
yacc -d cd5.y      
cc lex.yy.c y.tab.c
./a.out