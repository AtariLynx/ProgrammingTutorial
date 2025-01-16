                            * = $F2E2
INITSYS macro
F2E2   A9 0D                LDA #$0D
F2E4   8D 58 F7             STA $F758		; __dispctl
F2E7   A9 08                LDA #$08
F2E9   8D 57 F7             STA $F757		; __sprsys
F2EC   8D 92 FC             STA SPRSYS
F2EF   A9 08                LDA #$08		; Vector space
F2F1   8D F9 FF             STA MAPCTL		
F2F4   A9 0A                LDA #$0A		; CART_ADDR_DATA+RESTLESS	
F2F6   8D 59 F7             STA LF759		; __iodat
F2F9   8D 8B FD             STA IODAT
F2FC   8D 5A F7             STA $F75A		; __iodir
F2FF   8D 8A FD             STA IODIR
F302   A9 04                LDA #$04		; TXOPEN
F304   8D 8C FD             STA SERCTL

INITINT $EFE0 macro
F307   A9 61                LDA #$61
F309   8D FE FF             STA $FFFE
F30C   A9 F7                LDA #$F7
F30E   8D FF FF             STA $FFFF		; IRQ vector to $F761 UserIntHandler

; Initialize jump table at $EFE0 to $F77E IntReturn
F311   A2 0F                LDX #$0F
F313   A9 F7      LF313     LDA #$F7
F315   9D E0 EF             STA $EFE0,X
F318   CA                   DEX
F319   A9 7E                LDA #$7E
F31B   9D E0 EF             STA $EFE0,X
F31E   CA                   DEX
F31F   10 F2                BPL LF313

F321   A9 04                LDA #$04		; TXOPEN
F323   8D 8C FD             STA SERCTL		
F326   A9 10                LDA #$10
F328   8D 80 FD             STA INTRST		; Reset timer 4 for serial
End INITINT macro

F32B   58                   CLI			; Let's go
F32C   D8                   CLD
F32D   A2 20                LDX #$20		; Set stack pointer to start at 32?
F32F   9A                   TXS

Macro SETDISP_60
F330   A9 9E                LDA #$9E		; 158 == 159 before zero and +1 for underflow => 160 horizontal resolution
F332   8D 00 FD             STA TIMER0+BACKUP	
F335   A9 18                LDA #$18		; Enable reload and enable count
F337   8D 01 FD             STA TIMER0+CTL	; TIM1CTL
F33A   A9 68                LDA #$68		; 104 == 102 vertical resolution + 3 
F33C   8D 08 FD             STA TIMER2+BACKUP
F33F   A9 9F                LDA #$9F		; Enable reload + enable interrupt
F341   8D 09 FD             STA TIMER2+CTL	;
F344   A9 29                LDA #$29
F346   8D 93 FD             STA PBKUP		; Magic PBKUP 0x29 value
F349   20 87 F7             JSR LF787		; InitDisplayer
End of SETDISP macro

Macro INITSUZY
F34C   A9 F3                LDA #$F3
F34E   8D 83 FC             STA SPRINIT		; Special fixed value (docs say $F3)
F351   A9 7F                LDA #$7F
F353   8D 28 FC             STA HSIZOFFL
F356   8D 2A FC             STA VSIZOFFL	; Default values for offsets
F359   A9 01                LDA #$01
F35B   8D 90 FC             STA SUZYBUSEN	; Enable Suzy busy
F35E   9C 90 FD             STZ SDONEACK
End macro INITSUZY

Macro SETDBUF $D000 $D000 (single buffer?)
F361   A9 00                LDA #$00
F363   8D 5B F7             STA $F75B		; ??
F366   A9 D0                LDA #$D0		
F368   8D 5C F7             STA $F75C		; ??
F36B   A9 00                LDA #$00
F36D   8D 5D F7             STA $F75D		; DISPADRL
F370   A9 D0                LDA #$D0
F372   8D 5E F7             STA $F75E		; DISPADRH
F375   9C 60 F7             STZ $F760		; DisplayFlags
End of SETDBUF macro

; Turn off all collisions
F378   AD 57 F7             LDA $F757		; __sprsys
F37B   09 20                ORA #$20		; Don't collide
F37D   8D 57 F7             STA $F757
F380   8D 92 FC             STA SPRSYS

Initialize color map
RGB16 macro F9ED
F383   A9 ED                LDA #$ED
F385   85 E0                STA $E0		; sysptr
F387   A9 F9                LDA #$F9
F389   85 E1                STA $E1
F38B   A0 1F                LDY #$1F		; Initialize palette at $F9ED
F38D   B1 E0      LF38D     LDA ($E0),Y
F38F   99 A0 FD             STA COLMAP,Y
F392   88                   DEY
F393   10 F8                BPL LF38D

F395   A9 14                LDA #$14
F397   8D 04 FC             STA HOFFL		; HOFF8 macro
F39A   A9 14                LDA #$14
F39C   8D 06 FC             STA VOFFL		; VOFF8 macro

INITLIT $F200,21 macro (full-screen buffer at $F200)
F39F   A9 00                LDA #$00		; Initialize 8 values in $F200 to #$15
F3A1   A2 F2                LDX #$F2
F3A3   85 E0                STA $E0
F3A5   86 E1                STX $E1
F3A7   A2 07                LDX #$07		; FONT_HEIGT
F3A9   A9 15      LF3A9     LDA #$15
F3AB   92 E0 		            STA ($E0)
F3AD   18		    CLC
F3AE   65 E0                ADC $E0
F3B0   85 E0                STA $E0
F3B2   90 02                BCC LF3B6
F3B4   E6 E1                INC $E1
F3B6   CA         LF3B6     DEX
F3B7   D0 F0                BNE LF3A9

F3B9   A9 00                LDA #$00
F3BB   92 E0                STA ($E0)
End INITLIT macro

INITLIT $F294, 5 macro
F3BD   A9 94 		            LDA #$94
F3BF   A2 F2                LDX #$F2
F3C1   85 E0                STA $E0
F3C3   86 E1                STX $E1
F3C5   A2 07                LDX #$07
F3C7   A9 05      LF3C7     LDA #$05
F3C9   92 E0                STA ($E0)
F3CB   18                   CLC
F3CC   65 E0                ADC $E0
F3CE   85 E0                STA $E0
F3D0   90 02                BCC LF3D4
F3D2   E6 E1                INC $E1
F3D4   CA         LF3D4     DEX
F3D5   D0 F0                BNE LF3C7

