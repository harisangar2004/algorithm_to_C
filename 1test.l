%{
#include "y.tab.h"
#include <string.h>
#include <stdlib.h>
%}

%%
start                   { return START; }
declare                 { return DECLARE; }
int                     { return INT; }
assign                  { return ASSIGN; }
to                      { return TO; }
print                   { return PRINT; }
end                     { return END; }  // Add rule to recognize 'end'
[0-9]+                  { yylval.num = atoi(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z_0-9]*  { yylval.str = strdup(yytext); return IDENTIFIER; }
\+                      { return PLUS; }  // Rule to handle the '+' character
\-                      { return MINUS; }  // Rule to handle the '-' character
\*                      { return MULT; }   // Rule to handle the '*' character
\/                      { return DIV; }    // Rule to handle the '/' character
[ \t\n]                 { /* Ignore whitespace */ }
.                       { printf("Unknown character: %s\n", yytext); return yytext[0]; }
%%

int yywrap() {
    return 1;
}
