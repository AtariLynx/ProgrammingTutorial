; The Atari Lynx directory structure
; Written for the cc65 compiler by
; Karri Kaksonen, 2004
;
	.include "lynx.inc"
	.import __STARTOFDIRECTORY__
	.import __MAIN_START__
	.import __CODE_SIZE__, __DATA_SIZE__, __RODATA_SIZE__
	.import __STARTUP_SIZE__, __ONCE_SIZE__
	.import __BLOCKSIZE__

	.import __CODE_LOAD__
	.import __UPCODE_SIZE__
	.import __UPCODE_LOAD__
	.import __UPDATA_SIZE__

.segment	"DIRECTORY"
__DIRECTORY_START__:

; Entry 0 - Resident executable (RAM)
off0=__STARTOFDIRECTORY__+(__DIRECTORY_END__-__DIRECTORY_START__)
blocka=off0/__BLOCKSIZE__
len0=__STARTUP_SIZE__+__ONCE_SIZE__+__CODE_SIZE__+__DATA_SIZE__+__RODATA_SIZE__+__UPCODE_SIZE__+__UPDATA_SIZE__
	.byte	<blocka
	.word	off0 & (__BLOCKSIZE__ - 1)
	.byte	$88
	.word	__MAIN_START__	
	.word	len0

; You may insert more entries in any format you like

.macro entry old_off, old_len, new_off, new_block, new_len, new_size, new_addr
new_off=old_off+old_len
new_block=new_off/__BLOCKSIZE__
new_len=new_size
	.byte	<new_block
	.word	(new_off & (__BLOCKSIZE__ - 1))
	.byte	$88
	.word	new_addr
	.word	new_len
.endmacro

; The 2nd entry is the entertainment module that we run at startup
entry off0, len0, off1, block1, len1, __UPCODE_SIZE__ + __UPDATA_SIZE__, __UPCODE_LOAD__
__DIRECTORY_END__:
