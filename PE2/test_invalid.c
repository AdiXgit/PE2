/* test_invalid.c – intentional syntax error */

int a b;      /* missing comma between declarators → error */
float x = ;   /* missing expression after '='            */
