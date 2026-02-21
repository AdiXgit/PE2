%{
/*
 * parser.y - Bison Grammar for simplified C subset
 *
 * Grammar covers:
 *   - Variable declarations: int a, b, c;
 *   - if / if-else statements
 *   - do-while statements
 *   - Nested blocks  { ... }
 *   - Arithmetic and relational expressions
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Supplied by the lexer */
extern int  yylineno;
extern int  yylex(void);
extern char *yytext;

/* Called by Bison on parse error */
void yyerror(const char *msg) {
    fprintf(stderr,
        "Syntax error at line %d, token : '%s'\n",
        yylineno, yytext);
}
%}

/* ── Value type for semantic records ── */
%union {
    char *str;   /* identifier / number text */
}

/* ── Tokens from the lexer ── */
%token <str> ID NUM
%token INT FLOAT CHAR DOUBLE
%token IF ELSE DO WHILE
%token EQ NEQ LE GE LT GT

/* ── Operator precedence (low → high) ── */
%left  EQ NEQ
%left  LT GT LE GE
%left  '+' '-'
%left  '*' '/' '%'
%right UMINUS          /* unary minus pseudo-token */

%%

/* ================================================================
   Top-level program: zero or more statements
   ================================================================ */
program
    : stmt_list          { /* entire input accepted */ }
    ;

/* ── A list of zero or more statements ── */
stmt_list
    : /* empty */
    | stmt_list stmt
    ;

/* ================================================================
   Statement
   ================================================================ */
stmt
    : decl_stmt          /* variable declaration */
    | if_stmt            /* if / if-else          */
    | do_while_stmt      /* do-while              */
    | block              /* bare block  { ... }   */
    | expr_stmt          /* expression ; (assign) */
    ;

/* ================================================================
   Variable Declaration
   Examples:
       int x;
       float a, b, c;
       int p = 5, q;          (with optional initialiser)
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

/* A declarator is an identifier with an optional "= expr" initialiser */
declarator
    : ID
    | ID '=' expr
    ;

/* ================================================================
   if / if-else
   The classic "dangling-else" problem is handled by the standard
   trick: %prec ELSE shifts rather than reduces, so the else always
   binds to the nearest unmatched if.
   ================================================================ */
if_stmt
    : IF '(' expr ')' stmt %prec ELSE
    | IF '(' expr ')' stmt ELSE stmt
    ;

/* ================================================================
   do-while
   Example:  do { ... } while (expr);
   ================================================================ */
do_while_stmt
    : DO stmt WHILE '(' expr ')' ';'
    ;

/* ================================================================
   Block  { stmt_list }
   ================================================================ */
block
    : '{' stmt_list '}'
    ;

/* ================================================================
   Expression statement  (assignment or stand-alone expr)
   ================================================================ */
expr_stmt
    : ID '=' expr ';'    /* simple assignment */
    | expr ';'           /* e.g. function call placeholder */
    ;

/* ================================================================
   Expressions
   Precedence is enforced via %left/%right directives above.
   ================================================================ */
expr
    /* ── Arithmetic ── */
    : expr '+' expr
    | expr '-' expr
    | expr '*' expr
    | expr '/' expr
    | expr '%' expr

    /* ── Relational ── */
    | expr EQ  expr
    | expr NEQ expr
    | expr LT  expr
    | expr GT  expr
    | expr LE  expr
    | expr GE  expr

    /* ── Unary minus ── */
    | '-' expr %prec UMINUS

    /* ── Primary ── */
    | '(' expr ')'
    | ID
    | NUM
    ;

%%

/* ================================================================
   main – drive the parse, report final verdict
   ================================================================ */
int main(void) {
    int result = yyparse();
    if (result == 0) {
        printf("Syntax valid.\n");
    }
    /* yyerror() already printed the error message on failure */
    return result;
}
