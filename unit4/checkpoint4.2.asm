  .file [name="checkpoint4.2.bin", type="bin", segments="XMega65Bin"]
.segmentdef XMega65Bin [segments="Syscall, Code, Data, Stack, Zeropage"]
.segmentdef Syscall [start=$8000, max=$81ff]
.segmentdef Code [start=$8200, min=$8200, max=$bdff]
.segmentdef Data [startAfter="Code", min=$8200, max=$bdff]
.segmentdef Stack [min=$be00, max=$beff, fill]
.segmentdef Zeropage [min=$bf00, max=$bfff, fill]
  // Some definitions of addresses and special values that this program uses
  .label RASTER = $d012
  .label VIC_MEMORY = $d018
  .label SCREEN = $400
  .label BGCOL = $d021
  .label COLS = $d800
  .const BLACK = 0
  .const WHITE = 1
  .const JMP = $4c
  .const NOP = $ea
  .label current_screen_line = $f
  .label current_screen_x = $e
  lda #<0
  sta.z current_screen_line
  sta.z current_screen_line+1
  sta.z current_screen_x
  jsr main
  rts
.segment Code
main: {
    .label sc = 4
    .label msg = 2
    lda #$14
    sta VIC_MEMORY
    ldx #' '
    lda #<SCREEN
    sta.z memset.str
    lda #>SCREEN
    sta.z memset.str+1
    lda #<$28*$19
    sta.z memset.num
    lda #>$28*$19
    sta.z memset.num+1
    jsr memset
    ldx #WHITE
    lda #<COLS
    sta.z memset.str
    lda #>COLS
    sta.z memset.str+1
    lda #<$28*$19
    sta.z memset.num
    lda #>$28*$19
    sta.z memset.num+1
    jsr memset
    lda #<SCREEN+$28
    sta.z sc
    lda #>SCREEN+$28
    sta.z sc+1
    lda #<MESSAGE
    sta.z msg
    lda #>MESSAGE
    sta.z msg+1
  // The messag to display
  b1:
    ldy #0
    lda (msg),y
    cmp #0
    bne b2
  b3:
    lda #$36
    cmp RASTER
    beq b4
    lda #$42
    cmp RASTER
    beq b4
    lda #BLACK
    sta BGCOL
    jmp b3
  b4:
    lda #WHITE
    sta BGCOL
    jmp b3
  b2:
    ldy #0
    lda (msg),y
    sta (sc),y
    inc.z sc
    bne !+
    inc.z sc+1
  !:
    inc.z msg
    bne !+
    inc.z msg+1
  !:
    jmp b1
}
// Copies the character c (an unsigned char) to the first num characters of the object pointed to by the argument str.
// memset(void* zeropage(8) str, byte register(X) c, word zeropage(6) num)
memset: {
    .label end = 6
    .label dst = 8
    .label num = 6
    .label str = 8
    lda.z num
    bne !+
    lda.z num+1
    beq breturn
  !:
    lda.z end
    clc
    adc.z str
    sta.z end
    lda.z end+1
    adc.z str+1
    sta.z end+1
  b2:
    lda.z dst+1
    cmp.z end+1
    bne b3
    lda.z dst
    cmp.z end
    bne b3
  breturn:
    rts
  b3:
    txa
    ldy #0
    sta (dst),y
    inc.z dst
    bne !+
    inc.z dst+1
  !:
    jmp b2
}
CPUKIL: {
    rts
}
RESERVED: {
    rts
}
VF011WR: {
    rts
}
VF011RD: {
    rts
}
ALTTABKEY: {
    rts
}
RESTORKEY: {
    rts
}
PAGFAULT: {
    rts
}
//This is the reset function
RESET: {
    lda #<$400
    sta.z current_screen_line
    lda #>$400
    sta.z current_screen_line+1
    lda #0
    sta.z current_screen_x
    lda #$14
    sta VIC_MEMORY
    ldx #' '
    lda #<SCREEN
    sta.z memset.str
    lda #>SCREEN
    sta.z memset.str+1
    lda #<$28*$19
    sta.z memset.num
    lda #>$28*$19
    sta.z memset.num+1
    jsr memset
    ldx #WHITE
    lda #<COLS
    sta.z memset.str
    lda #>COLS
    sta.z memset.str+1
    lda #<$28*$19
    sta.z memset.num
    lda #>$28*$19
    sta.z memset.num+1
    jsr memset
    jsr start_simple_program
    rts
}
start_simple_program: {
    lda #$80
    sta $300
    lda #0
    sta $301
    lda #$81
    sta $302
    lda #0
    sta $303
    sta $304
    sta $305
    sta $306
    lda #$60
    sta $307
    lda #2
    sta $308
    lda #0
    sta $309
    lda #2
    sta $30a
    lda #1
    sta $30b
    lda #8
    sta $30c
    lda #0
    sta $30d
    sta $30e
    sta $30f
    lda #$60
    sta $310
    lda #3
    sta $d701
    lda #0
    sta $d702
    sta $d705
    lda #<$80d
    sta $d648
    lda #>$80d
    sta $d648+1
    jsr exit_hypervisor
    rts
}
exit_hypervisor: {
    // Trigger exit from Hypervisor mode
    lda #1
    sta $d67f
    rts
}
undefined_trap: {
    rts
}
syscall64: {
    jsr exit_hypervisor
    rts
}
syscall63: {
    jsr exit_hypervisor
    rts
}
syscall62: {
    jsr exit_hypervisor
    rts
}
syscall61: {
    jsr exit_hypervisor
    rts
}
syscall60: {
    jsr exit_hypervisor
    rts
}
syscall59: {
    jsr exit_hypervisor
    rts
}
syscall58: {
    jsr exit_hypervisor
    rts
}
syscall57: {
    jsr exit_hypervisor
    rts
}
syscall56: {
    jsr exit_hypervisor
    rts
}
syscall55: {
    jsr exit_hypervisor
    rts
}
syscall54: {
    jsr exit_hypervisor
    rts
}
syscall53: {
    jsr exit_hypervisor
    rts
}
syscall52: {
    jsr exit_hypervisor
    rts
}
syscall51: {
    jsr exit_hypervisor
    rts
}
syscall50: {
    jsr exit_hypervisor
    rts
}
syscall49: {
    jsr exit_hypervisor
    rts
}
syscall48: {
    jsr exit_hypervisor
    rts
}
syscall47: {
    jsr exit_hypervisor
    rts
}
syscall46: {
    jsr exit_hypervisor
    rts
}
syscall45: {
    jsr exit_hypervisor
    rts
}
syscall44: {
    jsr exit_hypervisor
    rts
}
syscall43: {
    jsr exit_hypervisor
    rts
}
syscall42: {
    jsr exit_hypervisor
    rts
}
syscall41: {
    jsr exit_hypervisor
    rts
}
syscall40: {
    jsr exit_hypervisor
    rts
}
syscall39: {
    jsr exit_hypervisor
    rts
}
syscall38: {
    jsr exit_hypervisor
    rts
}
syscall37: {
    jsr exit_hypervisor
    rts
}
syscall36: {
    jsr exit_hypervisor
    rts
}
syscall35: {
    jsr exit_hypervisor
    rts
}
syscall34: {
    jsr exit_hypervisor
    rts
}
syscall33: {
    jsr exit_hypervisor
    rts
}
syscall32: {
    jsr exit_hypervisor
    rts
}
syscall30: {
    jsr exit_hypervisor
    rts
}
syscall29: {
    jsr exit_hypervisor
    rts
}
syscall28: {
    jsr exit_hypervisor
    rts
}
syscall27: {
    jsr exit_hypervisor
    rts
}
syscall26: {
    jsr exit_hypervisor
    rts
}
syscall25: {
    jsr exit_hypervisor
    rts
}
syscall24: {
    jsr exit_hypervisor
    rts
}
syscall23: {
    jsr exit_hypervisor
    rts
}
syscall22: {
    jsr exit_hypervisor
    rts
}
syscall21: {
    jsr exit_hypervisor
    rts
}
syscall20: {
    jsr exit_hypervisor
    rts
}
syscall19: {
    jsr exit_hypervisor
    rts
}
syscall18: {
    jsr exit_hypervisor
    rts
}
syscall17: {
    jsr exit_hypervisor
    rts
}
syscall16: {
    jsr exit_hypervisor
    rts
}
syscall15: {
    jsr exit_hypervisor
    rts
}
syscall14: {
    jsr exit_hypervisor
    rts
}
syscall13: {
    jsr exit_hypervisor
    rts
}
syscall12: {
    jsr exit_hypervisor
    rts
}
syscall11: {
    jsr exit_hypervisor
    rts
}
syscall10: {
    jsr exit_hypervisor
    rts
}
syscall9: {
    jsr exit_hypervisor
    rts
}
syscall8: {
    jsr exit_hypervisor
    rts
}
syscall7: {
    jsr exit_hypervisor
    rts
}
syscall6: {
    jsr exit_hypervisor
    rts
}
syscall5: {
    jsr exit_hypervisor
    rts
}
syscall4: {
    jsr exit_hypervisor
    rts
}
//syscall functions
syscall3: {
    jsr exit_hypervisor
    rts
}
syscall2: {
    lda #'{'
    sta SCREEN+$4e
    lda #<message
    sta.z print_to_screen.msg
    lda #>message
    sta.z print_to_screen.msg+1
    jsr print_to_screen
    jsr print_newline
    jsr exit_hypervisor
    rts
  .segment Data
    message: .text "syscall01 entered"
    .byte 0
}
.segment Code
print_newline: {
    lda #$28
    clc
    adc.z current_screen_line
    sta.z current_screen_line
    bcc !+
    inc.z current_screen_line+1
  !:
    lda #0
    sta.z current_screen_x
  b1:
    lda.z current_screen_line+1
    cmp #>SCREEN+$28*$19
    bcc !+
    bne b2
    lda.z current_screen_line
    cmp #<SCREEN+$28*$19
    bcs b2
  !:
    rts
  b2:
    lda.z current_screen_line
    sec
    sbc #<$19
    sta.z current_screen_line
    lda.z current_screen_line+1
    sbc #>$19
    sta.z current_screen_line+1
    jmp b1
}
print_to_screen: {
    .label sc = $c
    .label msg = $a
    lda.z current_screen_x
    clc
    adc.z current_screen_line
    sta.z sc
    lda #0
    adc.z current_screen_line+1
    sta.z sc+1
  b1:
    ldy #0
    lda (msg),y
    cmp #0
    bne b2
  b3:
    lda.z current_screen_x
    cmp #$28
    bcs b4
    rts
  b4:
    lax.z current_screen_x
    axs #$28
    stx.z current_screen_x
    inc.z current_screen_line
    bne !+
    inc.z current_screen_line+1
  !:
    jmp b3
  b2:
    ldy #0
    lda (msg),y
    sta (sc),y
    inc.z sc
    bne !+
    inc.z sc+1
  !:
    inc.z msg
    bne !+
    inc.z msg+1
  !:
    inc.z current_screen_x
    jmp b1
}
syscall1: {
    lda #'}'
    sta SCREEN+$4f
    lda #<MESSAGE
    sta.z print_to_screen.msg
    lda #>MESSAGE
    sta.z print_to_screen.msg+1
    jsr print_to_screen
    jsr print_newline
    lda #<message1
    sta.z print_to_screen.msg
    lda #>message1
    sta.z print_to_screen.msg+1
    jsr print_to_screen
    jsr print_newline
    jsr exit_hypervisor
    rts
  .segment Data
    message1: .text "syscall00 entered"
    .byte 0
}
  // Some text to display
  MESSAGE: .text "checkpoint4.2 by aman0130"
  .byte 0
