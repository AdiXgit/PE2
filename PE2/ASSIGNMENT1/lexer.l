%{
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

%option noyywrap
%option yylineno

DIGIT     [0-9]
LETTER    [a-zA-Z_]
ID        {LETTER}({LETTER}|{DIGIT})*
INT_NUM   {DIGIT}+
FLOAT_NUM {DIGIT}+\.{DIGIT}+

%%

[ \t\r]+    { }
\n          { }

"//"[^\n]*  { }

"/*"        {
                int c;
                while (1) {
                    c = input();
                    if (c == '*') {
                        c = input();
                        if (c == '/') break;
                        if (c == EOF) break;
                    }
                    if (c == EOF) break;
                }
            }

"int"       { return INT;     }
"float"     { return FLOAT;   }
"char"      { return CHAR;    }
"double"    { return DOUBLE;  }
"if"        { return IF;      }
"else"      { return ELSE;    }
"do"        { return DO;      }
"while"     { return WHILE;   }
"for"       { return FOR;     }
"switch"    { return SWITCH;  }
"case"      { return CASE;    }
"default"   { return DEFAULT; }
"break"     { return BREAK;   }

{ID}        { yylval.str = strdup(yytext); return ID; }

{FLOAT_NUM} { yylval.str = strdup(yytext); return NUM; }
{INT_NUM}   { yylval.str = strdup(yytext); return NUM; }

"++"        { return INC;       }
"--"        { return DEC;       }
"+="        { return ADDASSIGN; }
"-="        { return SUBASSIGN; }
"=="        { return EQ;        }
"!="        { return NEQ;       }
"<="        { return LE;        }
">="        { return GE;        }
"&&"        { return AND;       }
"||"        { return OR;        }

"<"         { return LT;  }
">"         { return GT;  }
"+"         { return '+'; }
"-"         { return '-'; }
"*"         { return '*'; }
"/"         { return '/'; }
"%"         { return '%'; }
"="         { return '='; }
"!"         { return '!'; }
":"         { return ':'; }
";"         { return ';'; }
","         { return ','; }
"("         { return '('; }
")"         { return ')'; }
"{"         { return '{'; }
"}"         { return '}'; }
"["         { return '['; }
"]"         { return ']'; }

.           {
                fprintf(stderr,
                    "Syntax error at line %d, token : '%s'\n",
                    yylineno, yytext);
                exit(1);
            }

%%

