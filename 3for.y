%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex();

extern FILE *yyin; // Declare yyin for file handling
FILE *outfile;
%}

%union {
    char *str;
    int num;
}

%token <str> START DECLARE INT ASSIGN TO PRINT IDENTIFIER STRING
%token FOR RANGE INCR BY ENDFOR
%token <num> NUMBER
%token PLUS MINUS MULT DIV // Declare the new tokens for the operators
%token END

%type <str> program declarations declaration statements statement expression
%type <str> loop_stmt

%%
program:
    START declarations statements END
    {
        fprintf(outfile, "#include<stdio.h>\nvoid main() {\n");
        fprintf(outfile, "%s", $2);
        fprintf(outfile, "%s", $3);
        fprintf(outfile, "}\n");
    }
;

declarations:
    declarations declaration
    {
        char *temp = malloc(100);
        sprintf(temp, "%sint %s;\n", $1, $2);
        $$ = temp;
        free($1);
    }
    | declaration
    {
        char *temp = malloc(100);
        sprintf(temp, "int %s;\n", $1);
        $$ = temp;
    }
;

declaration:
    DECLARE INT IDENTIFIER
    {
        $$ = strdup($3);
    }
;

statements:
    statements statement
    {
        char *temp = malloc(100);
        sprintf(temp, "%s%s", $1, $2);
        $$ = temp;
        free($1);
        free($2);
    }
    | statement
    {
        $$ = $1;
    }
;

statement:
    ASSIGN IDENTIFIER TO NUMBER
    {
        char *temp = malloc(100);
        sprintf(temp, "%s = %d;\n", $2, $4);
        $$ = temp;
    }
    | PRINT expression
    {
        char *temp = malloc(100);
        sprintf(temp, "printf(\"%%d\", %s);\n", $2);
        $$ = temp;
        free($2);
    }
        | PRINT STRING
        {
                char *temp=malloc(100);
                sprintf(temp,"printf(%s);\n",$2);
                $$=temp;
                free($2);
        }
        | loop_stmt
        {
                printf("%s",$1);
        }

;

loop_stmt:
        FOR IDENTIFIER RANGE NUMBER NUMBER INCR BY NUMBER statement ENDFOR
        {
                char buffer[100];
                sprintf(buffer,"for(int %s=%d;%s<%d;%s=%s+%d){\n%s\n}\n",$2,$4,$2,$5,$2,$2,$8,$9);
                $$=strdup(buffer);
        }

;

expression:
    IDENTIFIER PLUS IDENTIFIER
    {
        $$ = malloc(100);
        sprintf($$, "%s + %s", $1, $3);
        free($1);
        free($3);
    }
    | IDENTIFIER MINUS IDENTIFIER
    {
        $$ = malloc(100);
        sprintf($$, "%s - %s", $1, $3);
        free($1);
        free($3);
    }
    | IDENTIFIER MULT IDENTIFIER
    {
        $$ = malloc(100);
        sprintf($$, "%s * %s", $1, $3);
        free($1);
        free($3);
    }
    | IDENTIFIER DIV IDENTIFIER
    {
        $$ = malloc(100);
        sprintf($$, "%s / %s", $1, $3);
        free($1);
        free($3);
    }
    | IDENTIFIER
    {
        $$ = strdup($1);
    }
    | NUMBER
    {
        char *temp = malloc(10);
        sprintf(temp, "%d", $1);
        $$ = temp;
    }
;
%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        yyin = stdin;  // Read from standard input if no file argument is provided
    } else {
        yyin = fopen(argv[1], "r");  // Open the specified input file
        if (!yyin) {
            perror("Failed to open input file");
            exit(1);
        }
    }

    outfile = fopen("output2.c", "w"); // Open the output file
    if (!outfile) {
        perror("Failed to open output file");
        exit(1);
    }

    yyparse();

    fclose(yyin);
    fclose(outfile);

    printf("C code generated in output.c\n");
    return 0;
}
