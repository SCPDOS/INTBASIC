    [map all ./lst/BASIC.MAP]
    [DEFAULT REL]
    BITS 64
%include "./data/MEM.INC"
Segment .text align=1 valign=1
%include "./src/MAIN.ASM"
%include "./src/TTY.ASM"
%include "./src/PROCESS.ASM"
%include "./src/PARSE.ASM"
%include "./src/COMMANDS.ASM"
%include "./src/CTRLFLOW.ASM"
%include "./src/MATH.ASM"
%include "./src/MEMORY.ASM"
%include "./data/BASICDAT.ASM"
Segment dSeg nobits valign=1 vfollows=.text 
%include "./data/BSS.ASM"
Segment programArea align=1 vfollows=dSeg valign=16 ;Para aligned
ENDOFPROGRAM: