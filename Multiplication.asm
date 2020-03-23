%include "io.inc"
section .bss
    ;the number multiplied by 8 must be the total number of elements in the resulting matrix (=M*P)
    ;the result matrix
    MatC: resd 16*8
section .data
    ;input matrices
    MatA: dq 1.0,1.0,1.0,1.0,2.0,2.0,2.0,2.0,3.0,3.0,3.0,3.0
    MatB: dq 1.0,1.0,1.0,2.0,2.0,2.0,3.0,3.0,3.0,4.0,4.0,4.0
    ;dimensions of input matrices A=M*N B=N*p
    N: dd 4
    M: dd 3
    P: dd 3
    ;printing formats
    format:db '%f  ',0
    formatln:db '%f  ',0xA,0
    formatC:db "MatC :",0xA,0
section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging
    xor eax, eax
    mov ecx, -1;i
    mov edi, -1;j
    mov ebx, -1;k
    ;calculating each element in c using the formula:
    ;c[i][j]=E a[i][k]*b[k][j] for i 0->M-1, j 0->P-1, k 0->N-1
    ;for i=0->M-1
    loop1:
        inc ecx
        cmp ecx, [M]
        jge end1
        mov edi, -1
        ;for j=0->P-1
        loop2:
            inc edi
            cmp edi, [P]
            jge loop1
            mov ebx, -1
            finit
            fldz
            ;for k=0->N-1
            loop3:
                inc ebx
                cmp ebx, [N]
                jge end3
                mov eax, ecx
                mul dword[N]
                add eax, ebx
                fld qword[MatA+eax*8]
                mov eax, ebx
                mul dword[P]
                add eax, edi
                fmul qword[MatB+eax*8]
                faddp
                jmp loop3
            end3:
            mov eax, ecx
            mul dword[M]
            add eax, edi
            fstp qword[MatC+eax*8]
            jmp loop2
    end1:
    ;printing the result matrix row by row
    push formatC
    call _printf
    add esp, 4
    mov ecx, -1;i
    mov edi, -1;j
        loop5:
        inc ecx
        cmp ecx, [M]
        jge end5
        mov edi, -1
            loop4:
            inc edi
            cmp edi, [P]
            jge loop5
            pushad
            sub esp, 8
            mov eax, ecx
            mul dword[M]
            add eax, edi
            fld qword[MatC+eax*8]
            fstp qword[esp]
            mov ebx, [P]
            dec ebx
            cmp edi, ebx;if the last element in the row then print it and go to the next line
            jne t1
            push formatln
            jmp t2
            t1:
            push format
            t2:
            call _printf
            add esp, 12
            popad
            jmp loop4
       end5: 
    ret