F3D7   A9 00                LDA #$00
F3D9   92 E0                STA ($E0)
End INITLIT macro

; Initialize serial interrupt handler
F3DB   A9 2D                LDA #$2D
F3DD   8D E8 EF             STA $EFE8
F3E0   A9 F7                LDA #$F7
F3E2   8D E9 EF             STA $EFE9

F3E5   A9 03                LDA #$03	
F3E7   8D 10 FD             STA TIM4BKUP	; 31250 baud
F3EA   A9 18                LDA #$18		; Enable reload and enable count
F3EC   8D 11 FD             STA TIM4CTLA
F3EF   A9 4D                LDA #$4D		;RXINTEN+RESETERR+TXOPEN+PAREVEN
F3F1   8D 8C FD             STA SERCTL

; Initialize buffer for receiving data?
F3F4   64 E6                STZ $E6    ; Last written to 0
F3F6   64 E7                STZ $E7    ; Last read to 0
F3F8   A9 FE                LDA #$FE
F3FA   85 EE                STA $EE    ; ????
F3FC   64 F8                STZ $F8    ; Set receive error count to zero 

Macro SPRITES FA0D, 0
F3FE   A9 0D                LDA #$0D
F400   8D 10 FC             STA SCBNEXTL		
F403   A9 FA                LDA #$FA
F405   8D 11 FC             STA SCBNEXTH
F408   AD 5B F7             LDA $F75B
F40B   8D 08 FC             STA VIDBASEL
F40E   AD 5C F7             LDA $F75C
F411   8D 09 FC             STA VIDBASEH
F414   9C 90 FD             STZ SDONEACK
F417   A9 01                LDA #$01
F419   8D 91 FC             STA SPRGO	
	
F41C   0C F9 FF             TSB MAPCTL
F41F   9C 91 FD             STZ CPUSLEEP
F422   1C F9 FF             TRB MAPCTL
F425   AD 92 FC             LDA DISPCTL
F428   29 01                AND #$01
F42A   D0 F0                BNE LF41C
F42C   9C 90 FD             STZ SDONEACK
End SPRITES macro 

protocol::
F42F   20 CA F6   LF42F     JSR LF6CA ; Read buffer

; Checking for data bytes 11, 07 according to segment number 0
F432   C9 11                CMP #$11
F434   D0 F9                BNE protocol
F436   20 CA F6             JSR LF6CA ; Read buffer
F439   C9 07                CMP #$07
F43B   D0 F2                BNE protocol

; Received magic bytes $1107
F43D   A9 25                LDA #$25    ; Reset left side progres bar
F43F   8D 44 FA             STA $FA44   ; Inside SCB data of progress HPOS Low byte 
F442   A9 1C                LDA #$1C    ; Reset to default data
F444   8D 3A FA             STA $FA3A   ; Inside SCB data of Text VPOS Low byte

F447   20 CA F6             JSR LF6CA   ; Receive byte for segment number SN
F44A   F0 0D                BEQ ReceiveSN0
F44C   C9 01                CMP #$01       ; SN1?
F44E   F0 11                BEQ WrongSN    ; $F461
F450   C9 02                CMP #$02       ; SN2?
F452   F0 0F                BEQ ReceiveSN2 ; $F463

F454   20 82 F4             JSR LF482   ; Bigger than 2?
F457   80 10                BRA ReceiveSN2

ReceiveSN0::
F459   20 82 F4             JSR LF482  ; ReceiveSN0Step1
F45C   20 32 F5             JSR LF532  ; LoadPaletteFromBuffer
F45F   80 CE                BRA protocol ; Start over 

WrongSN::
F461   80 CC                BRA protocol ; Doesn't exist, start over

; SN1
ReceiveSN2::
F463   20 84 F5   LF463     JSR LF584

ReceiveSN3plus::
F466   20 82 F4             JSR LF482

F469   78                   SEI
F46A   A9 0D                LDA #$0D
F46C   8D 8C FD             STA SERCTL
F46F   A9 FF                LDA #$FF
F471   8D 80 FD             STA INTRST   ; Reset all interrupt bits
F474   A2 0F                LDX #$0F
::loop
F476   9E A0 FD             STZ $FDA0,X
F479   9E B0 FD             STZ $FDB0,X
F47C   CA                   DEX
F47D   10 F7                BPL loop
F47F   6C E8 00             JMP ($00E8) ; Execute run address

ReceiveSN0Step1:
; Display sprite at $FA3D
Macro SPRITES $FA3D, 0
F482   A9 3D      LF482     LDA #$3D
F484   8D 10 FC             STA SCBNEXTL
F487   A9 FA                LDA #$FA
F489   8D 11 FC             STA SCBNEXTH
F48C   9C 90 FD             STZ SDONEACK
F48F   A9 01                LDA #$01
F491   8D 91 FC             STA SPRGO

F494   0C F9 FF             TSB MAPCTL
F497   9C 91 FD             STZ CPUSLEEP
F49A   1C F9 FF             TRB MAPCTL
F49D   AD 92 FC             LDA SPRSYS
F4A0   29 01                AND #$01
F4A2   D0 F0                BNE LF494

F4A4   9C 90 FD             STZ SDONEACK 
End SPRITES macro

F4A7   20 D7 F6             JSR LF6D7   ; Start address
F4AA   20 DD F6             JSR LF6DD   ; Load address
F4AD   20 E3 F6             JSR LF6E3   ; Data size
F4B0   20 F3 F6             JSR LF6F3   ; Load data

F4B3   A6 EC                LDX $EC     ; Lo byte load length
F4B5   E6 ED                INC $ED     ; Increase by 1 to compensate for decrease and BNE later at $F50B 

nextbyte:
F4B7   20 CA F6   LF4B7     JSR LF6CA   ; Receive byte from buffer 
F4BA   92 EA                STA ($EA)   ; Store at destination address
F4BC   E6 EA                INC $EA     ; Move to next spot
F4BE   D0 02                BNE next
F4C0   E6 EB                INC $EB     ; Increase high byte for wrap of lo

