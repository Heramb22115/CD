%{
#include <stdio.h>
%}

DIGIT       [0-9]
LETTER      [a-zA-Z_]
ID          {LETTER}({LETTER}|{DIGIT})*
INTEGER     {DIGIT}+
FLOAT       {DIGIT}+\.{DIGIT}+([eE][+-]?{DIGIT}+)?

%%

"/*"([^*]|\*+[^*/])*\*+"/"  { }
"//".* { }
[ \t\n]+                     { }

"auto"      | "break"    | "case"     | "char"     | "const"    |
"continue"  | "default"  | "do"       | "double"   | "else"     |
"enum"      | "extern"   | "float"    | "for"      | "goto"     |
"if"        | "int"      | "long"     | "register" | "return"   |
"short"     | "signed"   | "sizeof"   | "static"   | "struct"   |
"switch"    | "typedef"  | "union"    | "unsigned" | "void"     |
"volatile"  | "while"    { printf("KEYWORD:\t\t%s\n", yytext); }

{FLOAT}     { printf("CONSTANT (FLOAT):\t%s\n", yytext); }
{INTEGER}   { printf("CONSTANT (INTEGER):\t%s\n", yytext); }
'(\\.|[^'\\])' { printf("CONSTANT (CHAR):\t%s\n", yytext); }
\"(\\.|[^"\\])*\" { printf("STRING LITERAL:\t%s\n", yytext); }

{ID}        { printf("IDENTIFIER:\t\t%s\n", yytext); }

"++" | "--" | "==" | "!=" | ">=" | "<=" | "&&" | "||" |
"+=" | "-=" | "*=" | "/=" | "%=" | "&=" | "^=" | "|=" |
"<<" | ">>" | "->" | "..." { printf("OPERATOR:\t\t%s\n", yytext); }
"+" | "-" | "*" | "/" | "%" | "<" | ">" | "=" | "&" | "|" |
"^" | "!" | "~" | "?" | ":" | "." { printf("OPERATOR:\t\t%s\n", yytext); }

";" | "," | "(" | ")" | "{" | "}" | "[" | "]" { printf("SPECIAL SYMBOL:\t%s\n", yytext); }

^#.* { printf("PREPROCESSOR:\t%s\n", yytext); }

.           { printf("UNRECOGNIZED:\t%s\n", yytext); }

%%

extern FILE *yyin;

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    FILE *fp = fopen(argv[1], "r");
    if (!fp) {
        perror(argv[1]);
        return 1;
    }

    yyin = fp;

    printf("--- Starting Tokenization of %s ---\n", argv[1]);

    yylex();

    printf("--- Tokenization Complete ---\n");

    fclose(fp);

    return 0;
}