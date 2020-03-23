%include "io.inc"
section .bss
    ;the number multiplied by 8 must be the total number of elements in the resulting matrix (=M*P)
    ;the result matrix
    In_MatA: resd 25*8
    ;temporal matrices
    MatAL: resd 25*8
    MatU: resd 25*8
    MatF: resd 25*8
    MatB: resd 25*8
section .data
    ;input matrix
    MatA: dq 1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,13.0,22.0,17.0,55.0,42.0,93.0,77.0,50.0,99.0,100.0,33.0,21.0,88.0,75.0,10.0,1.0
    ;input matrix dimensions
    M: dd 5
    N: dd 5
    ;constants for use with FPU calculations
    negative:dq -1.0
    one:dq 1.0
    ;temporary variable to be used in the program
    determinant: dq 0.0
    temp: dq 0.0
    d: dq 1.0
    m: dd 0
    n: dd 0
    i: dd 0
    ;printing formats
    format:db '%f  ',0
    formatln:db '%f  ',0xA,0
    formatInv: db "The inverse of Matrix A is : ",0xA,0
    formaterr: db "Error: The inverse cannot be found since the matrix determinant is zero!!!",0
section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging
    xor eax, eax
    finit
    ;First calculating the determinant of the matrix
    sub esp, 4
    mov eax, dword[N]
    mov dword[esp], eax
    sub esp, 4
    mov dword[esp], MatA
    call _det
    mov esp, ebp
    fst qword[determinant]
    ;but if the determinant is zero the inverse cannot be found (at least by this method)
    fldz
    fcompp
    fnstsw ax
    sahf
    je err
    ;Then applying the algorithm of cofactrization which is described in each step
    mov ecx, -1;i
    mov edi, -1;j
    mov ebx, -1;q
    mov esi, -1;p
    mov dword[m], 0;m
    mov dword[n], 0;n
        ;for q=0->N-1
        loopq:
        inc ebx
        cmp ebx, [N]
        jge endq
        mov esi, -1
            ;for p=0->N-1
            loopp:
            inc esi
            cmp esi, [N]
            jge loopq
            mov dword[m], 0
            mov dword[n], 0
            mov ecx, -1
                loopi:
                ;for i=0->N-1
                inc ecx
                cmp ecx, [N]
                jge endi
                mov edi, -1
                    loopj:
                    ;for j=0->N-1
                    inc edi
                    cmp edi, [N]
                    jge loopi
                    ;if i=q or j=p skip element
                    cmp ecx, ebx;q
                    je loopj
                    cmp edi, esi;p
                    je loopj
                    ;else take element into the B matrix that contains a version of A where the row q and the coloumn p are discarded
                    mov eax, ecx
                    mul dword[N]
                    add eax, edi
                    fld qword[MatA+eax*8]
                    mov eax, dword[m]
                    mul dword[N]
                    add eax, dword[n]
                    fstp qword[MatB+eax*8]
                    ;if n<N-2 continue with the same row in B 
                    mov eax, [N]
                    sub eax, 2
                    cmp dword[n], eax
                    jg less
                    ;else go to the next row in both A and B
                    inc dword[n]
                    jmp loopj
                    less:
                    mov dword[n], 0
                    inc dword[m]
                    jmp loopj
                    endi:
                    ;Now calculating the item in F Using the formula:
                    ;F(q,p)=(-1^(p+q))*det(B)
                    mov eax, esi
                    add eax, ebx
                    mov dword[i], -1
                    ;calculating the (-1^(p+q)) term
                    fld qword[one]
                        loopPower:
                        inc dword[i]
                        cmp dword[i], eax
                        jge endpow
                        fmul qword[negative]
                        jmp loopPower
                    endpow:
                    ;storing that value in a temproral variable
                    fstp qword[temp]
                    ;now calculating the det(B) term
                    sub esp, 4
                    mov eax, dword[N]
                    dec eax
                    mov dword[esp], eax
                    sub esp, 4
                    mov dword[esp], MatB
                    call _det
                    mov esp, ebp
                    ;and now multiplying them
                    fmul qword[temp]
                    ;now storing that value in F(q,p)
                    mov eax, ebx
                    mul dword[N]
                    add eax, esi
                    fstp qword[MatF+eax*8]
                    jmp loopp
        endq:
        ;After filling the matrix F calculating the elements in the matrix In_A using the formula:
        ;In_A(i,j)=F(j,i)/det(A)
        mov ecx, -1
        mov edi, -1
        looptr:
             inc ecx
             cmp ecx, dword[N]
             jge endtr
             mov edi, -1
                looptr2:
                inc edi
                cmp edi, dword[N]
                jge looptr
                mov eax, ecx
                mul dword[N]
                add eax, edi
                mov ebx, eax
                fld qword[MatF+ebx*8]
                fdiv qword[determinant]
                mov eax, edi
                mul dword[N]
                add eax, ecx
                mov ebx, eax
                fldz
                fcomp
                fnstsw ax 
                sahf
                jne notzero
                finit
                fldz
                notzero:
                fstp qword[In_MatA+ebx*8]
                jmp looptr2
       endtr:
       ;Finally printing the In_A matrix
       mov esp, ebp
       push formatInv
       call _printf
       add esp, 4
       mov ecx, -1
     loop12:
        inc ecx
        cmp ecx, [M]
        jge end12
        mov edi, -1
        loop11:
            inc edi
            cmp edi, [N]
            jge loop12
            pushad
            sub esp, 8
            mov eax, ecx
            mul dword[M]
            add eax, edi
            fld qword[In_MatA+eax*8]
            fstp qword[esp]
            mov ebx, [N]
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
    jmp ending
    err:
    push formaterr
    call _printf
    add esp, 4
    ending:    
    mov esp, ebp
    xor eax, eax
    ret
