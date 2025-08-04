%{
int word_count = 0;
int vowel_count = 0;
int line_count = 0;
int char_count = 0;
%}

%%
\n          { line_count++; char_count++; }
[a-zA-Z]+   { 
                word_count++; 
                char_count += yyleng; 
                for(int i = 0; i < yyleng; i++) {
                    char c = tolower(yytext[i]);
                    if(c == 'a' || c == 'e' || c == 'i' || c == 'o' || c == 'u') {
                        vowel_count++;
                    }
                }
            }
.           { char_count++; }
%%

int yywrap() {
    printf("------------------------\n");
    printf("Total Lines      : %d\n", line_count);
    printf("Total Words      : %d\n", word_count);
    printf("Total Vowels     : %d\n", vowel_count);
    printf("Total Characters : %d\n", char_count);
    return 1; // End of processing
}

int main() {
    printf("Enter text (press Ctrl+D when done):\n");
    yylex();
    return 0;
}