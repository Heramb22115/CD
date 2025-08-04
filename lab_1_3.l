%{
#include <stdio.h>
int word=0, vowel=0, line=0, ch=0;
%}

%%
[ \t\n]        { ch++; if(yytext[0]=='\n') line++; }
[aeiouAEIOU]   { vowel++; ch++; }
[^\n \t]       { ch++; }
[^\n \t]+      { word++; }
%%

int main() {
    yylex();
    printf("Words: %d\nVowels: %d\nLines: %d\nCharacters: %d\n", word, vowel, line+1, ch);
    return 0;
}