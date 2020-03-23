%include "io.inc"
section .data
    ;initial guesses
    ;Note: AVOID USING THE NEGATIVE VALUE OF THE SAME (OR ALMOST EQUAL) GUESS OF XA IN XB AS IT TENDS TO RESULT IN VERY LARGE NUMBER OF ITERATIONS FOR LARGE VALUES OF XA AND XB!
    ;ALSO AVOID USING ZERO OR NEGATIVE VALUES FOR GUESSES FOR LARGE ORDER FUNCTIONS
    xa: dq 1.0
    xb: dq 3.0
    ;temporal variables for use in the program
    xnew: dq 0.0
    itNum: dd 0 ;number of iterations
    ;maximum allowed error
    error: dq 0.00001
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
    formaterr2: db "Error: the initial guesses doesn't bracket the root!!!",0
    formaterr3: db "Error: Soulution can't be found with the given initial guesses!!!",0
    format2: db "Number of iterations = %0.0f",0
section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging
    ;write your code here
    mov ecx, 0
    finit
    mov ebp, esp
    sub esp, 8
    fld qword[error]
    fstp qword[esp]
    sub esp, 8
    fld qword[xb]
    fstp qword[esp]
    sub esp, 8
    fld qword[xa]
    fstp qword[esp]
    push _fa
    call _Secant
    mov esp, ebp
    cmp eax, 0
    je dontprint
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
global _Secant
_Secant:
    push ebp
    mov ebp, esp
    finit
    add dword[itNum], 1
    mov ebx, [ebp+8]
    ;calculating xnew using the formula
    ;xnew=(xa*f(xb)-xb*f(xa))/(f(xb)-f(xa))
    ;a
    fld qword[ebp+12];xa
    ;mul fb
    fld qword[ebp+20];xb
    sub esp, 8
    fstp qword[esp]
    call ebx
    add esp, 8
    fmulp
    ;ld b
    fld qword[ebp+20]
    ;mul fa
    fld qword[ebp+12];xa
    sub esp, 8
    fstp qword[esp]
    call ebx
    add esp, 8
    fmulp
    ;subp
    fsubp
    ;ld fb
    fld qword[ebp+20];xb
    sub esp, 8
    fstp qword[esp]
    call ebx
    add esp, 8
    ;sub fa
    fld qword[ebp+12];xa
    sub esp, 8
    fstp qword[esp]
    call ebx
    add esp, 8
    fsubp
    ;div
    ;if the denumenator value is equal to zero then there is an error and the root cannot be found with the given initial guesses
    fldz
    fcomp
    fnstsw ax
    sahf
    je err3
    fdivp
    fstp qword[xnew]
    finit
    fld qword[xnew]
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
    fld qword[xnew]
    mov esp, ebp
    pop ebp
    ret
    cont:
    finit
    ;the error in this case is considered as the value of f(xnew) so that as it gets closer to zero we get closer to the solution
    fld qword[xnew]
    sub esp, 8
    fstp qword[esp]
    call _fa
    add esp, 8
    fabs
    fld qword[esp+28];Error
    fcompp
    fnstsw ax
    sahf
    ja found
        ;if number of iterations exceded the number allowed print an error message
        mov eax, [MaxIts]
        cmp dword[itNum], eax
        jg err
        ;call _Secant again with the new arguments
        ;xa=xb xb=xnew
        finit
        mov ebp, esp
        sub esp, 8
        fld qword[ebp+28];error
        fstp qword[esp]
        sub esp, 8
        fld qword[xnew];xb
        fstp qword[esp]
        sub esp, 8
        fld qword[ebp+20];xa
        fstp qword[esp]
        push ebx
        call _Secant
        mov esp, ebp
        pop ebp
        ret
    err3:
    push formaterr3
    call _printf
    mov eax, 0
    add esp, 4
    pop ebp
    ret
    err:
    push formaterr
    call _printf
    mov eax, 0
    add esp, 4
    pop ebp
    ret
 