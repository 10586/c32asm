#Basic Makefile -- provides explicit rules
# Creates "myprogram" from "scan.l" and "myprogram.c"
#
BUILDDIR=out/
INTDIR=int/
SRCDIR=src/
LEX=flex
YACC=bison
INCLUDES=-Iinclude -I$(INTDIR)
LIBS=-lfl
CXX=g++
CC=gcc
LD=$(CC)
CFLAGS=-g -DYYDEBUG=1
CXXFLAGS=-g
LDFLAGS=-g

OBJS=$(BUILDDIR)main.o

$(BUILDDIR)%.o: $(SRCDIR)%.c
	$(CC) -o $@ $(CPPFLAGS) $(CFLAGS) $(INCLUDES) -c $^

$(BUILDDIR)c32as: $(BUILDDIR)c32asm_scan.o $(BUILDDIR)c32asm_parse.o $(OBJS)
	$(LD) -o $@ $(LDFLAGS) $^ $(LIBS)

$(BUILDDIR)c32asm_scan.o: $(INTDIR)c32asm_scan.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(INCLUDES) -o $@ -c $^

$(BUILDDIR)c32asm_parse.o: $(INTDIR)c32asm_parse.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(INCLUDES) -o $@ -c $^
     
$(INTDIR)c32asm_parse.c: $(SRCDIR)c32asm.y
	$(YACC) $(YFLAGS) -o $@ $^

$(INTDIR)c32asm_parse.h: $(SRCDIR)c32asm.y
	$(YACC) $(YFLAGS) --defines=$@ $^

$(INTDIR)c32asm_scan.c: $(SRCDIR)c32asm.l $(INTDIR)c32asm_parse.h
	$(LEX) $(LFLAGS) -o $@ $^
     
clean:
	$(RM) $(BUILDDIR)* $(INTDIR)*
