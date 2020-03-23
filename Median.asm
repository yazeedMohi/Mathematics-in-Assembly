%include "io.inc"
section .data
    ;input data:
    M: dd 2.0,5.0,3.0,1.0,4.0,8.0,6.0,9.0,7.0,12.0,13.0,14.0,15.0,16.0,16.0,16.0,16.0,16.0,18.0,99.0
    N: dd ($-M)/4
    ;temporal variables:
    key: dd 0.0
    Med: dd 0.0
    ;constants to be used in FPU calculations:
    two: dd 2.0
    format: db "Median = %f",0
section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging
    ;Sorting:
    ;Insertion sort algorithm is used where each element is choosed as the pivot in each cycle then the every element less than it is put before it
    mov edx, 0
    loop1:
        finit
        mov ecx, edx
        inc edx
        cmp edx, [N]
        jge end1
        fld dword[M+edx*4]
        fstp dword[key]
        inc ecx
        loop2:
            dec ecx
            cmp ecx, -1
            jle end2
            fld dword[M+ecx*4]
            fld dword[key]
            fcom
            fnstsw ax 
            sahf
            ja end2
            finit
            sub esp, 4
            fld dword[M+ecx*4]
            fstp dword[esp]
            mov ebx, ecx
            inc ebx
            fld dword[M+ebx*4]
            fstp dword[M+ecx*4]
            fld dword[esp]
            fstp dword[M+ebx*4]
            add esp, 4
            jmp loop2
        end2:
        finit
        inc ecx
        fld dword[key]
        fstp dword[M+ecx*4]
        jmp loop1
    end1:
    ;Median calculation:
    mov eax, [N]
    and eax, 1
    jz even
    ;N odd
    mov eax, [N]
    dec eax
    ;(N-1)/2
    shr eax, 1
    fld dword[M+eax*4]
    fstp dword[Med]
    jmp finish
    even:
    ;N even
    mov eax, [N]
    mov ebx, eax
    shr eax, 1
    shr ebx, 1
    dec eax
    ;now ebx=N/2 and eax= (N/2)-1
    fld dword[M+eax*4]
    fadd dword[M+ebx*4]
    fdiv dword[two]
    fstp dword[Med]
    finish:
    ;printing
    sub esp, 8
    fld dword[Med]
    fstp qword[esp]
    push format
    call _printf
    add esp, 12
    xor eax, eax
    ret