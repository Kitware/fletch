# $Id$
#
# Makefile building json-c library (http://oss.metaparadigm.com/json-c/)
# 
include ../../../../GDALmake.opt

OBJ = \
	arraylist.o \
	debug.o \
	json_object.o \
	json_tokener.o \
	json_util.o \
	linkhash.o \
	printbuf.o \
	json_object_iterator.o \
	json_c_version.o

O_OBJ = $(foreach file,$(OBJ),../../o/$(file))

CPPFLAGS := $(CPPFLAGS)

default:	$(O_OBJ:.o=.$(OBJ_EXT))

#ifdef __APPLE__
# ...actually, needs to be -->600<-- to get strdup;
# per https://bugs.launchpad.net/libvterm/+bug/1638205
CPPFLAGS := -D_XOPEN_SOURCE=600 $(CPPFLAGS)
#else
# -D_XOPEN_SOURCE=500 to enable strdup() definition in C11 mode
CPPFLAGS := -D_XOPEN_SOURCE=500 $(CPPFLAGS)
#endif

../../o/%.$(OBJ_EXT):	%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(O_OBJ)
	rm -f *~
