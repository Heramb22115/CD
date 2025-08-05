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

"auto"      { printf("KEYWORD:\t\t%s\n", yytext); }
"break"     { printf("KEYWORD:\t\t%s\n", yytext); }
"case"      { printf("KEYWORD:\t\t%s\n", yytext); }
"char"      { printf("KEYWORD:\t\t%s\n", yytext); }
"const"     { printf("KEYWORD:\t\t%s\n", yytext); }
"continue"  { printf("KEYWORD:\t\t%s\n", yytext); }
"default"   { printf("KEYWORD:\t\t%s\n", yytext); }
"do"        { printf("KEYWORD:\t\t%s\n", yytext); }
"double"    { printf("KEYWORD:\t\t%s\n", yytext); }
"else"      { printf("KEYWORD:\t\t%s\n", yytext); }
"enum"      { printf("KEYWORD:\t\t%s\n", yytext); }
"extern"    { printf("KEYWORD:\t\t%s\n", yytext); }
"float"     { printf("KEYWORD:\t\t%s\n", yytext); }
"for"       { printf("KEYWORD:\t\t%s\n", yytext); }
"goto"      { printf("KEYWORD:\t\t%s\n", yytext); }
"if"        { printf("KEYWORD:\t\t%s\n", yytext); }
"int"       { printf("KEYWORD:\t\t%s\n", yytext); }
"long"      { printf("KEYWORD:\t\t%s\n", yytext); }
"register"  { printf("KEYWORD:\t\t%s\n", yytext); }
"return"    { printf("KEYWORD:\t\t%s\n", yytext); }
"short"     { printf("KEYWORD:\t\t%s\n", yytext); }
"signed"    { printf("KEYWORD:\t\t%s\n", yytext); }
"sizeof"    { printf("KEYWORD:\t\t%s\n", yytext); }
"static"    { printf("KEYWORD:\t\t%s\n", yytext); }
"struct"    { printf("KEYWORD:\t\t%s\n", yytext); }
"switch"    { printf("KEYWORD:\t\t%s\n", yytext); }
"typedef"   { printf("KEYWORD:\t\t%s\n", yytext); }
"union"     { printf("KEYWORD:\t\t%s\n", yytext); }
"unsigned"  { printf("KEYWORD:\t\t%s\n", yytext); }
"void"      { printf("KEYWORD:\t\t%s\n", yytext); }
"volatile"  { printf("KEYWORD:\t\t%s\n", yytext); }
"while"     { printf("KEYWORD:\t\t%s\n", yytext); }

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
    
    yylex();
    
    fclose(fp);
    
    return 0;
}