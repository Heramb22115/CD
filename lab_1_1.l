%{
#include <stdio.h>
%}

%%
[0-9]      { printf("Digit: %s\n", yytext); }
[A-Za-z]   { printf("Character: %s\n", yytext); }
.          { /* ignore other characters */ }
%%