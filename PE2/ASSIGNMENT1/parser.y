%{
/*
 * parser.y - Extended Bison Grammar (Assignment 1)
 *
 * New features over PE2:
 *   - for loops  : for(i=0, j=0; i<p && j<q; i++, j++)
 *   - while loops: while (expr) stmt
 *   - switch     : switch(expr) { case NUM: ... default: ... }
 *   - Arrays     : int a[15]; int a[10][10]; int a[4][4], b[5];
 *   - Variable declaration with init: int a=5, b, c, d=10;
 *   - ++/-- and +=/-= operators
 *   - && and || logical operators
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int  yylineno;
extern int  yylex(void);
extern char *yytext;

void yyerror(const char *msg) {
    fprintf(stderr,
        "Syntax error at line %d, token : '%s'\n",
        yylineno, yytext);
}
%}

%union {
    char *str;
}

/* ── Tokens ── */
%token <str> ID NUM
%token INT FLOAT CHAR DOUBLE
%token IF ELSE DO WHILE FOR
%token SWITCH CASE DEFAULT BREAK
%token INC DEC ADDASSIGN SUBASSIGN
%token EQ NEQ LE GE LT GT AND OR

/* ── Precedence (low → high) ── */
%left  OR
%left  AND
%left  EQ NEQ
%left  LT GT LE GE
%left  '+' '-'
%left  '*' '/' '%'
%right UMINUS
%right INC DEC

%%

/* ── Program ── */
program
    : stmt_list
    ;

stmt_list
    : /* empty */
    | stmt_list stmt
    ;

/* ================================================================
   Statements
   ================================================================ */
stmt
    : decl_stmt
    | if_stmt
    | do_while_stmt
    | while_stmt
    | for_stmt
    | switch_stmt
    | block
    | expr_stmt
    | BREAK ';'
    ;

/* ================================================================
   Variable Declarations
   Supports: int a=5, b, c, d=10;
             int arr[10];
             int arr[10][10];
             int a[4][4], b[5];
   ================================================================ */
decl_stmt
    : type declarator_list ';'
    ;

type
    : INT
    | FLOAT
    | CHAR
    | DOUBLE
    ;

declarator_list
    : declarator
    | declarator_list ',' declarator
    ;

/* Each declarator: plain var, initialised var, or array (any dims) */
declarator
    : ID
    | ID '=' expr
    | ID dim_list
    | ID dim_list '=' expr
    ;

/* One or more array dimension brackets: [N], [N][M], [N][M][P]... */
dim_list
    : '[' NUM ']'
    | dim_list '[' NUM ']'
    ;

/* ================================================================
   if / if-else
   ================================================================ */
if_stmt
    : IF '(' expr ')' stmt %prec ELSE
    | IF '(' expr ')' stmt ELSE stmt
    ;

/* ================================================================
   do-while
   ================================================================ */
do_while_stmt
    : DO stmt WHILE '(' expr ')' ';'
    ;

/* ================================================================
   while
   ================================================================ */
while_stmt
    : WHILE '(' expr ')' stmt
    ;

/* ================================================================
   for loop
   Supports:
     for (i=0; i<n; i++)
     for (i=0, j=0; i<p && j<q; i++, j++)
     for (;;)   (all parts optional)
   ================================================================ */
for_stmt
    : FOR '(' for_init ';' for_cond ';' for_update ')' stmt
    ;

/* init: empty or comma-separated assignments / declarations */
for_init
    : /* empty */
    | for_init_list
    ;

for_init_list
    : for_init_item
    | for_init_list ',' for_init_item
    ;

for_init_item
    : ID '=' expr          /* i=0           */
    | type ID '=' expr     /* int i=0  (C99 style) */
    | type ID              /* int i            */
    ;

/* condition: empty or expression */
for_cond
    : /* empty */
    | expr
    ;

/* update: empty or comma-separated update expressions */
for_update
    : /* empty */
    | for_update_list
    ;

for_update_list
    : for_update_item
    | for_update_list ',' for_update_item
    ;

for_update_item
    : ID INC               /* i++  */
    | ID DEC               /* i--  */
    | INC ID               /* ++i  */
    | DEC ID               /* --i  */
    | ID ADDASSIGN expr    /* i += n */
    | ID SUBASSIGN expr    /* i -= n */
    | ID '=' expr          /* i = expr */
    ;

/* ================================================================
   switch statement
   switch (expr) {
       case NUM : stmt_list
       default  : stmt_list
   }
   ================================================================ */
switch_stmt
    : SWITCH '(' expr ')' '{' case_list '}'
    ;

case_list
    : /* empty */
    | case_list case_clause
    ;

case_clause
    : CASE NUM ':' stmt_list
    | CASE ID  ':' stmt_list
    | DEFAULT  ':' stmt_list
    ;

/* ================================================================
   Block
   ================================================================ */
block
    : '{' stmt_list '}'
    ;

/* ================================================================
   Expression statement
   ================================================================ */
expr_stmt
    : ID '=' expr ';'
    | ID ADDASSIGN expr ';'
    | ID SUBASSIGN expr ';'
    | ID INC ';'
    | ID DEC ';'
    | expr ';'
    ;

/* ================================================================
   Expressions
   ================================================================ */
expr
    /* Arithmetic */
    : expr '+' expr
    | expr '-' expr
    | expr '*' expr
    | expr '/' expr
    | expr '%' expr

    /* Relational */
    | expr EQ  expr
    | expr NEQ expr
    | expr LT  expr
    | expr GT  expr
    | expr LE  expr
    | expr GE  expr

    /* Logical */
    | expr AND expr
    | expr OR  expr

    /* Unary */
    | '-' expr %prec UMINUS
    | '!' expr

    /* Increment / decrement */
    | ID INC
    | ID DEC
    | INC ID
    | DEC ID

    /* Array access: a[i], a[i][j] */
    | ID index_list

    /* Primary */
    | '(' expr ')'
    | ID
    | NUM
    ;

/* One or more index brackets */
index_list
    : '[' expr ']'
    | index_list '[' expr ']'
    ;

%%

int main(void) {
    int result = yyparse();
    if (result == 0) {
        printf("Syntax valid.\n");
    }
    return result;
}
