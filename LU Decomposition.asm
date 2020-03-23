%include "io.inc"
section .bss
    ;the number multiplied by 8 must be the total number of elements in the resulting matrix (=M*P)
    ;the result matrices
    MatU: resd 25*8
    MatAL: resd 25*8
section .data
    ;input matrix
    MatA: dq 1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,13.0,22.0,17.0,55.0,42.0,93.0,77.0,50.0,99.0,100.0,33.0,21.0,88.0,75.0,10.0,1.0
    ;input matrix dimensions
    M: dd 5
    N: dd 5
    ;constants for use with FPU calculations
    negative:dq -1.0
    one:dq 1.0
    ;printing formats
    format:db '%f  ',0
    formatln:db '%f  ',0xA,0
    formatL:db 'L matrix:',0xA,0
    formatU:db 'U matrix:',0xA,0
section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging
    ;NOTE : THIS PROGRAM WORKS ONLY FOR SQUARE MATRICES
    xor eax, eax
    mov ecx, -1;i
    mov edi, -1;j
    mov ebx, -1;k
    ;fill U first row U(0,j)=A(0,j) for j = 0->N-1
    loop1:
        inc ecx
        cmp ecx, [N]
        jge loop2
        fld qword[MatA+ecx*8]
        fst qword[MatU+ecx*8]
        jmp loop1
    ;fill L first coloumn A(i,0)/U(0,0)
    loop2:
        inc edi
        cmp edi, [M]
        jge end1
        mov eax, edi
        mul dword[N]
        fld qword[MatA+eax*8]
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
     ;increament k
     inc ebx
     cmp ebx, [N]
     jge finish
     ;fill row in U
     ;Ukj=Akj-Lkm*Umj for m from 1 to k-1, j>k
     mov ecx, -1;i
     mov edi, ebx;j
     dec edi
     finit
     loop4:
        inc edi
        cmp edi, [N]
        jge end4
        mov eax, ebx
        mul dword[N] 
        add eax, edi
        fld qword[MatA+eax*8]
        fldz
        mov esi, -1
        loop5:
            inc esi
            cmp esi, ebx
            jge end5
            mov eax, ebx
            mul dword[N]
            add eax, esi
            fld qword[MatAL+eax*8]
            mov eax, esi
            mul dword[N]
            add eax, edi
            fmul qword[MatU+eax*8]
            faddp
            jmp loop5
        end5:
        fsubp
        mov eax, ebx
        mul dword[N]
        add eax, edi
        fstp qword[MatU+eax*8]
        jmp loop4
     end4:
     ;fill coulomn in L
     ;Lik=(Aik-limUmk)/Ukk for m from 1 to k-1, i>=k
     mov ecx, [M];i
     mov esi, -1;j
     finit
     loop6:
        dec ecx
        cmp ecx, ebx
        jle loop3
        mov eax, ecx
        mul dword[N] 
        add eax, ebx
        fld qword[MatA+eax*8]
        mov esi, -1
        fldz
        loop7:
            inc esi
            cmp esi, ebx
            jge end7
            mov eax, ecx
            mul dword[N]
            add eax, esi
            fld qword[MatAL+eax*8]
            mov eax, esi
            mul dword[N]
            add eax, ebx
            fmul qword[MatU+eax*8]
            faddp
            jmp loop7
        end7:
        fsubp
        mov eax, ebx
        mul dword[N]
        add eax, ebx
        fdiv qword[MatU+eax*8]
        mov eax, ecx
        mul dword[N]
        add eax, ebx
        fstp qword[MatAL+eax*8]
        jmp loop6  
    finish:      
    ;printing the U matrix
    push formatU
    call _printf
    add esp, 4
    mov ecx, -1
    loop9:
       inc ecx
       cmp ecx, [N]
       jge end9
       mov edi, -1
       loop10:
           inc edi
           cmp edi, [N]
           jge loop9
           pushad
           sub esp, 8
           mov eax, ecx
           mul dword[N]
           add eax, edi
           fld qword[MatU+eax*8]
           fstp qword[esp]
           mov ebx, [N]
           dec ebx
           cmp edi, ebx
           jne t1
           push formatln
           jmp t2
           t1:
           push format
           t2:
           call _printf
           add esp, 12
           popad
           jmp loop10
    end9:
    ;printing the L matrix
    push formatL
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
           fld qword[MatAL+eax*8]
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
    ret