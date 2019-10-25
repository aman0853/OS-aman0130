// XMega65 Kernal Development Template
// Each function of the kernal is a no-args function
// The functions are placed in the SYSCALLS table surrounded by JMP and NOP
  .file [name="os5.1.bin", type="bin", segments="XMega65Bin"]
.segmentdef XMega65Bin [segments="Syscall, Code, Data, Stack, Zeropage"]
.segmentdef Syscall [start=$8000, max=$81ff]
.segmentdef Code [start=$8200, min=$8200, max=$bdff]
.segmentdef Data [startAfter="Code", min=$8200, max=$bdff]
.segmentdef Stack [min=$be00, max=$beff, fill]
.segmentdef Zeropage [min=$bf00, max=$bfff, fill]
  .const SIZEOF_WORD = 2
  .const OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME = 2
  .const OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS = 4
  .const OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_END_ADDRESS = 8
  .const OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE = $c
  .label RASTER = $d012
  .label VIC_MEMORY = $d018
  .label SCREEN = $400
  .label BGCOL = $d021
  .label COLS = $d800
  .const BLACK = 0
  .const WHITE = 1
  // Process stored state will live at $C000-$C7FF, with 256 bytes
  // for each process reserved
  .label stored_pdbs = $c000
  // To save writing 0x4C and 0xEA all the time, we define them as constants
  .const JMP = $4c
  .const NOP = $ea
  .label current_screen_line = 8
  .label current_screen_x = $a
  lda #<SCREEN
  sta.z current_screen_line
  lda #>SCREEN
  sta.z current_screen_line+1
  lda #0
  sta.z current_screen_x
  jsr main
  rts
