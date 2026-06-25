; NASM x86-64 Linux exact-length PositionTape generator.
; Change TAPE_LENGTH to compare against a different official fixture.

%define TAPE_LENGTH 100

section .bss
output: resb TAPE_LENGTH
marker: resb 32

section .text
global _start

_start:
    mov r12, 1              ; cursor
    xor r13, r13            ; written

.generate_loop:
    cmp r13, TAPE_LENGTH
    jae .write_output
    mov rax, r12
    xor rdx, rdx
    mov rbx, 10
    div rbx
    cmp rdx, 0
    je .write_marker

    add dl, '0'
    mov [output + r13], dl
    inc r13
    inc r12
    jmp .generate_loop

.write_marker:
    ; rax already contains cursor / 10.
    lea rdi, [marker + 31]
    xor rcx, rcx
.digits_reverse:
    xor rdx, rdx
    mov rbx, 10
    div rbx
    add dl, '0'
    dec rdi
    mov [rdi], dl
    inc rcx
    test rax, rax
    jne .digits_reverse

    mov r8, rcx             ; marker length
.copy_marker:
    cmp rcx, 0
    je .marker_done
    cmp r13, TAPE_LENGTH
    jae .marker_done
    mov al, [rdi]
    mov [output + r13], al
    inc rdi
    inc r13
    dec rcx
    jmp .copy_marker

.marker_done:
    add r12, r8
    jmp .generate_loop

.write_output:
    mov rax, 1              ; write
    mov rdi, 1              ; stdout
    lea rsi, [output]
    mov rdx, TAPE_LENGTH
    syscall

    mov rax, 60             ; exit
    xor rdi, rdi
    syscall
