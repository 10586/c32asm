#Basic Makefile -- provides explicit rules
# Creates "myprogram" from "scan.l" and "myprogram.c"
#
BUILDDIR=out/
INTDIR=int/
SRCDIR=src/
LEX=flex
YACC=bison
INCLUDES=-Iinclude -I$(INTDIR)
LIBS=-ll
CXX=g++
LD=$(CXX)
CFLAGS=-g
CXXFLAGS=-g
LDFLAGS=-g

OBJPP=$(BUILDDIR)main.opp \
	$(BUILDDIR)astcore.opp \
	$(BUILDDIR)astdecl.opp \
	$(BUILDDIR)symtype.opp \
	$(BUILDDIR)asteval.opp

$(BUILDDIR)%.opp: $(SRCDIR)%.cpp
	$(CXX) -o $@ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -c $^

$(BUILDDIR)lloolc: $(BUILDDIR)llool_scan.o $(BUILDDIR)llool_parse.o $(OBJPP)
	$(LD) -o $@ $(LDFLAGS) $^ $(LIBS)

$(BUILDDIR)llool_scan.o: $(INTDIR)llool_scan.cpp
	$(CXX) $(CPPFLAGS) $(CFLAGS) $(INCLUDES) -o $@ -c $^

$(BUILDDIR)llool_parse.o: $(INTDIR)llool_parse.cpp
	$(CXX) $(CPPFLAGS) $(CFLAGS) $(INCLUDES) -o $@ -c $^
     
$(INTDIR)llool_parse.cpp: $(SRCDIR)llool.y
	$(YACC) $(YFLAGS) -o $@ $^

$(INTDIR)llool_parse.h: $(SRCDIR)llool.y
	$(YACC) $(YFLAGS) --defines=$@ $^

$(INTDIR)llool_scan.cpp: $(SRCDIR)llool.l $(INTDIR)llool_parse.h
	$(LEX) $(LFLAGS) -o $@ $^
     
clean:
	$(RM) $(BUILDDIR)* $(INTDIR)*