.segment Code
main: {
    jsr exit_hypervisor
    rts
}
exit_hypervisor: {
    lda #1
    sta $d67f
    rts
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
RESET: {
    .label sc = $d
    .label msg = 2
    //Initialize screen memory, and select correct font
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
  // A simple copy routine to copy the string
  //print_to_screen(MESSAGE);
  //print_newline();
  __b1:
    ldy #0
    lda (msg),y
    cmp #0
    bne __b2
    lda #<SCREEN
    sta.z current_screen_line
    lda #>SCREEN
    sta.z current_screen_line+1
    jsr print_newline
    jsr print_newline
    jsr describe_pdb
    jsr exit_hypervisor
  __b4:
    lda #$36
    cmp RASTER
    beq __b5
    lda #$42
    cmp RASTER
    beq __b5
    lda #BLACK
    sta BGCOL
    jmp __b4
  __b5:
    lda #WHITE
    sta BGCOL
    jmp __b4
  __b2:
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
    jmp __b1
}
describe_pdb: {
    .label p = stored_pdbs
    .label n = $d
    .label ss = 2
    jsr print_newline
    lda #<message
    sta.z print_to_screen.c
    lda #>message
    sta.z print_to_screen.c+1
    jsr print_to_screen
    lda #<0
    sta.z print_hex.value
    sta.z print_hex.value+1
    jsr print_hex
    lda #<message1
    sta.z print_to_screen.c
    lda #>message1
    sta.z print_to_screen.c+1
    jsr print_to_screen
    jsr print_newline
    lda #<message2
    sta.z print_to_screen.c
    lda #>message2
    sta.z print_to_screen.c+1
    jsr print_to_screen
    lda p
    sta.z print_hex.value
    lda #0
    sta.z print_hex.value+1
    jsr print_hex
    jsr print_newline
    lda #<message3
    sta.z print_to_screen.c
    lda #>message3
    sta.z print_to_screen.c+1
    jsr print_to_screen
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME
    sta.z n
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME+1
    sta.z n+1
    ldx #0
  __b1:
    txa
    tay
    lda (n),y
    cmp #0
    beq __b3
    cpx #$11
    bcc __b2
  __b3:
    jsr print_newline
    lda #<message4
    sta.z print_to_screen.c
    lda #>message4
    sta.z print_to_screen.c+1
    jsr print_to_screen
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS
    sta.z print_dhex.value
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+1
    sta.z print_dhex.value+1
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+2
    sta.z print_dhex.value+2
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+3
    sta.z print_dhex.value+3
    jsr print_dhex
    jsr print_newline
    lda #<message5
    sta.z print_to_screen.c
    lda #>message5
    sta.z print_to_screen.c+1
    jsr print_to_screen
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_END_ADDRESS
    sta.z print_dhex.value
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_END_ADDRESS+1
    sta.z print_dhex.value+1
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_END_ADDRESS+2
    sta.z print_dhex.value+2
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_END_ADDRESS+3
    sta.z print_dhex.value+3
    jsr print_dhex
    jsr print_newline
    lda #<message6
    sta.z print_to_screen.c
    lda #>message6
    sta.z print_to_screen.c+1
    jsr print_to_screen
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE
    sta.z ss
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE+1
    sta.z ss+1
    ldy #4*SIZEOF_WORD
    lda (print_hex.value),y
    pha
    iny
    lda (print_hex.value),y
    sta.z print_hex.value+1
    pla
    sta.z print_hex.value
    jsr print_hex
    jsr print_newline
    rts
  __b2:
    txa
    tay
    lda (n),y
    jsr print_char
    inx
    jmp __b1
  .segment Data
    message: .text "pdb#"
    .byte 0
    message1: .text ":"
    .byte 0
    message2: .text "  pid:          "
    .byte 0
    message3: .text "  process name: "
    .byte 0
    message4: .text "  mem start:    $"
    .byte 0
    message5: .text "  mem end:      $"
    .byte 0
    message6: .text "  pc:           $"
    .byte 0
}
.segment Code
// print_char(byte register(A) c)
print_char: {
    ldy.z current_screen_x
    sta (current_screen_line),y
    inc.z current_screen_x
    rts
}
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
    rts
}
// print_hex(word zeropage(2) value)
print_hex: {
    .label __3 = $b
    .label __6 = $d
    .label value = 2
    ldx #0
  __b1:
    cpx #8
    bcc __b2
    lda #0
    sta hex+4
    lda #<hex
    sta.z print_to_screen.c
    lda #>hex
    sta.z print_to_screen.c+1
    jsr print_to_screen
    rts
  __b2:
    lda.z value+1
    cmp #>$a000
    bcc __b4
    bne !+
    lda.z value
    cmp #<$a000
    bcc __b4
  !:
    ldy #$c
    lda.z value
    sta.z __3
    lda.z value+1
    sta.z __3+1
    cpy #0
    beq !e+
  !:
    lsr.z __3+1
    ror.z __3
    dey
    bne !-
  !e:
    lda.z __3
    sec
    sbc #9
    sta hex,x
  __b5:
    asl.z value
    rol.z value+1
    asl.z value
    rol.z value+1
    asl.z value
    rol.z value+1
    asl.z value
    rol.z value+1
    inx
    jmp __b1
  __b4:
    ldy #$c
    lda.z value
    sta.z __6
    lda.z value+1
    sta.z __6+1
    cpy #0
    beq !e+
  !:
    lsr.z __6+1
    ror.z __6
    dey
    bne !-
  !e:
    lda.z __6
    clc
    adc #'0'
    sta hex,x
    jmp __b5
  .segment Data
    hex: .fill 5, 0
}
.segment Code
print_to_screen: {
    .label c = $d
  __b1:
    ldy #0
    lda (c),y
    cmp #0
    bne __b2
    rts
  __b2:
    ldy #0
    lda (c),y
    ldy.z current_screen_x
    sta (current_screen_line),y
    inc.z current_screen_x
    inc.z c
    bne !+
    inc.z c+1
  !:
    jmp __b1
}
// print_dhex(dword zeropage(4) value)
print_dhex: {
    .label __0 = $f
    .label value = 4
    lda #0
    sta.z __0+2
    sta.z __0+3
    lda.z value+3
    sta.z __0+1
    lda.z value+2
    sta.z __0
    sta.z print_hex.value
    lda.z __0+1
    sta.z print_hex.value+1
    jsr print_hex
    lda.z value
    sta.z print_hex.value
    lda.z value+1
    sta.z print_hex.value+1
    jsr print_hex
    rts
}
// Copies the character c (an unsigned char) to the first num characters of the object pointed to by the argument str.
// memset(void* zeropage($b) str, byte register(X) c, word zeropage($d) num)
memset: {
    .label end = $d
    .label dst = $b
    .label num = $d
    .label str = $b
    lda.z num
    bne !+
    lda.z num+1
    beq __breturn
  !:
    lda.z end
    clc
    adc.z str
    sta.z end
    lda.z end+1
    adc.z str+1
    sta.z end+1
  __b2:
    lda.z dst+1
    cmp.z end+1
    bne __b3
    lda.z dst
    cmp.z end
    bne __b3
  __breturn:
    rts
  __b3:
    txa
    ldy #0
    sta (dst),y
    inc.z dst
    bne !+
    inc.z dst+1
  !:
    jmp __b2
}
undefined_trap: {
    rts
}
altTabKey: {
    rts
}
restorKey: {
    rts
}
pagfault: {
    rts
}
syscall3F: {
    jsr exit_hypervisor
    rts
}
syscall3E: {
    jsr exit_hypervisor
    rts
}
syscall3D: {
    jsr exit_hypervisor
    rts
}
syscall3C: {
    jsr exit_hypervisor
    rts
}
syscall3B: {
    jsr exit_hypervisor
    rts
}
syscall3A: {
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
syscall2F: {
    jsr exit_hypervisor
    rts
}
syscall2E: {
    jsr exit_hypervisor
    rts
}
syscall2D: {
    jsr exit_hypervisor
    rts
}
syscall2C: {
    jsr exit_hypervisor
    rts
}
syscall2B: {
    jsr exit_hypervisor
    rts
}
syscall2A: {
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
syscall1F: {
    jsr exit_hypervisor
    rts
}
syscall1E: {
    jsr exit_hypervisor
    rts
}
syscall1D: {
    jsr exit_hypervisor
    rts
}
syscall1C: {
    jsr exit_hypervisor
    rts
}
syscall1B: {
    jsr exit_hypervisor
    rts
}
syscall1A: {
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
securExit: {
    jsr exit_hypervisor
    rts
}
securEntr: {
    jsr exit_hypervisor
    rts
}
syscall10: {
    jsr exit_hypervisor
    rts
}
syscall0F: {
    jsr exit_hypervisor
    rts
}
syscall0E: {
    jsr exit_hypervisor
    rts
}
syscall0D: {
    jsr exit_hypervisor
    rts
}
syscall0C: {
    jsr exit_hypervisor
    rts
}
syscall0B: {
    jsr exit_hypervisor
    rts
}
syscall0A: {
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
    jsr exit_hypervisor
    rts
}
syscall01: {
    jsr exit_hypervisor
    rts
}
//XXX - Copy in your syscalls, RESET() function and entry point tables from
//      checkpoint3.1
syscall00: {
    jsr exit_hypervisor
    rts
}
.segment Data
  MESSAGE: .text "checkpoint 5.1 aman0130"
  .byte 0
.segment Syscall
  //XXX - Now add the following lines to your RESET() function just before the
  // Loop forever with 2 bars"
  .align $100
  SYSCALL_RESET: .byte JMP
  .word syscall00
  .byte NOP, JMP
  .word syscall01
  .byte NOP, JMP
  .word syscall02
  .byte NOP, JMP
  .word syscall03
  .byte NOP, JMP
  .word syscall04
  .byte NOP, JMP
  .word syscall05
  .byte NOP, JMP
  .word syscall06
  .byte NOP, JMP
  .word syscall07
  .byte NOP, JMP
  .word syscall08
  .byte NOP, JMP
  .word syscall09
  .byte NOP, JMP
  .word syscall0A
  .byte NOP, JMP
  .word syscall0B
  .byte NOP, JMP
  .word syscall0C
  .byte NOP, JMP
  .word syscall0D
  .byte NOP, JMP
  .word syscall0E
  .byte NOP, JMP
  .word syscall0F
  .byte NOP, JMP
  .word syscall10
  .byte NOP, JMP
  .word securEntr
  .byte NOP, JMP
  .word securExit
  .byte NOP, JMP
  .word syscall13
  .byte NOP, JMP
  .word syscall14
  .byte NOP, JMP
  .word syscall15
  .byte NOP, JMP
  .word syscall16
  .byte NOP, JMP
  .word syscall17
  .byte NOP, JMP
  .word syscall18
  .byte NOP, JMP
  .word syscall19
  .byte NOP, JMP
  .word syscall1A
  .byte NOP, JMP
  .word syscall1B
  .byte NOP, JMP
  .word syscall1C
  .byte NOP, JMP
  .word syscall1D
  .byte NOP, JMP
  .word syscall1E
  .byte NOP, JMP
  .word syscall1F
  .byte NOP, JMP
  .word syscall20
  .byte NOP, JMP
  .word syscall21
  .byte NOP, JMP
  .word syscall22
  .byte NOP, JMP
  .word syscall23
  .byte NOP, JMP
  .word syscall24
  .byte NOP, JMP
  .word syscall25
  .byte NOP, JMP
  .word syscall26
  .byte NOP, JMP
  .word syscall27
  .byte NOP, JMP
  .word syscall28
  .byte NOP, JMP
  .word syscall29
  .byte NOP, JMP
  .word syscall2A
  .byte NOP, JMP
  .word syscall2B
  .byte NOP, JMP
  .word syscall2C
  .byte NOP, JMP
  .word syscall2D
  .byte NOP, JMP
  .word syscall2E
  .byte NOP, JMP
  .word syscall2F
  .byte NOP, JMP
  .word syscall30
  .byte NOP, JMP
  .word syscall31
  .byte NOP, JMP
  .word syscall32
  .byte NOP, JMP
  .word syscall33
  .byte NOP, JMP
  .word syscall34
  .byte NOP, JMP
  .word syscall35
  .byte NOP, JMP
  .word syscall36
  .byte NOP, JMP
  .word syscall37
  .byte NOP, JMP
  .word syscall38
  .byte NOP, JMP
  .word syscall39
  .byte NOP, JMP
  .word syscall3A
  .byte NOP, JMP
  .word syscall3B
  .byte NOP, JMP
  .word syscall3C
  .byte NOP, JMP
  .word syscall3D
  .byte NOP, JMP
  .word syscall3E
  .byte NOP, JMP
  .word syscall3F
  .byte NOP
  .align $100
  TRAPS: .byte JMP
  .word RESET
  .byte NOP, JMP
  .word pagfault
  .byte NOP, JMP
  .word restorKey
  .byte NOP, JMP
  .word altTabKey
  .byte NOP, JMP
  .word VF011RD
  .byte NOP, JMP
  .word VF011WR
  .byte NOP, JMP
  .word RESERVED
  .byte NOP, JMP
  .word CPUKIL
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP
