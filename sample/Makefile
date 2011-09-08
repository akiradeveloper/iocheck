.PHONY: build

build: main.c
	gcc -o main main.c
	mkdir -p iocheck/lock iocheck/unlock

clean: main
	rm main

purge: clean
	rm -rf iocheck
	
