# Makefile for the simplified C parser
#
# Build chain:
#   1. Bison  : parser.y  → parser.tab.c + parser.tab.h
#   2. Flex   : lexer.l   → lex.yy.c          (includes parser.tab.h)
#   3. GCC    : compile & link everything → c_parser

CC      = gcc
CFLAGS  = -Wall -Wextra -g
TARGET  = c_parser

.PHONY: all clean test_valid test_invalid

# ── Default target ──────────────────────────────────────────────
all: $(TARGET)

# Step 1: Run Bison
#   -d  : produce parser.tab.h (token #defines needed by the lexer)
#   -v  : produce parser.output (human-readable automaton — handy for debugging)
parser.tab.c parser.tab.h: parser.y
	bison -d -v parser.y

# Step 2: Run Flex
#   lex.yy.c #includes "parser.tab.h" for the token constants
lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

# Step 3: Compile and link
$(TARGET): parser.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o $(TARGET) parser.tab.c lex.yy.c -lfl

# ── Quick smoke-tests ────────────────────────────────────────────
test_valid: $(TARGET)
	@echo "=== Testing valid input ==="
	@echo "int x, y; float z; x = 1 + 2; if (x > 0) { y = x * 2; } do { x = x - 1; } while (x > 0);" \
	      | ./$(TARGET)

test_invalid: $(TARGET)
	@echo "=== Testing invalid input ==="
	@echo "int x y;" | ./$(TARGET) || true

# ── Clean up generated files ─────────────────────────────────────
clean:
	rm -f $(TARGET) parser.tab.c parser.tab.h parser.output lex.yy.c *.o
