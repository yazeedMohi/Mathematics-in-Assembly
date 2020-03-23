%include "io.inc"
section .data
    ;initial guess
    xi: dq 1.0
    ;temporal variables for use in the program
    xinew: dq 0.0
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
    epsilon: dq 0.0001
    ;printing formats
    format: db "Root = %f",0xA,0
    formaterr: db "Error: Number of iterations exceded the specified maximum number allowed!!!",0
    format2: db "Number of iterations = %0.0f",0
    errorr : dq 0.0
section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging
    mov ecx, 0
    finit
    mov edx, 1
    fld qword[xi]
    fstp qword[xinew]
    mov ebp, esp
    sub esp, 8
    fld qword[error]
    fstp qword[esp]
    sub esp, 8
    fld qword[xi]
    fstp qword[esp]
    push _fa
    call _NewRaph
    mov esp, ebp
    ;if edx=0 then an error regarding the number of iterations occured
    cmp edx, 0
    je dontprint
    ;printing the root value and the number of iterations
    sub esp, 8
    fstp qword[esp]
    push format
    call _printf
    mov esp, ebp
    fild dword[itNum]
    sub esp, 8
    fstp qword[esp]
    push format2
    call _printf
    fstp qword[esp]
    dontprint:
    mov esp, ebp
    xor eax, eax
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
global _NewRaph
_NewRaph:
    push ebp
    mov ebp, esp
    finit
    add dword[itNum], 1
    mov ebx, [ebp+8]
    fld qword[ebp+12];xi
    sub esp, 8
    fstp qword[esp]
    call ebx
    add esp, 8
    ;calculating the derivative of _fa
    ;f'(xi)=(f(xi)+f(xi+epsilon))/(epsilon)
    ;f(xi)
    fld qword[ebp+12];xl
    sub esp, 8
    fstp qword[esp]
    call ebx
    add esp, 8
    ;sub f(xi+eps)
    fld qword[ebp+12];xl
    fadd qword[epsilon]
    sub esp, 8
    fstp qword[esp]
    call ebx
    add esp, 8
    fsubp
    ;load xi
    fld qword[epsilon]
    fmul qword[negative]
    fdivp
    ;fdiv
    fdivp
    ;fsub xi
    fsub qword[ebp+12]
    ;f negate
    fmul qword[negative]
    ;store xinew
    fstp qword[xinew]
    finit
    fld qword[xinew]
    sub esp, 8
    fstp qword[esp]
    call ebx
    add esp, 8
    fldz
    fcompp
    fnstsw ax
    sahf
    jne cont
    found:
    finit
    fld qword[xinew]
    mov esp, ebp
    pop ebp
    ret
    cont:
    finit
    ;comparing (xinew-xiold)/xinew to the maximum allowed error
    fld qword[xinew]
    fsub qword[ebp+12]
    fdiv qword[ebp+12]
    fabs
    fmul qword[hundred];to make it a percentage
    fld qword[esp+28];Error
    fcompp
    fnstsw ax
    sahf
    ja found
        ;if number of iterations exceded the number allowed print an error message
        mov eax, [MaxIts]
        cmp dword[itNum], eax
        jg err
        ;call _NewRaph again with the new arguments
        ;xi=xinew
        finit
        mov ebp, esp
        sub esp, 8
        fld qword[ebp+20];error
        fstp qword[esp]
        sub esp, 8
        fld qword[xinew];xh
        fstp qword[esp]
        push ebx
        call _NewRaph
        mov esp, ebp
        pop ebp
        ret
    err:
    push formaterr
    call _printf
    mov edx, 0
    add esp, 4
    pop ebp
    ret
 