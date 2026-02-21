# Simplified C Parser — LEX/FLEX + YACC/Bison

## Project Structure

```
c_parser/
├── lexer.l          ← FLEX lexer  (tokenizer)
├── parser.y         ← BISON grammar (syntax validator)
├── Makefile         ← Build automation
├── test_valid.c     ← Valid C subset program (should print "Syntax valid.")
└── test_invalid.c   ← Invalid program       (should print syntax error)
```

---

## Methodology

### 1. The Compilation Pipeline

```
Source Code (stdin / file)
        │
        ▼
  ┌──────────────┐     tokens      ┌──────────────┐
  │  FLEX Lexer  │ ─────────────▶  │ BISON Parser │
  │  (lexer.l)   │                 │  (parser.y)  │
  └──────────────┘                 └──────────────┘
         │                                │
  Skips whitespace              Validates grammar
  & comments                    rules and reports
  Returns tokens                success/failure
```

FLEX and BISON are a matched pair: Bison generates the token-type constants
(in `parser.tab.h`), and Flex uses those constants so both sides agree on
what each integer code means.

---

### 2. Lexer Design (`lexer.l`)

| What it handles | How |
|-----------------|-----|
| Whitespace / newlines | Discarded; newlines increment `yylineno` |
| `//` comments | Discarded via regex `"//"[^\n]*` |
| `/* */` comments | Manual scanning loop inside action |
| Keywords (`int`, `if`, …) | Matched before `ID` rule — flex uses longest/first-match |
| Identifiers | `[a-zA-Z_][a-zA-Z0-9_]*` → returns `ID` token |
| Numbers (int & float) | Returns `NUM` token |
| Operators (`==`, `!=`, `<=`, `>=`) | Multi-char first, then single-char |
| Unknown chars | Prints error and exits immediately |

**Key design point:** Keywords appear *before* the `ID` rule. Flex matches
the longest token; if two rules match equally, the one listed first wins.
This ensures `int` is returned as `INT`, not as `ID`.

---

### 3. Parser / Grammar Design (`parser.y`)

#### Grammar Rules (BNF summary)

```
program        → stmt_list

stmt_list      → ε | stmt_list stmt

stmt           → decl_stmt
               | if_stmt
               | do_while_stmt
               | block
               | expr_stmt

decl_stmt      → type declarator_list ';'
type           → int | float | char | double
declarator_list→ declarator | declarator_list ',' declarator
declarator     → ID | ID '=' expr

if_stmt        → IF '(' expr ')' stmt
               | IF '(' expr ')' stmt ELSE stmt

do_while_stmt  → DO stmt WHILE '(' expr ')' ';'

block          → '{' stmt_list '}'

expr_stmt      → ID '=' expr ';'
               | expr ';'

expr           → expr '+' expr  | expr '-' expr
               | expr '*' expr  | expr '/' expr | expr '%' expr
               | expr EQ expr   | expr NEQ expr
               | expr LT expr   | expr GT expr
               | expr LE expr   | expr GE expr
               | '-' expr       (unary minus)
               | '(' expr ')'
               | ID | NUM
```

#### Operator Precedence

Declared via `%left` / `%right` directives (low → high priority):

```
Level 1 (lowest):  ==  !=
Level 2:           <  >  <=  >=
Level 3:           +  -
Level 4:           *  /  %
Level 5 (highest): unary minus  (%right UMINUS)
```

#### Dangling-Else Resolution

The classic ambiguity:
```c
if (a) if (b) x=1; else x=2;
```
Is `else` for the outer or inner `if`? The standard C answer: inner `if`.

Bison resolves this automatically because the default conflict resolution
(shift over reduce) naturally binds `else` to the nearest `if`. The
`%prec ELSE` annotation on the no-else rule makes this explicit.

---

### 4. Error Reporting

`yyerror()` is called by Bison whenever it cannot continue parsing. It
prints:

```
Syntax error at line <N>, token : '<token_text>'
```

`yylineno` is maintained by the lexer (incremented on every `\n`).
`yytext` holds the last token text that caused the problem.

---

## Build Instructions

### Prerequisites

```bash
sudo apt-get install bison flex gcc   # Debian/Ubuntu
sudo yum install bison flex gcc       # RHEL/CentOS
brew install bison flex               # macOS
```

### Compile

```bash
make
```

This runs:
```bash
bison -d -v parser.y     # → parser.tab.c  parser.tab.h  parser.output
flex lexer.l             # → lex.yy.c
gcc -o c_parser parser.tab.c lex.yy.c -lfl
```

---

## Running the Parser

### From stdin

```bash
echo "int x, y; x = 5 + 3;" | ./c_parser
# Output: Syntax valid.
```

### From a file

```bash
./c_parser < test_valid.c
# Output: Syntax valid.

./c_parser < test_invalid.c
# Output: Syntax error at line 3, token : 'b'
```

### Make targets

```bash
make test_valid    # pipe a known-good snippet through the parser
make test_invalid  # pipe a broken snippet and confirm error detection
make clean         # remove all generated files
```

---

## Supported Syntax Examples

```c
// 1. Multiple declarations
int a, b, c;
float x = 3.14, y;
double d = 2.71;

// 2. Arithmetic expressions
a = 10 + b * (c - 2);
x = -y + 3.0;

// 3. if / if-else
if (a > 0) {
    b = a;
} else {
    b = -a;
}

// 4. do-while
do {
    a = a - 1;
} while (a > 0);

// 5. Nested blocks
if (b != 0) {
    do {
        c = c + 1;
    } while (c <= 10);
}
```

---

## Limitations (by design — simplified subset)

- No function definitions or calls
- No arrays or pointers
- No `for` / `while` (only `do-while`)
- No `return`, `break`, `continue`
- No string literals
- No `++` / `--` operators
- Single-file programs only
