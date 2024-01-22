; The Atari Lynx directory structure
; Written for the cc65 compiler by
; Karri Kaksonen, 2004
;
	.include "lynx.inc"
	.import __STARTOFDIRECTORY__
	.export _MAIN_FILENR : absolute
	.import __MAIN_START__
	.import __CODE_SIZE__, __DATA_SIZE__, __RODATA_SIZE__
	.import __STARTUP_SIZE__, __ONCE_SIZE__, __LOWCODE_SIZE__
	.import __BANK0BLOCKSIZE__
	.import __STARTUP_LOAD__
	.import __STARTUP_SIZE__ 
	.import __LOWCODE_SIZE__

	.import __CODE_LOAD__

	.export _UPLOAD_FILENR : absolute
	.import __UPCODE_SIZE__
	.import __UPCODE_LOAD__
	.import __UPDATA_SIZE__

.segment	"DIRECTORY"

.macro entry old_off, old_len, new_off, new_block, new_len, new_size, new_addr
new_off=old_off+old_len
new_block=new_off/__BANK0BLOCKSIZE__
new_len=new_size
	.byte	<new_block
	.word	(new_off & (__BANK0BLOCKSIZE__ - 1))
	.byte	$88
	.word	new_addr
	.word	new_len
.endmacro

__DIRECTORY_START__:

; Entry 0 - Resident executable (RAM)
_MAIN_FILENR=0
entry __STARTOFDIRECTORY__+(__DIRECTORY_END__-__DIRECTORY_START__), 0, mainoff, mainblock, mainlen, __STARTUP_SIZE__+__ONCE_SIZE__+__CODE_SIZE__+__RODATA_SIZE__+__DATA_SIZE__+__LOWCODE_SIZE__, __STARTUP_LOAD__

; Uploader segment
_UPLOAD_FILENR=_MAIN_FILENR+1
entry mainoff, mainlen, uploadoff, uploadblock, uploadlen, __UPCODE_SIZE__ + __UPDATA_SIZE__, __UPCODE_LOAD__

__DIRECTORY_END__:
