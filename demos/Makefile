# Include paths needed for compilations
CC65_INC=/workspaces/cc65/include
CA65_INC=/workspaces/cc65/asminc
CC65_HOME=/workspaces/cc65/
LD65_CFG=/workspaces/cc65/cfg
LD65_LIB=/workspaces/cc65/lib
LD65_OBJ=/workspaces/cc65/obj

# Compiling for Atari Lynx system
SYS=lynx

# Names of tools
CO=co65
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

BIN=bin
OBJ=obj

# Flag for assembler
AFLAGS=-I $(CA65_INC) -t $(SYS)

targets = plasma.lnx rasta128.lnx
all: $(targets)

%.lnx: %.o
	$(CL) -t $(SYS) -o $(OBJ)/$*.bin -C lynx-asm.cfg -v -m $(OBJ)/$*.map $<
	lynxenc $(OBJ)/$*.bin $(OBJ)/$*.lyx
	make_lnx $(OBJ)/$*.lyx -b0 256K -o $(BIN)/$@

# Rule for making a *.o file out of a *.s or *.asm file
%.o: %.s
	$(AS) -o $@ $(AFLAGS) $<
%.o: %.asm
	$(AS) -o $@ $(AFLAGS) -l $(OBJ)/$*.lst $<

# Rule for making a *.o file out of a *.bmp file
%.o : %.bmp
	$(SPRPCK) -t6 -p2 $<
	$(ECHO) .global _$(*F) > $*.s
	$(ECHO) .segment \"$(RODATA_SEGMENT)\" >> $*.s
	$(ECHO) _$(*F): .incbin \"$*.spr\" >> $*.s
	$(AS) -o $@ $(AFLAGS) $*.s
	$(RM) $*.s
	$(RM) $*.pal
	$(RM) $*.spr

all: $(target)

clean :
	$(RM) $(BIN)/*.lnx
	$(RM) $(OBJ)/*.*
	$(RM) *.spr
	$(RM) *.s
	$(RM) *.o
	$(RM) *.pal