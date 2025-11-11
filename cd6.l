%{
#include "y.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

%%
[a-zA-Z][a-zA-Z0-9]*   { yylval.str = strdup(yytext); return ID; }
[0-9]+                 { yylval.str = strdup(yytext); return NUM; }
"="                    { return ASSIGN; }
"*"                    { return MUL; }
"/"                    { return DIV; }
"+"                    { return PLUS; }
"-"                    { return MINUS; }
"("                    { return LPAREN; }
")"                    { return RPAREN; }
[ \t\n]                ;
.                      { printf("Invalid character: %s\n", yytext); }
%%
int yywrap() { return 1; }