next: (Checksum?)
F4C2   DA         LF4C2     PHX         ; Contains current lo byte count of receive
F4C3   86 F5                STX $F5     ; 
F4C5   A6 EE                LDX $EE     ; ???
F4C7   BD 01 F1             LDA $F101,X ; 
F4CA   C5 ED                CMP $ED     ; ???
F4CC   D0 33                BNE SubA
F4CE   BD 00 F1             LDA $F100,X
F4D1   C5 F5                CMP $F5
F4D3   D0 2C                BNE SubA
F4D5   CA                   DEX
F4D6   CA                   DEX
F4D7   86 EE                STX $EE

; Redraw the indicator
F4D9   EE 44 FA             INC $FA44     ; Increase load indicator left side to right

Macro SPRITES FA3D, 0
F4DC   A9 3D                LDA #$3D
F4DE   8D 10 FC             STA SCBNEXTL
F4E1   A9 FA                LDA #$FA
F4E3   8D 11 FC             STA SCBNEXTH
F4E6   9C 90 FD             STZ SDONEACK
F4E9   A9 01                LDA #$01
F4EB   8D 91 FC             STA SPRGO
F4EE   0C F9 FF             TSB MAPCTL
F4F1   9C 91 FD             STZ CPUSLEEP
F4F4   1C F9 FF             TRB MAPCTL
F4F7   AD 92 FC             LDA SPRSYS
F4FA   29 01                AND #$01 ; Sprite process started and not completed or stopped
F4FC   D0 F0                BNE LF4EE
F4FE   9C 90 FD             STZ SDONEACK
End macro SPRITES

SubA::
F501   A5 F8      LF501     LDA $F8      ; Load error count
F503   D0 09                BNE LF50E    ; Display if error
F505   FA                   PLX          ; Restore receive count lo byte
F506   CA                   DEX          ; One less to go
F507   D0 AE                BNE nextbyte ; LF4B7
F509   C6 ED                DEC $ED      ; Decrease hi byte count
F50B   D0 AA                BNE nextbyte ; LF4B7
F50D   60                   RTS          ; All done

; Error situation?
F50E   A9 0F      LF50E     LDA #$0F
F510   8D B0 FD             STA BLUERED0  ; Full red for pen 0 == red background (on error?) 
again:
F513   20 18 F5             JSR LF518     ; check for press of Option1 to start over
F516   80 FB                BRA again

F518   AD B0 FC   LF518     LDA JOYSTICK
F51B   29 08                AND #$08      ; Option1
F51D   F0 12                BEQ escape
F51F   A9 01                LDA #$01
F521   2C B1 FC             BIT SWITCHES  ; Cart active???   
F524   F0 0B                BEQ escape
F526   9C B0 FD             STZ BLUERED0  ; Restore color
F529   2C B1 FC   LF529     BIT SWITCHES
F52C   D0 FB                BNE LF529     ; Wait until ????
F52E   4C F4 F3             JMP LF3F4     ; Start at initialization, try all over again
escape::
F531   60         LF531     RTS

LoadPaletteFromBuffer::
F532   A0 1F      LF532     LDY #$1F
F534   B1 E8      LF534     LDA ($E8),Y  ; Offset from load/run address
F536   99 A0 FD             STA $FDA0,Y  ; Store in palette
F539   88                   DEY
F53A   10 F8                BPL LF534

F53C   A9 00                LDA #$00
F53E   8D 04 FC             STA HOFFL
F541   8D 06 FC             STA VOFFL
F544   18                   CLC
F545   A5 E8                LDA $E8     ; Low byte load address
F547   69 20                ADC #$20
F549   85 E8                STA $E8     ; Update to skip 32 bytes to make sure SCB data can read from E8-E9
F54B   90 02                BCC LF54F
F54D   E6 E9                INC $E9     ; Increase high byte if necessary

Macro SPRITES $E8, 1 (zonder renderbuffer zetten)
F54F   A5 E8      LF54F     LDA $E8     ; Set SCB to current load address
F551   8D 10 FC             STA SCBNEXTL
F554   A5 E9                LDA $E9
F556   8D 11 FC             STA SCBNEXTH
F559   9C 90 FD             STZ SDONEACK
F55C   A9 01                LDA #$01
F55E   8D 91 FC             STA SPRGO
F561   0C F9 FF             TSB MAPCTL
F564   9C 91 FD             STZ CPUSLEEP
F567   1C F9 FF             TRB MAPCTL
F56A   AD 92 FC             LDA SPRSYS
F56D   29 01                AND #$01
F56F   D0 F0                BNE LF561
F571   9C 90 FD             STZ SDONEACK
End macro SPRITES

Restore original HOFF and VOFF
F574   A9 14                LDA #$14
F576   8D 04 FC             STA HOFFL
F579   A9 14                LDA #$14
F57B   8D 06 FC             STA VOFFL
F57E   A9 25                LDA #$25
F580   8D 44 FA             STA $FA44   ; Restore location of progress bar
F583   60                   RTS

; Receive name
F584   A2 FF      LF584     LDX #$FF
F586   E8         LF586     INX
F587   20 CA F6             JSR LF6CA   ; Read from buffer
F58A   9D B8 F2             STA $F2B8,X ; Should read to F2E1 maximum , as code starts at F2E2 (41 chars)
F58D   D0 F7                BNE LF586   ; Read until zero value is encountered
; Receive copyright
F58F   20 DD F6             JSR LF6DD   ; Get year (instead of load address) into $EB-$EC

