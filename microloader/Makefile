# Compiling for Atari Lynx system
SYS=lynx

# Names of tools
CO=co65
CC=cc65
AS=ca65
AR=ar65
CL=cl65
SPRPCK=sprpck
CP=cp
RM=rm -f
ECHO=echo
TOUCH=touch

CODE_SEGMENT=CODE
DATA_SEGMENT=DATA
RODATA_SEGMENT=RODATA
BSS_SEGMENT=BSS

SEGMENTS=--code-name $(CODE_SEGMENT) \
		 --rodata-name $(RODATA_SEGMENT) \
		 --bss-name $(BSS_SEGMENT) \
		 --data-name $(DATA_SEGMENT)

# Flag for assembler
AFLAGS=-I $(CA65_INC) -t $(SYS)

target=microloader

all: $(target).lnx

$(target).lnx : $(target).lyx
	make_lnx $(target).lyx -b0 256K -o $@

$(target).lyx : stage1.enc stage2.bin
	cat stage1.enc stage2.bin > $@
	bzcat allff.lyx.bz2 >> $@

%.enc: %.bin
	lynxenc $< $@

%.bin: %.o
	$(CL) -t $(SYS) -o $@ -C lynx-asm.cfg -v -m $*.map $<
	
# Rule for making a *.o file out of a *.s or *.asm file
%.o: %.s
	$(AS) -o $@ $(AFLAGS) $<
%.o: %.asm
	$(AS) -o $@ $(AFLAGS) $<

clean:
	$(RM) *.lnx
	$(RM) *.bin
	$(RM) *.enc
	$(RM) *.s
	$(RM) *.o