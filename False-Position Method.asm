%include "io.inc"
section .data
    ;initial guesses
    ;Note: AVOID USING THE NEGATIVE VALUE OF THE SAME (OR ALMOST EQUAL) GUESS OF XL IN XU AS IT TENDS TO RESULT IN VERY LARGE NUMBER OF ITERATIONS FOR LARGE VALUES OF XA AND XB!
    ;ALSO AVOID USING ZERO OR NEGATIVE VALUES FOR GUESSES FOR LARGE ORDER FUNCTIONS
    xl: dq 1.0
    xu: dq 3.0
    ;temporal variables for use in the program
    xr: dq 0.0
    xrold: dq 0.0
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
    formaterr3: db "Error: Soulution can't be found with the given initial guesses!!!",0
    format2: db "Number of iterations = %0.0f",0
section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging
    ;calling the function _Bracket using the initial guesses
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
    ;f(xh)
    sub esp, 8
    fld qword[xu]
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
    mov ecx, 0
    mov edx, 1
    fld qword[xl]
    fstp qword[xrold]
    mov ebp, esp
    sub esp, 8
    fld qword[error]
    fstp qword[esp]
    sub esp, 8
    fld qword[xu]
    fstp qword[esp]
    sub esp, 8
    fld qword[xl]
    fstp qword[esp]
    push _fa
    call _falsePosition
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
    push format2
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
global _falsePosition
_falsePosition:
    push ebp
    mov ebp, esp
    finit
    add dword[itNum], 1
    mov ebx, [ebp+8]
    ;calculating xr=xu-(f(xu))/((f(xl)-f(xu))/(xl-xu))
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    fld qword[ebp+20];xu
    sub esp, 8
    fstp qword[esp]
    call ebx
    add esp, 8
    ;
    fld qword[ebp+12];xl
    sub esp, 8
    fstp qword[esp]
    call ebx
    add esp, 8
    ;
    fld qword[ebp+20];xu
    sub esp, 8
    fstp qword[esp]
    call ebx
    add esp, 8
    ;
    fsubp
    ;
    fld qword[ebp+12];xl
    ;
    fsub qword[ebp+20];xu
    ;
    fdivp
    ;if the denumenator value is equal to zero then there is an error and the root cannot be found with the given initial guesses
    fldz
    fcomp
    fnstsw ax
    sahf
    je err3
    ;
    fdivp
    ;
    fsub qword[ebp+20];xu
    ;
    fmul qword[negative]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    fstp qword[xr]
    fld qword[ebp+12];xl
    sub esp, 8
    fstp qword[esp]
    call ebx
    add esp, 8
    sub esp, 8
    fstp qword[esp]
    sub esp, 8
    fld qword[xr]
    fstp qword[esp]
    call ebx
    add esp, 8
    sub esp, 8
    fstp qword[esp]
    fld qword[esp]
    fmul qword[esp+8]
    ;f(xl)*f(xr)
    ;=0 -> found
    ;<0 -> between xl and xr
    ;>0 -> between xr and xu
    fldz
    add esp, 16
    fcompp
    fnstsw ax
    sahf
    je found
    ja xlxr
    jb xrxu
    found:
    finit
    fld qword[xr]
    mov esp, ebp
    pop ebp
    ret
    xlxr:
    finit
    ;comparing (xr-xrold)/xr to the error
    ;though using relative error would give higher accuracy yet more iterations (comparing f(xr) directly to zero)
    fld qword[xr]
    fsub qword[xrold]
    fdiv qword[xr]
    fmul qword[hundred]
    fabs
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
        ;call _falsePosition again with the new arguments
        ;xl=xl xu=xr
        fld qword[xr]
        fstp qword[xrold]
        mov ebp, esp
        sub esp, 8
        fld qword[ebp+28];error
        fstp qword[esp]
        sub esp, 8
        fld qword[xr];xu
        fstp qword[esp]
        sub esp, 8
        fld qword[ebp+12];xl
        fstp qword[esp]
        push ebx
        call _falsePosition
        mov esp, ebp
        pop ebp
        ret
        
        
    xrxu:
    finit
    ;comparing (xr-xrold)/xr to the error
    fld qword[xr]
    fsub qword[xrold]
    fdiv qword[xr]
    fabs
    fmul qword[hundred]
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
        ;call _falsePosition again with the new arguments
        ;xl=xr xu=xu
        fld qword[xr]
        fstp qword[xrold]
        mov ebp, esp
        sub esp, 8
        fld qword[ebp+28];error
        fstp qword[esp]
        sub esp, 8
        fld qword[ebp+20];xu
        fstp qword[esp]
        sub esp, 8
        fld qword[xr];xl
        fstp qword[esp]
        push ebx
        call _falsePosition
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
    mov edx, 0
    add esp, 4
    pop ebp
    ret
 