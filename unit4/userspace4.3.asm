.pc = $801 "Basic"
:BasicUpstart(main)
.pc = $80d "Program"
main: {
    jsr call_syscall00
    jsr call_syscall01
  b1:
    jmp b1
}
call_syscall01: {
    jsr enable_syscalls
    lda #0
    sta $d641
    nop
    rts
}
enable_syscalls: {
    lda #$47
    sta $d02f
    lda #$53
    sta $d02f
    rts
}
call_syscall00: {
    jsr enable_syscalls
    lda #0
    sta $d640
    nop
    rts
}