; Create four digit hex value in buffer $F9A5-$F9A8 for year
F592   A5 EB                LDA $EB
F594   48                   PHA
F595   4A                   LSR A
F596   4A                   LSR A
F597   4A                   LSR A
F598   4A                   LSR A
F599   1A                   INC
F59A   1A                   INC
F59B   8D A5 F9             STA $F9A5  ; Text buffer for hex values of receive count
F59E   68                   PLA
F59F   29 0F                AND #$0F
F5A1   1A                   INC
F5A2   1A                   INC
F5A3   8D A6 F9             STA $F9A6
F5A6   A5 EA                LDA $EA 
F5A8   48                   PHA
F5A9   4A                   LSR A
F5AA   4A                   LSR A
F5AB   4A                   LSR A
F5AC   4A                   LSR A
F5AD   1A                   INC
F5AE   1A                   INC
F5AF   8D A7 F9             STA $F9A7
F5B2   68                   PLA
F5B3   29 0F                AND #$0F
F5B5   1A                   INC
F5B6   1A                   INC
F5B7   8D A8 F9             STA $F9A8 

; Load 20 chars for author
F5BA   A2 FF                LDX #$FF
F5BC   E8         LF5BC     INX
F5BD   20 CA F6             JSR LF6CA    ; Load byte from buffer
F5C0   9D CD F2             STA $F2CD,X
F5C3   D0 F7                BNE LF5BC    ; Repeat until zero byte is received (must be max 20 chars)

; Move 24 pixels down from top
F5C5   A9 18                LDA #$18
F5C7   20 C2 F6             JSR LF6C2    ; Increases $FA3A with $18

; Call HandyPrint with $F2B8 Name of game into $F200 sprite text buffer 
F5CA   A9 B8                LDA #$B8
F5CC   85 E0                STA $E0      ; sysptr
F5CE   A9 F2                LDA #$F2
F5D0   85 E1                STA $E1      ; sysptr
F5D2   A9 00                LDA #$00
F5D4   8D F9 00             STA $00F9    ; TextPtr
F5D7   A9 F2                LDA #$F2
F5D9   8D FA 00             STA $00FA    ; TextPtr+1
F5DC   20 D7 F7             JSR LF7D7

Macro SPRITES $FA31,1
F5DF   A9 31                LDA #$31
F5E1   8D 10 FC             STA SCBNEXTL
F5E4   A9 FA                LDA #$FA
F5E6   8D 11 FC             STA SCBNEXTH
F5E9   9C 90 FD             STZ 
F5EC   A9 01                LDA #$01
F5EE   8D 91 FC             STA $FC91
F5F1   0C F9 FF             TSB MAPCTL
F5F4   9C 91 FD             STZ 
F5F7   1C F9 FF             TRB MAPCTL
F5FA   AD 92 FC             LDA 
F5FD   29 01                AND #$01
F5FF   D0 F0                BNE LF5F1
F601   9C 90 FD             STZ SDONEACK
End macro SPRITES

F604   A9 18                LDA #$18
F606   20 C2 F6             JSR LF6C2       ; Move VPOS of text 18 down?

F609   A9 9B                LDA #$9B        ; sysptr => $F99B
F60B   85 E0                STA $E0
F60D   A9 F9                LDA #$F9
F60F   85 E1                STA $E1

F611   A9 00                LDA #$00        ; TextPtr => $F200
F613   8D F9 00             STA $00F9
F616   A9 F2                LDA #$F2
F618   8D FA 00             STA $00FA
F61B   20 D7 F7             JSR LF7D7       ; Call HandyPrint

Macro SPRITES $FA31,1
F61E   A9 31                LDA #$31
F620   8D 10 FC             STA $FC10
F623   A9 FA                LDA #$FA
F625   8D 11 FC             STA $FC11
F628   9C 90 FD             
F62B   A9 01                LDA #$01
F62D   8D 91 FC             STA $FC91
F630   0C F9 FF             TSB MAPCTL
F633   9C 91 FD             STZ 
F636   1C F9 FF             TRB MAPCTL
F639   AD 92 FC             
F63C   29 01                AND #$01
F63E   D0 F0                BNE LF630
F640   9C 90 FD             STZ SDONEACK
End macro SPRITES

; Print year
F643   A9 09                LDA #$09
F645   20 C2 F6             JSR LF6C2       ; Move 9 pixels down

F648   A9 A5                LDA #$A5        ; sysptr => $F9A5
F64A   85 E0                STA $E0
F64C   A9 F9                LDA #$F9
F64E   85 E1                STA $E1
F650   A9 00                LDA #$00        ; TextPtr => $F200
F652   8D F9 00             STA $00F9
F655   A9 F2                LDA #$F2
F657   8D FA 00             STA $00FA
F65A   20 D7 F7             JSR LF7D7       ; Call HandyPrint

Macro SPRITES FA31,1
F65D   A9 31                LDA #$31
F65F   8D 10 FC             STA $FC10
F662   A9 FA                LDA #$FA
F664   8D 11 FC             STA $FC11
F667   9C 90 FD             BCC LF667
F66A   A9 01                LDA #$01
F66C   8D 91 FC             STA $FC91
F66F   0C F9 FF
F662   9C 91 FD             STA ($FD),Y
F675   1C F9 FF 
F678   AD 92 FC
F67B   29 01                AND #$01
F67D   D0 F0                BNE LF66F
F67F   9C 90 FD

; Print author
F682   A9 09                LDA #$09
F684   20 C2 F6             JSR LF6C2     ; Move 9 lines down
F687   A9 CD                LDA #$CD      ; sysptr => $F2CD
F689   85 E0                STA $E0
F68B   A9 F2                LDA #$F2
F68D   85 E1                STA $E1
F68F   A9 00                LDA #$00      ; TextPtr => $F200
F691   8D F9 00             STA $00F9
F694   A9 F2                LDA #$F2
F696   8D FA 00             STA $00FA
F699   20 D7 F7             JSR LF7D7     ; HandyPrint

Macro SPRITES $FA31,1
F69C   A9 31                LDA #$31
F69E   8D 10 FC             STA $FC10
F6A1   A9 FA                LDA #$FA
F6A3   8D 11 FC             STA $FC11
F6A6   9C 90 FD
F6A9   A9 01                LDA #$01
F6AB   8D 91 FC             STA $FC91
F6AE   0C F9 FF 
F6B1   9C 91 FD             
F6B4   1C F9 FF 
F6B7   AD 92 FC             
F6BA   29 01                AND #$01
F6BC   D0 F0                BNE LF6AE
F6BE   9C 90 FD             BCC LF6BE
F6C1   60                   RTS

