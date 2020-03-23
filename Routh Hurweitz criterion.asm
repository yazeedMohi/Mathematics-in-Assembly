;By David A. Ricardo
%include "io.inc"
section .bss
    A: resd 10*10*8
section .data
    cof: dq 3.0,9.0,6.0,4.0,7.0,8.0,2.0,6.0
    n: dd ($-cof)/8
    formatA: db 'A = ',0xA,0
    format:db '%0.2f    ',0
    formatln:db '%0.2f    ',0xA,0
    format1: db 'The system is stable!',0
    ;formatMst: db 'The system is marginly-stable and it has %d poles in the jw axis',0
    format2: db 'The system is unstable, it has 0 poles in the jw axis and %d poles in the RHP',0
    temp: dq 0.0
    epsilon: dq 0.00001
section .text
global CMAIN
CMAIN:
    mov ebp, esp
    mov edi, 0
    xor eax, eax
    mov ecx, -2
    loop1:
        add ecx, 2
        cmp ecx, [n]
        jge end1
        mov eax, ecx
        shr eax, 1
        fld qword[cof+ecx*8]
        fstp qword[A+eax*8]
        inc edi
        jmp loop1
    end1:
    add edi, 0
    mov ecx, -1
    loop2:
        add ecx, 2
        cmp ecx, [n]
        jge end2
        mov eax, ecx
        shr eax, 1
        add eax, edi
        fld qword[cof+ecx*8]
        fstp qword[A+eax*8]
        jmp loop2
    end2:
    ;aij=(a(i-2,j+1)*a(i-1,0)-a(i-2,0)*a(i-1,j+1))/a(i-1,0)
    mov ebx, 1;i
    add edi, 0
    loop3:
        inc ebx
        cmp ebx, [n]
        jge end3
        mov ecx, -1;j
        loop4:
            inc ecx
            cmp ecx, edi
            jge loop3
            mov edx, edi
            dec edx
            cmp ecx, edx
            je lst
            mov edx, ebx
            sub edx, 2
            mov eax, edx
            mul edi
            mov edx, ecx
            add edx, 1
            add eax, edx
            fld qword[A+eax*8]
            mov edx, ebx
            sub edx, 1
            mov eax, edx
            mul edi
            mov edx, ecx
            add edx, 0
            add eax, 0
            fmul qword[A+eax*8]
            mov edx, ebx
            sub edx, 2
            mov eax, edx
            mul edi
            mov edx, ecx
            add edx, 0
            add eax, 0
            fld qword[A+eax*8]
            mov edx, ebx
            sub edx, 1
            mov eax, edx
            mul edi
            mov edx, ecx
            add edx, 1
            add eax, edx
            fmul qword[A+eax*8]
            fsubp
            mov edx, ebx
            sub edx, 1
            mov eax, edx
            mul edi
            mov edx, ecx
            add edx, 0
            add eax, 0
            fdiv qword[A+eax*8]
            mov eax, ebx
            mul edi
            add eax, ecx
            fstp qword[A+eax*8]
            jmp loop4
            lst:
            fldz
            mov eax, ebx
            mul edi
            add eax, ecx
            fst qword[A+eax*8]
            fldz
            fcompp
            fnstsw ax
            sahf
            jne loop4
            cmp ecx, 0
            jne loop4
            fld qword[epsilon]
            fstp qword[A+eax*8]
            jmp loop4
    jmp loop3
    end3:
    mov esp, ebp
    mov esi, edi
       push formatA
       call _printf
       add esp, 4
       mov ecx, -1
     loop12:
        inc ecx
        cmp ecx, [n]
        jge end12
        mov edi, -1
        loop11:
            inc edi
            cmp edi, esi
            jge loop12
            pushad
            sub esp, 8
            mov eax, ecx
            mul esi
            add eax, edi
            fld qword[A+eax*8]
            fstp qword[esp]
            mov ebx, esi
            dec ebx
            cmp edi, ebx
            jne t3
            push formatln
            jmp t4
            t3:
            push format
            t4:
            call _printf
            add esp, 12
            popad
            jmp loop11
       end12:
    mov edi, 0
    mov ebx, 0
    mov ecx, -1
    loop44:
        inc ecx
        cmp ecx, [n]
        jge finin
        mov eax, ecx
        mul esi
        fld qword[A+eax*8]
        fst qword[temp]
        fldz
        fcompp
        fnstsw ax
        sahf
        ja nega
        cmp ebx, 1
        jne loop44
        mov ebx, 0
        inc edi
        jmp loop44
        nega:
        cmp ebx, 0
        jne loop44
        mov ebx, 1
        inc edi
        jmp loop44
    finin: 
    cmp edi, 0
    jne un
    push format1
    call printf
    add esp, 4
    ret
    un:
    push edi
    push format2
    call printf
    add esp, 8
    ret