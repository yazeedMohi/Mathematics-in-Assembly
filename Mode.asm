%include "io.inc"
section .data
    ;input data:
    M: dq 2.0,5.0,3.0,1.0,3.0,3.0,6.0,2.0,7.0,2.0,2.0,2.0,3.0,15.0,15.0,15.0,15.0,15.0,15.0,15.0,15.0,16.0,-16.0,-16.0,-16.0,-16.0,-16.0,-16.0,-16.0,-16.0,-16.0,-16.0
    N: dd ($-M)/8
    ;temporal variables:
    Mode: dq 0.0
    ;printing formats:
    format: db "Mode = %f",0xA,0
    format2: db "Number of Occurance times = %0.0f",0
section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging
    ;going through each element and comparing it to all the others while keeping the number of its occurance
    mov esi, -1;i
    mov edi, 0;index of element with maximum occurance
    mov edx, 0;maximum occurance
    mov ecx, -1;j
    loop1:
        inc ecx
        cmp ecx, [N]
        jge end1
        fld qword[M+ecx*8]
        mov ebx, -1
        mov edx, 0
        loop2:
            inc ebx
            cmp ebx, [N]
            jge end2
            fld qword[M+ebx*8]
            fcomp
            fnstsw ax 
            sahf
            jne loop2
            inc edx
            jmp loop2
       end2:
       cmp edx, edi
       jle loop1
       mov esi, ecx
       mov edi, edx
       jmp loop1
    end1:
    ;printing
    fld qword[M+esi*8]
    fstp qword[Mode]
    pushad
    sub esp, 8
    fld qword[Mode]
    fstp qword[esp]
    push format
    call _printf
    add esp, 12
    popad
    sub esp, 4
    mov [esp], edx
    fild dword[esp]
    sub esp, 4
    fstp qword[esp]
    push format2
    call _printf
    add esp, 12
    xor eax, eax
    ret