#!/usr/bin/make

# my-geo-ip -- The my-geo-ip package provides geo-ip services to
#              applications via a MySQL database.
#
# Copyright (C) 2016-2019 Isaac Lewis

SHELL = /bin/bash

.PHONY: all clean install uninstall

all:
	./make.sh

install: all
	./install.sh

uninstall:
	./uninstall.sh

clean: uninstall
