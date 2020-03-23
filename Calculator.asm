%include "io.inc"
section .data
    nums: db '0123456789',0
    ops: db '+-*/^',0
    exp: db '12+54',0,0,0,0,0,0,0,0,0,0
    n: dd ($-exp)
    num1: dd 0
    num2: dd 0
    op: db 0
    format: db 'ans = %d'
    ten: dd 10
    screen:db '000000',0
    result:db '000000',0
section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging
    ;write your code here
    mov ebx, exp
    xor eax, eax
    mov ecx,-1
    loop11:
        inc ecx
        cmp ecx, 20
        jge end11
        mov al, [exp+ecx]
        cmp al, 0
        je end11
        jmp loop11
    end11:
    mov dword[n], ecx
    mov ecx,-1
    loop21:
        inc ecx
        cmp ecx, [n]
        jge end21
        mov bl, [exp+ecx]
        
        mov esi, -1
        loop31:
            inc esi
            cmp esi, 10
            jge end31
            cmp bl, [nums+esi]
            jne loop31
            sub bl, 0x30
            cmp edx, 0
            jne nn
            mov eax, [num1]
            mul dword[ten]
            movzx ebx, bl
            add eax, ebx
            mov [num1], eax
            jmp loop21
            nn:
            push edx
            mov eax, [num2]
            mul dword[ten]
            pop edx
            movzx ebx, bl
            add eax, ebx
            mov [num2], eax
            jmp loop21
        end31:
        mov esi, -1
        loop41:
            inc esi
            cmp esi, 5
            jge loop21
            cmp bl, [ops+esi]
            jne loop41
            mov al, byte[ops+esi]
            mov byte[op], al
            mov edx, 1
            jmp loop21
    end21:
    cmp byte[op], '+'
    jne c1
    mov eax, dword[num1]
    add eax, dword[num2]
    jmp cc
    c1:
    cmp byte[op], '-'
    jne c2
    mov eax, dword[num1]
    sub eax, dword[num2]
    jmp cc
    c2:
    cmp byte[op], '*'
    jne c3
    mov eax, dword[num1]
    mul dword[num2]
    jmp cc
    c3:
    cmp byte[op], '/'
    jne c4
    mov eax, dword[num1]
    cdq
    div dword[num2]
    jmp cc
    c4:
    cmp byte[op], '^'
    jne err
    mov ecx, -1
    mov ebx, dword[num1]
    mov eax, 1
    loopPow:
        inc ecx
        cmp ecx, dword[num2]
        jge cc
        mul ebx
        jmp loopPow 
    jmp cc
    err:
        nop
   cc:
        
        push eax
        push format
        call _printf
        add esp, 8
    ret