#!/bin/sh
assemble:
	nasm ./Source/BASIC.ASM -o ./Binaries/BASIC.BIN -f bin -l ./Source/BASIC.LST -O0