; Move line position down by A pixels
F6C2   18         LF6C2     CLC
F6C3   6D 3A FA             ADC $FA3A
F6C6   8D 3A FA             STA $FA3A
F6C9   60                   RTS

Subroutine load from buffer to destination at ($E7-$E8)
F6CA   A4 E7      LF6CA     LDY $E7
F6CC   C4 E6                CPY $E6
F6CE   F0 FA                BEQ LF6CA    ; Wait until data in buffer is available
F6D0   C8                   INY
F6D1   B9 00 F0             LDA $F000,Y
F6D4   84 E7                STY $E7
F6D6   60                   RTS

GetRunAddress:
F6D7   A2 E8      LF6D7     LDX #$E8    ; Run address
F6D9   20 E9 F6             JSR LF6E9
F6DC   60                   RTS

GetLoadAddress
F6DD   A2 EA      LF6DD     LDX #$EA    ; Load address
F6DF   20 E9 F6             JSR LF6E9
F6E2   60                   RTS

GetDataSize
F6E3   A2 EC      LF6E3     LDX #$EC    ; Receive count/data size
F6E5   20 E9 F6             JSR LF6E9
F6E8   60                   RTS

; Read two consecutive bytes from buffer and store at X and X+1 in ZP 
F6E9   20 ED F6   LF6E9     JSR LF6ED
F6EC   E8                   INX
F6ED   20 CA F6   LF6ED     JSR LF6CA  ; Read from buffer
F6F0   95 00                STA $00,X
F6F2   60                   RTS

; Load data according to data size ($EC) into destination $(EA) 
F6F3   A5 EC      LF6F3     LDA $EC
F6F5   0A                   ASL A
F6F6   85 EF                STA $EF
F6F8   85 F2                STA $F2
F6FA   A5 ED                LDA $ED
F6FC   2A                   ROL A
F6FD   85 F0                STA $F0
F6FF   85 F3                STA $F3
F701   A9 00                LDA #$00
F703   2A                   ROL A
F704   85 F1                STA $F1
F706   1A                   ???                ;%00011010
F707   85 F4                STA $F4
F709   A2 00                LDX #$00
F70B   A5 F3      LF70B     LDA $F3
F70D   9D 00 F1             STA $F100,X
F710   A5 F4                LDA $F4
F712   9D 01 F1             STA $F101,X
F715   18                   CLC
F716   A5 EF                LDA $EF
F718   65 F2                ADC $F2
F71A   85 F2                STA $F2
F71C   A5 F0                LDA $F0
F71E   65 F3                ADC $F3
F720   85 F3                STA $F3
F722   A5 F1                LDA $F1
F724   65 F4                ADC $F4
F726   85 F4                STA $F4
F728   E8                   INX
F729   E8                   INX
F72A   D0 DF                BNE LF70B
F72C   60                   RTS

; Serial interrupt handler
F72D   A2 05                LDX #$05		; TXOPEN+PAREVEN (no interrupts for now)
F72F   8E 8C FD             STX SERCTL
F732   A9 10                LDA #$10
F734   8D 80 FD             STA INTRST		; Reset timer interrupt bit for serial
F737   AD 8C FD             LDA SERCTL
F73A   89 40                BIT #$40		; RXRDY data available?
F73C   F0 11                BEQ LF74F		; No, skip to return

F73E   29 1C                AND #$1C		; PARERR+OVERRUN+FRAMERR 
F740   F0 02                BEQ LF744		; Check for errors
F742   E6 F8                INC $F8		  ; Count errors?

F744   AD 8D FD   LF744     LDA SERDAT		; Load serial data
F747   A6 E6                LDX $E6		    ; Store in circular buffer
F749   E8                   INX
F74A   86 E6                STX $E6
F74C   9D 00 F0             STA $F000,X		; Buffer at $F000-F0FF

F74F   A2 4D      LF74F     LDX #$4D		; RXINTEN+RESETERR+TXOPEN+PAREVEN
F751   8E 8C FD             STX SERCTL
F754   4C 7E F7             JMP IntReturn		; End IRQ

SEGMENT .DATA
(sysdata.src)
F757   00                   BRK			; __sprsys
F758   00                   BRK			; __dispctl (see $F7AC and )
F759   00                   BRK			; __iodat
F75A   00                   BRK			; __iodir
F75B   00                   BRK			; ?
F75C   00                   BRK			; ?
F75D   00                   BRK			; DISPADRL value (read at $F7C4)
F75E   00                   BRK			; DISPADRH value
F75F   00                   BRK			; Save interrupt bits from INTSET
F760   00                   BRK			; DisplayFlags

.CODE from sys.src

; ISR routine!
UserIntHandler
F761   48                   PHA			; Store A and X
F762   DA                   PHX
F763   AD 81 FD             LDA INTSET		; Load interrupt bits
F766   89 10 		    BIT #$10		; Check for serial interrupt
F768   F0 03                BEQ $F76D
F76A   6C E8 EF             JMP ($EFE8)		; Use 4th entry in jump table
	
F76D   8D 5F F7             STA $F75F		; Save INTSET
F770   A2 00                LDX #$00
F772   A9 01                LDA #$01
F774   2C 5F F7   LF774     BIT $F75F		; Check for interrupt starting at 1
F777   D0 08                BNE LF781
F779   E8                   INX
F77A   E8                   INX
F77B   0A                   ASL A
F77C   D0 F6                BNE LF774

; Dummy IRQ handler (initial destination of jump table entries)
IntReturn
F77E   FA         LF77E     PLX			; End interrupt
F77F   68                   PLA
F780   40                   RTI

jumpIntTable
F781   8D 80 FD   LF781     STA INTRST		; Reset interrupt bit
F784   7C E0 EF             JMP ($EFE0,X)	; Use jump table

.CODE End of sys.src

.CODE display.src

InitDisplayer
F787   AD E4 EF   LF787     LDA $EFE4		; Modify jump address using third entry (timer 2)
F78A   8D D5 F7             STA $F7D5
F78D   AD E5 EF             LDA $EFE5
F790   8D D6 F7             STA $F7D6

F793   A9 9E                LDA #$9E		; Set third entry to handler at $F79E
F795   8D E4 EF             STA $EFE4
F798   A9 F7                LDA #$F7
F79A   8D E5 EF             STA $EFE5
F79D   60                   RTS

