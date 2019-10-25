.pc = $801 "Basic"
:BasicUpstart(main)
.pc = $80d "Program"
main: {
    jsr process_info
    jsr end_program
    rts
}
end_program: {
    jsr enable_syscalls
    lda #0
    sta $d644
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
process_info: {
    jsr enable_syscalls
    lda #0
    sta $d643
    nop
    rts
}
