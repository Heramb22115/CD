%{
#include <stdio.h>
#define FIND "hello"
#define REPLACE "hi"
%}

%%
{FIND}    { printf(REPLACE); }
.|\n      { ECHO; }
%%

int main(int argc, char *argv[]) {
    if(argc > 1) {
        FILE *fp = fopen(argv[1], "r");
        if(fp) {
            yyin = fp;
            yylex();
            fclose(fp);
        }
    } else {
        yylex();
    }
    return 0;
}