; End-of-Frame Handler
FrameEnd
F79E   5A                   PHY
F79F   AD F9 FF             LDA MAPCTL
F7A2   48                   PHA
F7A3   29 FE                AND #$FE
F7A5   8D F9 FF             STA MAPCTL		; Switch to RAM

TIMEOUT macro does nothing here

F7A8   68                   PLA
F7A9   8D F9 FF             STA MAPCTL	

DISPLAY macro	
F7AC   AD 58 F7             LDA $F758		; __dispctl
F7AF   8D 92 FD             STA DISPCTL
F7B2   29 02                AND #$02		; FLIP
F7B4   F0 0E                BEQ LF7C4

; This alternates screen base addresses between $D000 and $EFE0
F7B6   AD 5D F7             LDA $F75D		
F7B9   18                   CLC
F7BA   69 DF                ADC #$DF		; Shift #$1FDF to set address to 
F7BC   AA                   TAX
F7BD   AD 5E F7             LDA $F75E
F7C0   69 1F                ADC #$1F
F7C2   80 06 		    BRA $F7CA

F7C4   AE 5D F7 	    LDX $F75D
F7C7   AD 5E F7		    LDA $F75E

DISP_AX macro
F7CA   08             	    PHP
F7CB   78                   SEI
F7CC   8E 94 FD             STX DISPADRL	; 
F7CF   8D 95 FD             STA DISPADRH
F7D2   28                   PLP
End DISP_AX macro
End DISPLAY macro

F7D3   7A                   PLY

FrameEndExit
; Self modified destination from $F787-$F792 to FrameEnd 
F7D4   4C 7E F7             JMP LF77E		; IntReturn
; End of code display.src

.CODE for hprint.src

HandyPrint
F7D7   A5 F9      LF7D7     LDA $F9		; TextPtr
F7D9   85 E2                STA $E2
F7DB   A5 FA                LDA $FA		; TextPtr+1
F7DD   85 E3                STA $E3
F7DF   B2 E2                LDA ($E2)
F7E1   85 FB                STA $FB		; TextWidth
F7E3   3A                   DEC
F7E4   85 FC                STA $FC		; TextRemaining

hprintLoop
F7E6   B2 E0 		    LDA ($E0)
F7E8   D0 08                BNE 
F7EA   9C 61 FC             STZ MATHG		; Setup shortcut for math
F7ED   A6 FC                LDX $FC
F7EF   D0 1E                BNE LF80F
F7F1   60                   RTS

F7F2   3A         LF7F2     DEC
F7F3   8D 54 FC             STA MATHB
F7F6   A9 07                LDA #$07		; FONT_HEIGHT
F7F8   8D 52 FC             STA MATHD
F7FB   9C 53 FC             STZ MATHC
F7FE   9C 55 FC             STZ MATHA
F801   E6 E0                INC $E0
F803   D0 02                BNE LF807
F805   E6 E1                INC $E1

Macro WAITMATH
F807   2C 92 FC   LF807     BIT $FC92
F80A   30 FB                BMI LF807
End WAITMATH macro

F80C   AD 60 FC             LDA MATHH
F80F   18         LF80F     CLC
F810   69 44                ADC #$44		; <FontBase
F812   85 E4                STA $E4		; sysptr3
F814   AD 61 FC             LDA MATHG
F817   69 F8                ADC #$F8		; >FontBase
F819   85 E5                STA $E5
F81B   E6 F9                INC $F9
F81D   D0 02                BNE LF821
F81F   E6 FA                INC $FA
F821   A5 F9      LF821     LDA $F9
F823   85 E2                STA $E2
F825   A5 FA                LDA $FA
F827   85 E3                STA $E3
F829   A0 06                LDY #$06		; FONT_HEIGHT-1
F82B   B1 E4      LF82B     LDA ($E4),Y
F82D   92 E2                STA (sysptr2)
F82F   A5 E2                LDA sysptr2
F831   18                   CLC
F832   65 FB                ADC $FB
F834   85 E2                STA $E2
F836   A5 E3                LDA $E3
F838   69 00                ADC #$00
F83A   85 E3                STA $E3
F83C   88                   DEY
F83D   10 EC                BPL LF82B		; hprintCharLoop
F83F   C6 FC                DEC $FC
F841   4C E6 F7             JMP LF7E6		; hprintloop

End code for hprint.src

FontBase

Macro HPRFONT HPRDIGIT+UPPER+PUNC
; space
F844   00                   BRK
F845   00                   BRK
F846   00                   BRK
F847   00                   BRK
F848   00                   BRK
F849   00                   BRK
F84A   00                   BRK

; 0
F84B   7C                   ;%01111100
F84C   C6                   ;%11000110
F84D   E6                   ;%11100110
F84E   D6                   ;%11010110
F84E   CE                   ;%11001110
F850   C6                   ;%11000110                
F851   7C                   ;%01111100

; 1
F852   FE 18 18             ; 1
F855   18                   
F856   78                   
F857   38                   
F858   18                   

; 2
F859   FE 30 18             INC $1830,X
F85C   0C                   ???                ;%00001100
F85D   06 C6                ASL $C6
F85F   7C                   ???                ;%01111100 '|'

;3
F860   7C                   ???                ;%01111100 '|'
F861   C6 06                DEC $06
F863   0C                   ???                ;%00001100
F864   06 C6                ASL $C6
F866   7C                   ???                ;%01111100 '|'

;4
F867   0C                   ???                ;%00001100
F868   0C                   ???                ;%00001100
F869   FE CC 6C             INC $6CCC,X
F86C   3C                   ???                ;%00111100 '<'
F86D   1C                   ???                ;%00011100

;5
F86E   FC                   ???                ;%11111100
F86F   06 06                ASL $06
F871   FC                   ???                ;%11111100
F872   C0 C0                CPY #$C0
F874   FC                   ???                ;%11111100

;6
F875   7C                   ???                ;%01111100 '|'
F876   C6 C6                DEC $C6
F878   FC                   ???                ;%11111100
F879   C0 C0                CPY #$C0
F87B   7C                   ???                ;%01111100 '|'

