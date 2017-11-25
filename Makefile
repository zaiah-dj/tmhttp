#!/usr/bin/make
NAME = tmhttp
PREFIX = /usr/local
MANPREFIX = $(PREFIX)/share/man
DB=gdb
DBFLAGS=-ex run --args 
LC=valgrind
LCFLAGS=--leak-check=full --log-fd=3
CFLAGS = -g -Wall -Werror -Wno-unused -std=c99 -fsanitize=address -fsanitize-undefined-trap-on-error -DSQROOGE_H
CC = clang
#CFLAGS = -g -Wall -Werror $(COMPLAIN) -Wstrict-overflow -ansi -std=c99 -Wno-deprecated-declarations -O0 -pedantic-errors $(LDDIRS) $(LDFLAGS) $(DFLAGS)
#CC = gcc
DFLAGS = -DHTTP_URL_MAX=100 -DHTTP_HEADER_MAX=10 -DHTTP_BODY_MAX=10 -DOBS_LOCAL_SQLITE3 -DSMPSRV_CLI_MODE
COMPLAIN = -Wno-unused
SRC = vendor/nw.c vendor/single.c http.c main.c 
OBJ = ${SRC:.c=.o}
IGNORE = archive/* vendor/*  
ARCHIVEDIR = ..
ARCHIVEFMT = gz
ARCHIVEFILE = $(NAME).`date +%F`.`date +%H.%M.%S`.tar.${ARCHIVEFMT}
BIN = $(NAME) 

#Phony targets 
.PHONY: main clean debug leak run other

#Primary target
main: build
main: run
main:
	@printf '' > /dev/null

build: CFLAGS += -DHTTP_TEST_MAIN -DHTTP_ECHO_ALL
build: $(OBJ) main.o
	@echo $(CC) -o $(BIN) $^ $(CFLAGS)
	@$(CC) -o $(BIN) $^ $(CFLAGS)

#Run args always run this
run:
	@$(RUNARGS)

#Install (the newest version can be a symbolic link)
install:
	@mkdir $(PREFIX)/$(NAME)
	@cp handler.h $(PREFIX)/$(NAME)
	@cp $(LIB) $(PREFIX)/lib

#Uninstall if you don't like it
uninstall:
	@rm -r $(PREFIX)/$(NAME)
	@rm $(PREFIX)/lib/$(LIB)

debug: build 
debug:
	@echo $(DB) $(DBFLAGS) $(RUNARGS)
	@$(DB) $(DBFLAGS) $(RUNARGS)

#Add flags here, b/c the server should free all resources...
leak: CFLAGS += -DNW_BEATDOWN_POST
leak: CFLAGS += -DNW_BEATDOWN_MODE
leak: clean 
leak: build 
leak:
	@echo $(LC) $(LCFLAGS) $(RUNARGS) 3>etc
	@$(LC) $(LCFLAGS) $(RUNARGS) 3>etc

#clean
clean:
	-@find . -maxdepth 2 -type f -iname "*.o" | xargs rm 
	-@rm $(BIN)

#clean
veryclean:
	-find . -type f -iname "*.o" -o -iname "*.$(SONAME)" -o -iname ".*.swp" | \
		xargs rm	
	-rm $(BIN)

# Make a tarball that goes to another directory
backup:
	@-rm -f sqlite3.o
	@echo tar chzf $(ARCHIVEDIR)/${ARCHIVEFILE} --exclude-backups \
		`echo $(IGNORE) | sed '{ s/^/--exclude=/; s/ / --exclude=/g; }'` ./*
	@tar chzf $(ARCHIVEDIR)/${ARCHIVEFILE} --exclude-backups \
		`echo $(IGNORE) | sed '{ s/^/--exclude=/; s/ / --exclude=/g; }'` ./*

# Make an archive tarball
archive: ARCHIVEDIR = archive
archive: backup

# ...
changelog:
	@echo "Creating / updating CHANGELOG document..."
	@touch CHANGELOG

# Notate a change (Target should work on all *nix and BSD)
change:
	@test -f CHANGELOG || printf "No changelog exists.  Use 'make changelog' first.\n\n"
	@test -f CHANGELOG
	@echo "Press [Ctrl-D] to save this file."
	@cat > CHANGELOG.USER
	@date > CHANGELOG.ACTIVE
	@sed 's/^/\t -/' CHANGELOG.USER >> CHANGELOG.ACTIVE
	@printf "\n" >> CHANGELOG.ACTIVE
	@cat CHANGELOG.ACTIVE CHANGELOG > CHANGELOG.NEW
	@rm CHANGELOG.ACTIVE CHANGELOG.USER
	@mv CHANGELOG.NEW CHANGELOG
