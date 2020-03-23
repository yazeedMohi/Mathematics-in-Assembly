%include "io.inc"
section .data
    m: dq 0.0
    b: dq 0.0
    n: dd 6
    x: dq 0.5,1.0,2.0,3.0,4.0,5.0
    y: dq -8.0,-4.0,0.0,4.0,8.0,12.0
    format: db '%0.16f',0xa,0
section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging
    ;write your code here
    xor eax, eax
    mov eax, n
    push n
    push y
    push x
    call _LinReg
    add esp, 12
    sub esp , 8
    fld qword[m]
    fstp qword[esp]
    push format
    call _printf
    add esp, 12
    sub esp , 8
    fld qword[b]
    fstp qword[esp]
    push format
    call _printf
    add esp, 12
    ret
global _LinReg
_LinReg:
    push ebp
    mov ebp, esp
    mov edx, [ebp+16];n
    mov ebx, [edx]
    mov edi, [ebp+12];y
    mov esi, [ebp+8];x
    ;m:
    fild dword[edx]
    ;sum
    fldz
    mov ecx, -1
        loop1:
        inc ecx
        cmp ecx, ebx
        jge end1
        fld qword[esi+ecx*8]
        fmul qword[edi+ecx*8]
         
        faddp
         
        jmp loop1
    end1:
     
    fmulp
     
    mov ecx, -1
    fldz
    loop2:
        inc ecx
        cmp ecx, ebx
        jge end2
        fadd qword[esi+ecx*8]
        jmp loop2
    end2:
    mov ecx, -1
    fldz
    loop3:
        inc ecx
        cmp ecx, ebx
        jge end3
        fadd qword[edi+ecx*8]
        jmp loop3
    end3:
    fmulp
     
    fsubp
     
    fild dword[edx]
    fldz
    mov ecx, -1
    loop4:
        inc ecx
        cmp ecx, ebx
        jge end4
        fld qword[esi+ecx*8]
        fmul qword[esi+ecx*8]
        faddp
        jmp loop4
    end4:
    fmulp
     
    fldz
    mov ecx, -1
    loop5:
        inc ecx
        cmp ecx, ebx
        jge end5
        fadd qword[esi+ecx*8]
        jmp loop5
    end5:
    fmul st0;;;;;;;;;;;;;
     
    fsubp
     
    fdivp
     
    fst qword[m]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    fldz
    mov ecx, -1
        loop6:
        inc ecx
        cmp ecx, ebx
        jge end6
        fld qword[esi+ecx*8]
        fmul qword[esi+ecx*8]
        faddp
        jmp loop6
    end6:
    mov ecx, -1
    fldz
    loop7:
        inc ecx
        cmp ecx, ebx
        jge end7
        fadd qword[edi+ecx*8]
        jmp loop7
    end7:
    fmulp
    mov ecx, -1
    fldz
    loop8:
        inc ecx
        cmp ecx, ebx
        jge end8
        fadd qword[esi+ecx*8]
        jmp loop8
    end8:
    mov ecx, -1
    fldz
    loop11:
        inc ecx
        cmp ecx, ebx
        jge end11
        fld qword[esi+ecx*8]
        fmul qword[edi+ecx*8]
        faddp
        jmp loop11
    end11:
    fmulp
    fsubp
    
    fild dword[edx]
    fldz
    mov ecx, -1
    loop9:
        inc ecx
        cmp ecx, ebx
        jge end9
        fld qword[esi+ecx*8]
        fmul qword[esi+ecx*8]
        faddp
        jmp loop9
    end9:
    fmulp
     
    fldz
    mov ecx, -1
    loop10:
        inc ecx
        cmp ecx, ebx
        jge end10
        fadd qword[esi+ecx*8]
        jmp loop10
    end10:
    fmul st0;;;;;;;;;;;;;
     
    fsubp
     
    fdivp
     
    fst qword[b]
    mov esp, ebp
    pop ebp
    ret
    mov esp, ebp
    pop ebp
    ret