;7
F87C   C0 60                CPY #$60
F87E   30 18                BMI LF898
F880   0C                   ???                ;%00001100
F881   06 FE                ASL $FE

;8
F883   7C                   ???                ;%01111100 '|'
F884   C6 C6                DEC $C6
F886   7C                   ???                ;%01111100 '|'
F887   C6 C6                DEC $C6
F889   7C                   ???                ;%01111100 '|'

;9
F88A   7C                   ;%01111100 
F88B   06                   ;%00000110
F88C   06                   ;%00000110
F88D   7E                   ;%01111110
F88D   C6                   ;%11000110
F88D   C6                   ;%11000110
F890   7C                   ;%01111100

;A
F891   C6                   ;%11000110
F892   C6                   ;%11000110
F893   C6                   ;%11000110
F894   FE                   ;%11111110
F895   C6                   ;%11000110
F896   6C                   ;%01101100
F897   38                   ;%00111000

F898   FC         LF898     ???                ;%11111100
F899   C6 C6                DEC $C6
F89B   FC                   ???                ;%11111100
F89C   C6 C6                DEC $C6
F89E   FC                   ???                ;%11111100

F89F   7C                   ???                ;%01111100 '|'
F8A0   C6 C0                DEC $C0
F8A2   C0 C0                CPY #$C0
F8A4   C6 7C                DEC $7C

F8A6   FC                   ???                ;%11111100
F8A7   C6 C6                DEC $C6
F8A9   C6 C6                DEC $C6
F8AB   C6 FC                DEC $FC

F8AD   FE C0 C0             INC $C0C0,X
F8B0   F8                   SED
F8B1   C0 C0                CPY #$C0
F8B3   FE 

C0 C0             INC $C0C0,X
F8B6   C0 F8                CPY #$F8
F8B8   C0 C0                CPY #$C0
F8BA   FE 

7E C6             INC $C67E,X
F8BD   C6 CE                DEC $CE
F8BF   C0 C6                CPY #$C6
F8C1   7C                   ???                ;%01111100 '|'

F8C2   C6 C6                DEC $C6
F8C4   C6 FE                DEC $FE
F8C6   C6 C6                DEC $C6
F8C8   C6 

;I
F8C9   7E                   ;%01111110
F8CA   18                   ;%00011000
F8CB   18                   CLC
F8CC   18                   CLC
F8CD   18                   CLC
F8CE   18                   CLC
F8CF   7E 

7C C6             	    ;%1100ROR $C67C,X
F8D2   06 06                ASL $06
F8D4   06 06                ASL $06
F8D6   7E 

C6 
CC             ROR $CCC6,X
F8D9   D8                   CLD
F8DA   F0 D8                BEQ LF8B4
F8DC   CC C6 

FE             CPY $FEC6
F8DF   C0 C0                CPY #$C0
F8E1   C0 C0                CPY #$C0
F8E3   C0 C0                CPY #$C0

F8E5   C6 C6                DEC $C6
F8E7   C6 D6                DEC $D6
F8E9   FE EE C6             INC $C6EE,X

F8EC   C6 C6                DEC $C6
F8EE   CE DE F6             DEC $F6DE
F8F1   E6 C6                INC $C6

F8F3   7C                   ???                ;%01111100 '|'
F8F4   C6 C6                DEC $C6
F8F6   C6 C6                DEC $C6
F8F8   C6 7C                DEC $7C

F8FA   C0 C0                CPY #$C0
F8FC   C0 FC                CPY #$FC
F8FE   C6 C6                DEC $C6
F900   FC                   ???                ;%11111100

F901   7A                   ???                ;%01111010 'z'
F902   CE D6 C6             DEC $C6D6
F905   C6 C6                DEC $C6
F907   7C                   ???                ;%01111100 '|'

F908   C6 CC                DEC $CC
F90A   D8                   CLD
F90B   FC                   ???                ;%11111100
F90C   C6 C6                DEC $C6
F90E   FC                   ???                ;%11111100

F90F   7C                   ???                ;%01111100 '|'
F910   C6 06                DEC $06
F912   7C                   ???                ;%01111100 '|'
F913   C0 C6                CPY #$C6
F915   7C                   ???                ;%01111100 '|'

F916   18                   CLC
F917   18                   CLC
F918   18                   CLC
F919   18                   CLC
F91A   18                   CLC
F91B   18                   CLC
F91C   7E 

7C C6             ROR $C67C,X
F91F   C6 C6                DEC $C6
F921   C6 C6                DEC $C6
F923   C6 

38                DEC $38
F925   38                   SEC
F926   6C 6C 6C             JMP ($6C6C)
F929   C6 C6                DEC $C6

F92B   6C D6 D6             JMP ($D6D6)
F92E   D6 C6                DEC $C6,X
F930   C6 C6                DEC $C6

F932   C6 C6                DEC $C6
F934   6C 38 6C             JMP ($6C38)
F937   C6 C6                DEC $C6

;Y
F939   18                   ;%00011000
F93A   18                   ;%00011000
F93B   18                   ;%00011000
F93C   18                   ;%00011000
F93D   3C                   ;%00111100 '<'
F93E   66                   ;%01100110
F93F   66                   ;%01100110

;Z
F940   FE                   ;%11111110
F941   C0                   ;%11000000
F942   60                   ;%01100000
F943   30                   ;%00110000
F943   18                   ;%00011000
F945   0C                   ;%00001100
F946   FE                   ;%11111110

;!
F946   18                   ;%00011000
F947   00                   ;%00000000
F949   18                   ;%00011000
F94A   3C                   ;%00111100 '<'
F94B   3C                   ;%00111100 '<'
F94C   3C                   ;%00111100 '<'
F94D   18                   ;%00011000

; "
F94E   00                   BRK
F94F   00                   BRK
F950   00                   BRK
F951   00                   BRK
F952   66 66                ROR $66
F954   66 

; ' 
F955   00                   ROR $00
F956   00                   BRK
F957   00                   BRK
F958   00                   BRK
F959   30                   ;%00110000
F959   18                   ;%00011000
F95B   18                   ;%00011000

