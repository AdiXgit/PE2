/* test_valid.c – valid program for the simplified C parser */

// Multiple declarations with comma-separated declarators
int   a, b, c;
float x = 3.14, y;
char  ch;
double d = 2.71;

// Simple assignments / arithmetic expressions
a = 10;
b = a + 5 * 2;
c = (a - b) % 3;

// if statement
if (a > b) {
    a = a - 1;
}

// if-else statement (with nesting)
if (x >= 0) {
    y = x * 2;
} else {
    y = -x;
}

// do-while statement
do {
    b = b + 1;
} while (b < 20);

// Nested do-while inside if
if (c != 0) {
    do {
        c = c - 1;
        a = a + c;
    } while (c > 0);
} else {
    b = 0;
}

// Relational expression in do-while
do {
    a = a + 1;
} while (a <= 100);
