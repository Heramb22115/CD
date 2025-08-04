%{
#include <stdio.h>
%}

%%
(cat|dog|table|city)         { printf("Noun: %s\n", yytext); }
(he|she|it|they|we|I|you)    { printf("Pronoun: %s\n", yytext); }
(run|eat|play|go|is|are)     { printf("Verb: %s\n", yytext); }
(big|small|beautiful|quick)  { printf("Adjective: %s\n", yytext); }
(quickly|slowly|well|badly)  { printf("Adverb: %s\n", yytext); }
(on|in|at|by|with|from)      { printf("Preposition: %s\n", yytext); }
.                            { /* ignore other tokens */ }
%%