.segment Syscall
SYSCALLS:
  .byte JMP
  .word syscall1
  .byte NOP
  .byte JMP
  .word syscall2
  .byte NOP
  .byte JMP
  .word syscall3
  .byte NOP
  .byte JMP
  .word syscall4
  .byte NOP
  .byte JMP
  .word syscall5
  .byte NOP
  .byte JMP
  .word syscall6
  .byte NOP
  .byte JMP
  .word syscall7
  .byte NOP
  .byte JMP
  .word syscall8
  .byte NOP
  .byte JMP
  .word syscall9
  .byte NOP
  .byte JMP
  .word syscall10
  .byte NOP
  .byte JMP
  .word syscall11
  .byte NOP
  .byte JMP
  .word syscall12
  .byte NOP
  .byte JMP
  .word syscall13
  .byte NOP
  .byte JMP
  .word syscall14
  .byte NOP
  .byte JMP
  .word syscall15
  .byte NOP
  .byte JMP
  .word syscall16
  .byte NOP
  .byte JMP
  .word syscall17
  .byte NOP
  .byte JMP
  .word syscall18
  .byte NOP
  .byte JMP
  .word syscall19
  .byte NOP
  .byte JMP
  .word syscall20
  .byte NOP
  .byte JMP
  .word syscall21
  .byte NOP
  .byte JMP
  .word syscall22
  .byte NOP
  .byte JMP
  .word syscall23
  .byte NOP
  .byte JMP
  .word syscall24
  .byte NOP
  .byte JMP
  .word syscall25
  .byte NOP
  .byte JMP
  .word syscall26
  .byte NOP
  .byte JMP
  .word syscall27
  .byte NOP
  .byte JMP
  .word syscall28
  .byte NOP
  .byte JMP
  .word syscall29
  .byte NOP
  .byte JMP
  .word syscall30
  .byte NOP
  .byte JMP
  .word syscall13
  .byte NOP
  .byte JMP
  .word syscall32
  .byte NOP
  .byte JMP
  .word syscall33
  .byte NOP
  .byte JMP
  .word syscall34
  .byte NOP
  .byte JMP
  .word syscall35
  .byte NOP
  .byte JMP
  .word syscall36
  .byte NOP
  .byte JMP
  .word syscall37
  .byte NOP
  .byte JMP
  .word syscall38
  .byte NOP
  .byte JMP
  .word syscall39
  .byte NOP
  .byte JMP
  .word syscall40
  .byte NOP
  .byte JMP
  .word syscall41
  .byte NOP
  .byte JMP
  .word syscall42
  .byte NOP
  .byte JMP
  .word syscall43
  .byte NOP
  .byte JMP
  .word syscall44
  .byte NOP
  .byte JMP
  .word syscall45
  .byte NOP
  .byte JMP
  .word syscall46
  .byte NOP
  .byte JMP
  .word syscall47
  .byte NOP
  .byte JMP
  .word syscall48
  .byte NOP
  .byte JMP
  .word syscall49
  .byte NOP
  .byte JMP
  .word syscall50
  .byte NOP
  .byte JMP
  .word syscall51
  .byte NOP
  .byte JMP
  .word syscall52
  .byte NOP
  .byte JMP
  .word syscall53
  .byte NOP
  .byte JMP
  .word syscall54
  .byte NOP
  .byte JMP
  .word syscall55
  .byte NOP
  .byte JMP
  .word syscall56
  .byte NOP
  .byte JMP
  .word syscall57
  .byte NOP
  .byte JMP
  .word syscall58
  .byte NOP
  .byte JMP
  .word syscall59
  .byte NOP
  .byte JMP
  .word syscall60
  .byte NOP
  .byte JMP
  .word syscall61
  .byte NOP
  .byte JMP
  .word syscall62
  .byte NOP
  .byte JMP
  .word syscall63
  .byte NOP
  .byte JMP
  .word syscall64
  .byte NOP
  .align $100
TRAPS:
  .byte JMP
  .word RESET
  .byte NOP
  .byte JMP
  .word PAGFAULT
  .byte NOP
  .byte JMP
  .word RESTORKEY
  .byte NOP
  .byte JMP
  .word ALTTABKEY
  .byte NOP
  .byte JMP
  .word VF011RD
  .byte NOP
  .byte JMP
  .word VF011WR
  .byte NOP
  .byte JMP
  .word RESERVED
  .byte NOP
  .byte JMP
  .word CPUKIL
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
  .byte JMP
  .word undefined_trap
  .byte NOP