; (
F95C   0C                   ;%00001100
F95D   18         LF95D     CLC
F95E   30 30                BMI LF990
F960   30 18                BMI LF97A
F962   0C                   ???                ;%00001100

; )
F963   30                   BMI LF97D
F963   18                   ;%00011000
F965   0C                   ;%00001100
F966   0C                   ;%00001100
F967   0C                   ;%00001100
F968   18                   ;%00011000
F969   30 		    ;%00110000

; ,
F96A   30                   ;%00110000
F96B   18                   ;%00011000
F96C   18                   ;%00011000
F96D   00                   BRK
F96E   00                   BRK
F96F   00                   BRK
F970   00                   BRK

; -
F971   00                   BRK
F972   00                   BRK
F973   00         LF973     BRK
F974   3C                   ???                ;%00111100 '<'
F975   00                   BRK
F976   00                   BRK
F977   00                   BRK

; .
F978   18                   CLC
F979   18                   CLC
F97A   00         LF97A     BRK
F97B   00                   BRK
F97C   00                   BRK
F97D   00         LF97D     BRK
F97E   00                   BRK

; :
F97F   00                   BRK
F980   18                   CLC
F981   18                   CLC
F982   00                   BRK
F983   18                   CLC
F984   18                   CLC
F985   00                   BRK

; ;
F986   30 18                BMI LF9A0
F988   18                   CLC
F989   00                   BRK
F98A   18                   CLC
F98B   18                   CLC
F98C   00                   BRK

; ?
F98D   18                   CLC
F98E   00                   BRK
F98F   18                   CLC
F990   0C         LF990     ;%00001100
F991   06                   ;%00000110
F991   C6                   ;%11000110
F993   7C                   ;%01111100
End of plain font

F994   A5                   ;%10100101
F995   5A                   ;%01011010
F996   A5                   ;%10100101
F997   5A                   ;%01011010
F998   A5                   ;%10100101
F999   5A                   ;%01011010
F99A   A5                   ;%10100101
Nix7

F99B   0E                   ;%00001110
F99C   1A                   ;%00011010
F99D   1B                   ;%00011011
F99E   24                   ;%00100100
F99E   1D                   ;%00011101
F9A0   14         LF9A0     ;%00010100
F9A1   12                   ;%00010010
F9A2   13                   ???                ;%00010011
F9A3   1F                   ???                ;%00011111
F9A4   00                   BRK
F9A5   01 01                ORA ($01,X)
F9A7   01 01                ORA ($01,X)
F9A9   01 0D                ORA ($0D,X)
F9AB   24 00                BIT $00

; Sprite Data for SCB at FA21
F9AD   08
F9AE   7D F7 DF 7D F7 DF 14 
; 01111101 11110111 11011111             01111101 11110111 11011111 00010100
; 0 1111 1  0 1111 1  0 1111 1 0 1111 1  0 1111 1  0 1111 1  0 1111 1 0 1111 1  0 0010 1 00
; 8*16+3 = 131 pixels from 16 to 146
F9B5   0B
F9B6   85 E7 A1 79 C8 5E 72 17 9E 84 
F9C0   0B
F9C1   85 E7 A1 79 C8 5E 72 17 9E 84 
FC9B   0B
F9CC   85 E7 A1 79 C8 5E 72 17 9E 84 
F9D6   0B
F9D7   85 E7 A1 79 C8 5E 72 17 9E 84
F9E1   08
F9E2   7D F7 DF 7D F7 DF 14 
F9E9   00

; Sprite data for SCB at $FA3D
F9EA   02                   ; Single pixel sprite
F9EB   80                   
F9EC   00                   BRK

; Palette values
F9ED   00 00 0F 00 0F 0F 00 0F
F9F5   07 07 00 07 00 07 00 07
F9FD   00 0F 00 F0 F0 0F FF FF
FA05   7F 77 07 00 70 07 77 70 

; SCB data Clear screen
FA0D   01                   BACKNONCOLL_SPRITE
FA0E   B0                   LITERAL+RELOAD_HVST
FA0F   00                   SPRCOLL
FA10   21 FA      LFA10     SCBNEXT
FA12   EA F9                SCBDATA single pixel
FA14   14 00                HPOS  ; Compensate for HOFF and VOFF?
FA16   14 00                VPOS
FA18   00 A0                HSIZE ; full screen
FA1A   00 66                VSIZE
FA1C   00 00                STRETCH
FA1E   00 00                TILT
FA20   00                   Palette uses pen 0 for both colors
;Next SCB Frame around progress bar 
FA21   01                   BACKNONCOLL_SPRITE
FA22   10                   RELOAD_HV
FA23   00                   SPRCOLL
FA24   00 00                SCBNEXT
FA26   AD F9                SCBDATA
FA28   24 00                
FA2A   73 00                HPOS 
FA2C   00 01 
FA2E   00 01 
FA30   07                   Palette uses pen 7 for color 1

; SCB data for displaying text
FA31   05                   SPRCTL0_NON_COLLIDABLE+SPRCTL0_2_COL
FA32   80                   SPRCTL1_LITERAL+SPRCTL1_DEPTH_NO_RELOAD
FA33   00                   SPRCOLL
FA34   00 00                SCBNEXT
FA36   00 F2                sprite data at $F200
FA38   1C 00                HPOS
FA3A   1C 00                VPOS
FABC   02                   Palette 2 colors pen 2 for color 1

; SCB data for progress bar (Fits inside frame at (16,95) to (146,101))
; Sprite draws new vertical pixel line by increasing HPOS. No double buffers
FA3D   05                   SPRCTL0_NON_COLLIDABLE+SPRCTL0_2_COL
FA3E   90                   SPRCTL1_LITERAL+RELOAD_HV
FA3F   00                   SPRCOLL
FA40   00 00                SCBNEXT
FA42   EA F9                SCB data single pixel
FA44   25 00                HPOS (17, compensating for #$14 offset)
FA46   74 00                VPOS (96, compensating for #$14 offset)
FA48   00 01                HSIZE normal horizontal size
FA4A   00 04                VSIZE 4 pixels high
FA4C   06                   Palette 2 colors pen 6 for color 1
FA4D   00                   ? One byte too much?
.END