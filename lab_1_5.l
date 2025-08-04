%{
#include <stdio.h>
#include <ctype.h>
%}

%%
[a-zA-Z]+   {
                for(int i = 0; i < yyleng; i++) {
                    if(islower(yytext[i])) {
                        printf("%c", toupper(yytext[i]));
                    } else if(isupper(yytext[i])) {
                        printf("%c", tolower(yytext[i]));
                    }
                }
            }
.|\n        { ECHO; } // Print all other characters (spaces, punctuation) as is
%%

int main() {
    printf("Enter text to toggle case: ");
    yylex();
    return 0;
}

int yywrap() {
    return 1;
}