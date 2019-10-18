  .file [name="checkpoint3.1.bin", type="bin", segments="XMega65Bin"]
.segmentdef XMega65Bin [segments="Syscall, Code, Data, Stack, Zeropage"]
.segmentdef Syscall [start=$8000, max=$81ff]
.segmentdef Code [start=$8200, min=$8200, max=$bdff]
.segmentdef Data [startAfter="Code", min=$8200, max=$bdff]
.segmentdef Stack [min=$be00, max=$beff, fill]
.segmentdef Zeropage [min=$bf00, max=$bfff, fill]
  .label VIC_MEMORY = $d018
  .label SCREEN = $400
  .label COLS = $d800
  .const WHITE = 1
  .const JMP = $4c
  .const NOP = $ea
  .label current_screen_line = 2
.segment Code
main: {
    rts
}
CPUKIL: {
    jsr exit_hypervisor
    rts
}
exit_hypervisor: {
    lda #1
    sta $d67f
    rts
}
UNDEFINED_TRAPS: {
    jsr exit_hypervisor
    rts
}
VF011WR: {
    jsr exit_hypervisor
    rts
}
VF011RD: {
    jsr exit_hypervisor
    rts
}
ALTTABKEY: {
    jsr exit_hypervisor
    rts
}
RESTORKEY: {
    jsr exit_hypervisor
    rts
}
PAGFAULT: {
    jsr exit_hypervisor
    rts
}
RESET: {
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
    lda #<MESSAGE
    sta.z print_to_screen.message
    lda #>MESSAGE
    sta.z print_to_screen.message+1
    lda #<$400
    sta.z current_screen_line
    lda #>$400
    sta.z current_screen_line+1
    jsr print_to_screen
    jsr print_newline
    lda #<MESSAGE2
    sta.z print_to_screen.message
    lda #>MESSAGE2
    sta.z print_to_screen.message+1
    lda #<$400+$28
    sta.z current_screen_line
    lda #>$400+$28
    sta.z current_screen_line+1
    jsr print_to_screen
  b2:
    jmp b2
}
// print_to_screen(byte* zeropage(4) message)
print_to_screen: {
    .label sc = 6
    .label message = 4
    lda.z current_screen_line
    sta.z sc
    lda.z current_screen_line+1
    sta.z sc+1
  b1:
    ldy #0
    lda (message),y
    cmp #0
    bne b2
    rts
  b2:
    ldy #0
    lda (message),y
    sta (sc),y
    inc.z sc
    bne !+
    inc.z sc+1
  !:
    inc.z message
    bne !+
    inc.z message+1
  !:
    jmp b1
}
print_newline: {
    rts
}
// Copies the character c (an unsigned char) to the first num characters of the object pointed to by the argument str.
// memset(void* zeropage(6) str, byte register(X) c, word zeropage(4) num)
memset: {
    .label end = 4
    .label dst = 6
    .label num = 4
    .label str = 6
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
syscall31: {
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
SECUREXIT: {
    jsr exit_hypervisor
    rts
}
SECURENTR: {
    jsr exit_hypervisor
    rts
}
syscall10: {
    jsr exit_hypervisor
    rts
}
syscall09: {
    jsr exit_hypervisor
    rts
}
syscall08: {
    jsr exit_hypervisor
    rts
}
syscall07: {
    jsr exit_hypervisor
    rts
}
syscall06: {
    jsr exit_hypervisor
    rts
}
syscall05: {
    jsr exit_hypervisor
    rts
}
syscall04: {
    jsr exit_hypervisor
    rts
}
syscall03: {
    jsr exit_hypervisor
    rts
}
syscall02: {
    lda #'<'
    sta SCREEN+$4e
    jsr exit_hypervisor
    rts
}
syscall01: {
    lda #'>'
    sta SCREEN+$4f
    jsr exit_hypervisor
    rts
}
.segment Data
  MESSAGE: .text "aman0130 operating system starting.."
  .byte 0
  MESSAGE2: .text "testing hardware"
  .byte 0
.segment Syscall
SYSCALLS:
  .byte JMP
  .word syscall01
  .byte NOP
  .byte JMP
  .word syscall02
  .byte NOP
  .byte JMP
  .word syscall03
  .byte NOP
  .byte JMP
  .word syscall04
  .byte NOP
  .byte JMP
  .word syscall05
  .byte NOP
  .byte JMP
  .word syscall06
  .byte NOP
  .byte JMP
  .word syscall07
  .byte NOP
  .byte JMP
  .word syscall08
  .byte NOP
  .byte JMP
  .word syscall09
  .byte NOP
  .byte JMP
  .word syscall10
  .byte NOP
  .byte JMP
  .word SECURENTR
  .byte NOP
  .byte JMP
  .word SECUREXIT
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
  .word syscall31
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
SYSCALL_TRAPS:
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
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word UNDEFINED_TRAPS
  .byte NOP
  .byte JMP
  .word CPUKIL
  .byte NOP
