%include "io.inc"
section .data
    ;input data
    M: dd 1.4,4.0,3.8,0.2,0.6,1.4,4.0,3.8,0.2,0.6,1.4,4.0,3.8,0.2,0.6,1.4,4.0,3.8,0.2,0.6,9.0,45.0,12.0,36.0,2.0,1.0,0.0,7.0,8.0,-5.0
    N: dd ($-M)/4
    ;temporal variables for use in the program
    X: dd 0.0
    S: dd 0.0
    ;printing formats
    format: db "Standard Deviation = %f",0
section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging
    ;calculating the average
    finit
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
    mov ecx, -1
    ;calculating the standard deviation using the formula
    ;S=((x(i)-X)^2)/N for i from 0 to N-1
    finit
    fldz
    loop2:
        inc ecx
        cmp ecx, [N]
        jge end2
        fld dword[M+ecx*4]
        fsub dword[X]
        sub esp, 4
        fst dword[esp]
        fmul dword[esp]
        add esp, 4
        faddp
        jmp loop2
    end2:
    fidiv dword[N]
    fstp dword[S]
    ;printing
    sub esp, 8
    fld dword[S]
    ;fsqrt would've been used if the formula given contained a square root of the square mean
    fstp qword[esp]
    push format
    call _printf
    add esp, 12
    xor eax, eax
    ret