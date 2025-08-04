%{
#include <stdio.h>
#include <ctype.h>
%}

%%
[A-Z]+    { // Lowercase
             for(int i=0; yytext[i]; i++) putchar(tolower(yytext[i]));
           }
[a-z]+    { // Uppercase
             for(int i=0; yytext[i]; i++) putchar(toupper(yytext[i]));
           }
.|\n      { putchar(*yytext); }
%%

int main() {
    yylex();
    return 0;
}