/* test_invalid.c - intentional syntax errors */

/* Error 1: missing size in array declaration */
int a[];

/* Error 2: for loop missing semicolons */
for (i = 0, i < 10, i++) {
    a = 1;
}
