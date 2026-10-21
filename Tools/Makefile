# Tools makefile (linux/Debian)

ifeq ($(wildcard /bin/csh),)
$(error	Please install /bin/csh or equivalent)
endif

ifneq ($(wildcard /usr/bin/mysql_config),)
SQLINC=$(shell mysql_config --include)
SQLLIB=$(shell mysql_config --libs)
SQLVER=$(shell mysql_config --version | sed 'sx\..*xx')
endif
ifneq ($(wildcard /usr/bin/mariadb_config),)
SQLINC=$(shell mariadb_config --include)
SQLLIB=$(shell mariadb_config --libs)
SQLVER=$(shell mariadb_config --version | sed 'sx\..*xx')
endif

ifdef	SQLINC
TOOLS := faikoutlog faikoutgraph
else
$(error Warning - mariadb/mysql not installed, needed if you want to build tools)
endif

all:	tools

tools:	$(TOOLS)

ifeq ($(shell uname),Darwin)
INCLUDES=-I/usr/local/include/ -I../ESP/main
LIBS=-L/usr/local/Cellar/popt/1.18/lib/
else
LIBS=
INCLUDES=-I../ESP/main
endif

../SQLlib/sqllib.o: ../SQLlib/sqllib.c
	make -C ../SQLlib
AXL/axl.o: AXL/axl.c
	make -C AXL
AJL/ajl.o: AJL/ajl.c
	make -C AJL

CCOPTS=${SQLINC} -I. -I/usr/local/ssl/include -D_GNU_SOURCE -g -Wall -funsigned-char -lm
OPTS=-L/usr/local/ssl/lib ${SQLLIB} ${CCOPTS}

faikoutlog: faikoutlog.c ../SQLlib/sqllib.o AJL/ajl.o ../ESP/main/acextras.m ../ESP/main/acfields.m ../ESP/main/accontrols.m
	cc -O -o $@ $< -lpopt -lmosquitto -I../ESP/main -I../SQLlib ../SQLlib/sqllib.o -IAJL AJL/ajl.o ${INCLUDES} ${OPTS}

faikoutgraph: faikoutgraph.c ../SQLlib/sqllib.o AXL/axl.o
	cc -O -o $@ $< -lpopt -lmosquitto -I../ESP/main -I../SQLlib ../SQLlib/sqllib.o -IAXL AXL/axl.o -lcurl ${INCLUDES} ${OPTS}
pull:
	git pull
	git submodule update --recursive

update:
	git submodule update --init --recursive --remote
	-git commit -a -m "Library update"
