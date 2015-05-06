#Basic Makefile -- provides explicit rules
# Creates "myprogram" from "scan.l" and "myprogram.c"
#
BUILDDIR=out/
INTDIR=int/
SRCDIR=src/
LEX=flex
INCLUDES=-Iinclude
LIBS=-ll

$(BUILDDIR)lloolc: $(BUILDDIR)llool_scan.o 
	$(CC) -o $@ $(LDFLAGS) $^ $(LIBS)

$(BUILDDIR)llool_scan.o: $(INTDIR)llool_scan.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(INCLUDES) -o $@ -c $^
     
$(INTDIR)llool_scan.c: $(SRCDIR)llool.l
	$(LEX) $(LFLAGS) -o $@ $^
     
clean:
	$(RM) $(BUILDDIR)*.o $(INTDIR)llool_scan.c $(BUILDDIR)lloolc
