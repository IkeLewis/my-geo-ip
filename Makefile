#!/usr/bin/make

# Copyright (c) 2015 Isaac Lewis all rights reserved. 

SHELL = /bin/bash

.PHONY: all clean install uninstall

all: 
	./make.sh

install: all
	./install.sh

uninstall:
	./uninstall.sh

clean: uninstall
