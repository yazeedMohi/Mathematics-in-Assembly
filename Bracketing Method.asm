%include "io.inc"
section .data
    ;initial guesses (must bracket the solution!)
    xl: dq -5.0
    xh: dq 5.0
    ;temporal variables for use in the program
    xm: dq 0.0
    xmold: dq 0.0
    itNum: dd 0 ;number of iterations
    ;maximum allowed error
    error: dq 0.0001
    ;maximum allowed number of iterations
    MaxIts: dd 1000
    ;constants for use with FPU calculations
    one: dq 1.0
    negative: dq -1.0
    two: dq 2.0
    three: dq 3.0
    four: dq 4.0
    ten: dq 10.0
    hundred: dq 100.0
    ;printing formats
    format: db "Root = %f",0xA,0
    formaterr: db "Error: Number of iterations exceded the specified maximum number allowed!!!",0
    formaterr2: db "Error: the initial guesses doesn't bracket the root!!!",0
    formatIts: db "Number of iterations = %0.0f",0
section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging
    finit
    ;checking the initial guesses validity
    fld qword[xl]
    ;f(xl)
    sub esp, 8
    fstp qword[esp]
    call _fa
    add esp, 8
    sub esp, 8
    fstp qword[esp]
    ;f(xu)
    sub esp, 8
    fld qword[xh]
    fstp qword[esp]
    call _fa
    add esp, 8
    sub esp, 8
    fstp qword[esp]
    fld qword[esp]
    fmul qword[esp+8]
    ;f(xl)*f(xh)
    ;=0 -> found
    ;<0 -> the gusses are ok
    ;>0 -> invalid gusses
    fldz
    add esp, 16
    fcompp
    fnstsw ax
    sahf
    je found2
    ja ok
    jb err2
    found2:
    fld qword[xl]
    jmp printing
    ok:
    ;calling the function _Bracket using the initial guesses
    mov edx, 1
    fld qword[xl]
    fstp qword[xmold]
    mov ebp, esp
    sub esp, 8
    fld qword[error]
    fstp qword[esp]
    sub esp, 8
    fld qword[xh]
    fstp qword[esp]
    sub esp, 8
    fld qword[xl]
    fstp qword[esp]
    push _fa
    call _Bracket
    mov esp, ebp
    ;if edx=0 then an error regarding the number of iterations occured
    cmp edx, 0
    je dontprint
    ;printing the root value and the number of iterations
    printing:
    sub esp, 8
    fstp qword[esp]
    push format
    call _printf
    mov esp, ebp
    fild dword[itNum]
    sub esp, 8
    fstp qword[esp]
    push formatIts
    call _printf
    fstp qword[esp]
    dontprint:
    mov esp, ebp
    xor eax, eax
    ret
    err2:
    push formaterr2
    call _printf
    add esp, 4
    ret
;defining the f(x) function
global _fa
_fa:
    push ebp
    mov ebp, esp
    fld qword[ten]
    fmul qword[negative]
    fld qword[ebp+8]
    fmul qword[ebp+8]
    fmul qword[ebp+8]
    fmul qword[ebp+8]
    fmul qword[ebp+8]
    fmul qword[ebp+8]
    fmul qword[ebp+8]
    faddp
    ;now f(x)=(x^7)-10
    mov esp, ebp
    pop ebp
    ret
global _Bracket
_Bracket:
    push ebp
    mov ebp, esp
    finit
    add dword[itNum], 1
    mov ebx, [ebp+8];_fa
    ;calculating  xm=(xl+xh)/2
    fld qword[ebp+12];xl
    fadd qword[ebp+20];xh
    fdiv qword[two]
    fstp qword[xm]
    fld qword[ebp+12];xl
    ;f(xl)
    sub esp, 8
    fstp qword[esp]
    call ebx
    add esp, 8
    sub esp, 8
    fstp qword[esp]
    ;f(xm)
    sub esp, 8
    fld qword[xm]
    fstp qword[esp]
    call ebx
    add esp, 8
    sub esp, 8
    fstp qword[esp]
    fld qword[esp]
    fmul qword[esp+8]
    ;f(xl)*f(xm)
    ;=0 -> found
    ;<0 -> between xl and xm
    ;>0 -> between xm and xh
    fldz
    add esp, 16
    fcompp
    fnstsw ax
    sahf
    je found
    ja xlxm
    jb xmxh
    found:
    finit
    fld qword[xm]
    mov esp, ebp
    pop ebp
    ret
    
    xlxm:
    finit
    ;comparing (xm-xmold)/xm to the maximum allowed error
    fld qword[xm]
    fsub qword[xmold]
    fdiv qword[xm]
    fabs
    fmul qword[hundred];to make it a percentage
    fld qword[esp+28];Error
    fcompp
    fnstsw ax
    sahf
    ja found
        finit
        ;if number of iterations exceded the number allowed print an error message
        mov eax, [MaxIts]
        cmp dword[itNum], eax
        jg err
        ;call _Bracket again with the new arguments
        ;xl=xl xh=xm
        fld qword[xm]
        fstp qword[xmold]
        mov ebp, esp
        sub esp, 8
        fld qword[ebp+28];error
        fstp qword[esp]
        sub esp, 8
        fld qword[xm];xh
        fstp qword[esp]
        sub esp, 8
        fld qword[ebp+12];xl
        fstp qword[esp]
        push ebx
        call _Bracket
        mov esp, ebp
        pop ebp
        ret
        
        
    xmxh:
    finit
    ;comparing (xm-xmold)/xm to the error
    fld qword[xm]
    fsub qword[xmold]
    fdiv qword[xm]
    fabs
    fmul qword[hundred];to make it a percentage
    fld qword[esp+28];Error
    fcompp
    fnstsw ax
    sahf
    ja found
        finit
        ;if number of iterations exceded the number allowed print an error message
        mov eax, [MaxIts]
        cmp dword[itNum], eax
        jg err
        ;call _Bracket again with the new arguments
        ;xl=xm xh=xh
        fld qword[xm]
        fstp qword[xmold]
        mov ebp, esp
        sub esp, 8
        fld qword[ebp+28];error
        fstp qword[esp]
        sub esp, 8
        fld qword[ebp+20];xh
        fstp qword[esp]
        sub esp, 8
        fld qword[xm];xl
        fstp qword[esp]
        push ebx
        call _Bracket
        mov esp, ebp
        pop ebp
        ret
    err:
    ;error message printing
    push formaterr
    call _printf
    mov edx, 0
    add esp, 4
    pop ebp
    ret
 