;the determinant calculation function as from the previous question
global _det
_det:
    push ebp
    mov ebp, esp
    xor eax, eax
    ;pushing the general purpose registers to retain their values after returning from the determinant calculation function
    pushad
    ;[ebp+12] contains the matrix dimension
    ;[ebp+8] contains the matrix address
    mov ecx, -1
        loopi2:
        inc ecx
        cmp ecx, [ebp+12]
        jge endi2
         mov edi, -1
             loopj2:
             inc edi
             cmp edi, [ebp+12]
             jge loopi2
             fldz
             mov eax, ecx
             mul dword[ebp+12]
             add eax, edi
             fst qword[MatU+eax*8]
             fstp qword[MatAL+eax*8]
             jmp loopj2
    endi2:
    mov ecx, -1;i
    mov edi, -1;j
    mov ebx, -1;k
    loop1:
        inc ecx
        cmp ecx, [ebp+12]
        jge loop2
        ;the value of [ebp+8] is copied to edx everytime becasue if it stays in edx it will be altered whenever a mul instruction is used
        mov edx, dword[ebp+8]
        fld qword[edx+ecx*8]
        fst qword[MatU+ecx*8]
        jmp loop1
    loop2:
        inc edi
        cmp edi, [ebp+12]
        jge end1
        mov eax, edi
        mul dword[ebp+12]
        mov edx, dword[ebp+8]
        fld qword[edx+eax*8]
        fdiv qword[MatU]
        fstp qword[MatAL+eax*8]
        add eax, edi
        fld qword[one]
        fstp qword[MatAL+eax*8]
        jmp loop2
    end1:
    mov ecx, 0;i
    mov edi, 0;j
    mov ebx, 0;k
    mov esi, -1;m
        loop3:
        inc ebx
        cmp ebx, [ebp+12];;;;;;
        jge finish
        mov ecx, -1;i
        mov edi, ebx;j
        dec edi
        finit
            loop4:
            inc edi
            cmp edi, [ebp+12]
            jge end4
            mov eax, ebx
            mul dword[ebp+12]
            add eax, edi
            mov edx, dword[ebp+8]
            fld qword[edx+eax*8]
            fldz
            mov esi, -1
            loop5:
                inc esi
                cmp esi, ebx
                jge end5
                mov eax, ebx
                mul dword[ebp+12]
                add eax, esi
                fld qword[MatAL+eax*8]
                mov eax, esi
                mul dword[ebp+12]
                add eax, edi
                fmul qword[MatU+eax*8]
                faddp
                jmp loop5
            end5:
            fsubp
            mov eax, ebx
            mul dword[ebp+12]
            add eax, edi
            fstp qword[MatU+eax*8]
            jmp loop4
        end4:
        mov ecx, [ebp+12];i
        mov esi, -1;j
        finit
        loop6:
        dec ecx
        cmp ecx, ebx
        jle loop3
        mov eax, ecx
        mul dword[ebp+12] 
        add eax, ebx
        mov edx, dword[ebp+8]
        fld qword[edx+eax*8]
        mov esi, -1
        fldz
            loop7:
            inc esi
            cmp esi, ebx
            jge end7
            mov eax, ecx
            mul dword[ebp+12]
            add eax, esi
            fld qword[MatAL+eax*8]
            mov eax, esi
            mul dword[ebp+12]
            add eax, ebx
            fmul qword[MatU+eax*8]
            faddp
            jmp loop7
        end7:
        fsubp
        mov eax, ebx
        mul dword[ebp+12]
        add eax, ebx
        fdiv qword[MatU+eax*8]
        mov eax, ecx
        mul dword[ebp+12]
        add eax, ebx
        fstp qword[MatAL+eax*8]
        jmp loop6
    finish:
    mov ebx, -1
    fld qword[one]
        loop8:
        inc ebx
        cmp ebx, [ebp+12]
        jge end
        mov eax, ebx
        mul dword[ebp+12]
        add eax, ebx
        mov ecx, eax
        fld qword[MatU+ecx*8]
        fldz
        fcomp
        fnstsw ax 
        sahf
        je zero
        fmulp
        jmp loop8
        zero:
        finit
        fldz
    end:
    sub esp, 8
    fstp qword[esp]
    finit
    fld qword[esp]
    add esp, 8
    popad
    pop ebp
    ret