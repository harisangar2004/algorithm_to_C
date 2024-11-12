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
%token <str> IF THEN LT GT ELSE                                                                                                                                         
%token <str> WHILE DO ENDWHILE                                                                                                                                          
%token CREATE FUNCTION WITH PARAMETERS RETURN COMMA                                                                                                                     
%token <num> NUMBER                                                                                                                                                     
%token PLUS MINUS MULT DIV // Declare the new tokens for the operators                                                                                                  
%token END                                                                                                                                                              
                                                                                                                                                                        
%type <str> program declarations declaration statements statement expression                                                                                            
%type <str> loop_stmt if_stmt while_stmt                                                                                                                                
%type <str> condition                                                                                                                                                   
%type <str>  function_defn                                                                                                                                              
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
        char *temp = malloc(1000);                                                                                                                                      
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
        | if_stmt                                                                                                                                                       
        {                                                                                                                                                               
                printf("%s",$1);                                                                                                                                        
        }                                                                                                                                                               
        | while_stmt                                                                                                                                                    
        {                                                                                                                                                               
                printf("%s",$1);                                                                                                                                        
        }                                                                                                                                                               
        | function_defn{                                                                                                                                                
                printf("%s",$1);                                                                                                                                        
        }                                                                                                                                                               
;                                                                                                                                                                       
                                                                                                                                                                        
loop_stmt:                                                                                                                                                              
        FOR IDENTIFIER RANGE NUMBER NUMBER INCR BY NUMBER statement ENDFOR                                                                                              
        {                                                                                                                                                               
                char buffer[100];                                                                                                                                       
                sprintf(buffer,"for(int %s=%d;%s<%d;%s=%s+%d){\n\t%s}\n",$2,$4,$2,$5,$2,$2,$8,$9);                                                                      
                $$=strdup(buffer);                                                                                                                                      
        }                                                                                                                                                               
                                                                                                                                                                        
;                                                                                                                                                                       
if_stmt:                                                                                                                                                                
       IF condition THEN statement ELSE statement{                                                                                                                      
                printf("if(%s) {\n",$2);                                                                                                                                
                printf("\t%s",$4);                                                                                                                                      
                printf("} else {\n");                                                                                                                                   
                printf("\t%s",$6);                                                                                                                                      
                printf("}\n");                                                                                                                                          

                char buffer[500];                                                                                                                                       
                sprintf(buffer,"if(%s){\n\t%s} else {\n\t%s}\n",$2,$4,$6);                                                                                              
                $$=strdup(buffer);                                                                                                                                      
        }                                                                                                                                                               
;                                                                                                                                                                       
while_stmt:                                                                                                                                                             
          WHILE IDENTIFIER LT NUMBER DO statements INCR BY NUMBER ENDWHILE{                                                                                             
                printf("while(%s<%d){\n\t%s\n%s=%s+%d;\n}",$2,$4,$6,$2,$2,$9);                                                                                          
                char buffer[500];                                                                                                                                       
                sprintf(buffer,"while(%s<%d){\n\t%s\n%s=%s+%d;\n}",$2,$4,$6,$2,$2,$9 );                                                                                 
                $$=strdup(buffer);                                                                                                                                      
}                                                                                                                                                                       
function_defn:                                                                                                                                                          
             CREATE FUNCTION IDENTIFIER WITH PARAMETERS INT IDENTIFIER COMMA INT IDENTIFIER declarations statements RETURN IDENTIFIER{                                  
                printf("int %s(int %s, int %s) {\n", $3, $7, $10);                                                                                                      
                printf("    %s\n%s", $11,$12);                                                                                                                          
                printf("    return %s;\n", $14);                                                                                                                        
                printf("}\n");                                                                                                                                          
                char buffer[700];                                                                                                                                       
                sprintf(buffer,"int %s(int %s, int %s) {\n\t %s\n%s\t return %s;\n }\n", $3, $7, $10,$11,$12,$14);                                                      
                $$=strdup(buffer);                                                                                                                                      
}                                                                                                                                                                       
condition:                                                                                                                                                              
         IDENTIFIER LT NUMBER{                                                                                                                                          
                $$=malloc(200);
                if($$==NULL){                                                                                                                                           
                        fprintf(stderr,"Mem allocation failure");                                                                                                       
                        exit(EXIT_FAILURE);                                                                                                                             
                }                                                                                                                                                       
                sprintf($$,"%s < %d",$1,$3);                                                                                                                            
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
                                                                                                                                                                        
    outfile = fopen("whileop.c", "w"); // Open the output file                                                                                                          
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
