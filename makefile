#!/bin/sh
assemble:
	nasm ./BASIC.ASM -o ./bin/BASIC.COM -f bin -l ./lst/BASIC.LST -O0