%include "io.inc"
section .data
    ;input data:
    M: dd 1.4,4.0,3.8,0.2,0.6,2.0,2.0,2.0,2.0,2.0,2.0,2.0,4.0,4.0,4.0
    N: dd ($-M)/4
    ;temproral variables:
    X: dd 0.0
    ;printing formats:
    format:dd "Average = %f",0
section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging
    finit
    ;Calculating the average using the formula:
    ;X=0 initially then X=X+x(i) for i 0->N-1 and then X=X/N 
    fld dword[X]
    mov ecx, -1
    loop1:
        inc ecx
        cmp ecx, [N]
        jge end
        fadd dword[M+4*ecx]
        jmp loop1
    end:
    fidiv dword[N]
    fstp dword[X]
    ;Now printing the result
    sub esp, 8
    fld dword[X]
    fstp qword[esp]
    push format
    call _printf
    add esp, 12
    xor eax, eax
    ret