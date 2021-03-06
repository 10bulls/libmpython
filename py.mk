# default settings; can be overriden in main Makefile

ifndef PY_SRC
PY_SRC = ../py
endif

ifndef BUILD
BUILD = build
endif

# to create the build directory

#$(BUILD):
#	$(Q)mkdir -p $@

# where py object files go (they have a name prefix to prevent filename clashes)

PY_BUILD = $(BUILD)/py

PY_QSTR_DEFS = $(PY_SRC)/qstrdefs.h

# py object files

PY_O_BASENAME = \
	nlrx86.o \
	nlrx64.o \
	nlrthumb.o \
	malloc.o \
	gc.o \
	qstr.o \
	vstr.o \
	unicode.o \
	lexer.o \
	lexerstr.o \
	lexerunix.o \
	parse.o \
	parsehelper.o \
	scope.o \
	compile.o \
	emitcommon.o \
	emitpass1.o \
	emitcpy.o \
	emitbc.o \
	asmx64.o \
	emitnx64.o \
	asmthumb.o \
	emitnthumb.o \
	emitinlinethumb.o \
	runtime.o \
	map.o \
	strtonum.o \
	obj.o \
	objarray.o \
	binary.o \
	objbool.o \
	objboundmeth.o \
	objcell.o \
	objclosure.o \
	objcomplex.o \
	objdict.o \
	objenumerate.o \
	objexcept.o \
	objfilter.o \
	objfloat.o \
	objfun.o \
	objgenerator.o \
	objgetitemiter.o \
	objint.o \
	objlist.o \
	objmap.o \
	objmodule.o \
	objnone.o \
	objrange.o \
	objset.o \
	objslice.o \
	objstr.o \
	objtuple.o \
	objtype.o \
	stream.o \
	builtin.o \
	builtinimport.o \
	builtinevex.o \
	builtinmp.o \
	vm.o \
	showbc.o \
	repl.o \
	objzip.o \
	sequence.o \

# prepend the build destination prefix to the py object files

PY_O = $(addprefix $(PY_BUILD), $(PY_O_BASENAME))


# qstr data

# Adding an order only dependency on $(PY_BUILD) causes $(PY_BUILD) to get
# created before we run the script to generate the .h
$(PY_BUILD)/qstrdefs.generated.h: | $(PY_BUILD)/
$(PY_BUILD)/qstrdefs.generated.h: $(PY_QSTR_DEFS) $(QSTR_DEFS) $(PY_SRC)/makeqstrdata.py
	$(ECHO) "makeqstrdata $(PY_QSTR_DEFS) $(QSTR_DEFS)"
	$(Q)$(PYTHON) $(PY_SRC)/makeqstrdata.py $(PY_QSTR_DEFS) $(QSTR_DEFS) > $@

# We don't know which source files actually need the generated.h (since
# it is #included from str.h). The compiler generated dependencies will cause
# the right .o's to get recompiled if the generated.h file changes. Adding
# an order-only dependendency to all of the .o's will cause the generated .h
# to get built before we try to compile any of them.
$(PY_O): | $(PY_BUILD)/qstrdefs.generated.h


$(PY_BUILD)emitnx64.o: $(PY_SRC)/emitnative.c $(PY_SRC)/emit.h $(MPTEENSY_SRC)/mpconfigport.h
	$(ECHO) "CC $<"
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) -DN_X64 -c -o $@ $<

$(PY_BUILD)emitnthumb.o: $(PY_SRC)/emitnative.c $(PY_SRC)/emit.h $(MPTEENSY_SRC)/mpconfigport.h
	$(ECHO) "CC $<"
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) -DN_THUMB -c -o $@ $<

$(PY_BUILD)%.o: $(PY_SRC)/%.S
	$(ECHO) "CC $<"
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

$(PY_BUILD)%.o: $(PY_SRC)/%.c $(MPTEENSY_SRC)/mpconfigport.h
	$(ECHO) "CC $<"
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

# optimising gc for speed; 5ms down to 4ms on pybv2
$(PY_BUILD)gc.o: $(PY_SRC)/gc.c
	$(ECHO) "CC $<"
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) -O3 -c -o $@ $<

# optimising vm for speed, adds only a small amount to code size but makes a huge difference to speed (20% faster)
$(PY_BUILD)vm.o: $(PY_SRC)/vm.c
	$(ECHO) "CC $<"
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) -O3 -c -o $@ $<

# header dependencies

$(PY_BUILD)parse.o: $(PY_SRC)/grammar.h
$(PY_BUILD)compile.o: $(PY_SRC)/grammar.h
$(PY_BUILD)/emitcpy.o: $(PY_SRC)/emit.h
$(PY_BUILD)emitbc.o: $(PY_SRC)/emit.h
