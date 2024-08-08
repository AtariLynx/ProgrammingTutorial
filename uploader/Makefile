# https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html
# https://yuukidach.github.io/p/makefile-for-projects-with-subdirectories/
# https://ismail.badawi.io/blog/automatic-directory-creation-in-make/

# Include paths needed for compilations
CC65_INC=/workspaces/cc65/include
CA65_INC=/workspaces/cc65/asminc
CC65_HOME=/workspaces/cc65/
LD65_CFG=/workspaces/cc65/cfg
LD65_LIB=/workspaces/cc65/lib
LD65_OBJ=/workspaces/cc65/obj

ifeq ($(BUILD),)
	BUILD=debug
endif

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
AFLAGS=-I $(CA65_INC) -t $(SYS) -D $(BUILD)

# Flags for C-code compiler
CFLAGS=-I ./includes -t $(SYS) --add-source -O -Or -Cl -Os -D $(BUILD)

target = tutorial-uploader.lnx
objects = main.o turbo.o

$(target) : $(objects)
	$(CL) -t $(SYS) -o $@ -v -m uploader.map $(objects) lynx.lib
	$(CP) $@ $(BUILD)-$@

# Rule for making a *.o file out of a *.c file
%.o: %.c
	$(CC) $(CFLAGS) $(SEGMENTS) -o $(*).s $<
	$(AS) -o $@ $(AFLAGS) $(*).s
#	$(RM) $*.s

# Rule for making a *.o file out of a *.s or *.asm file
%.o: %.s
	$(AS) -o $@ $(AFLAGS) $<
%.o: %.asm
	$(AS) -o $@ $(AFLAGS) $<

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
	$(RM) $(objects)
	$(RM) *.spr
	$(RM) *.s
	$(RM) *.o
	$(RM) *.pal
	$(RM) *.joy
	$(RM) *.tgi
	$(RM) *.ser