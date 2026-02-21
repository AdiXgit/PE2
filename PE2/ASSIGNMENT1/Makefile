CC     = gcc
CFLAGS = -Wall -Wextra -g
TARGET = c_parser

.PHONY: all clean

all: $(TARGET)

parser.tab.c parser.tab.h: parser.y
	bison -d -v parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

$(TARGET): parser.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o $(TARGET) parser.tab.c lex.yy.c -lfl

clean:
	rm -f $(TARGET) parser.tab.c parser.tab.h parser.output lex.yy.c *.o
