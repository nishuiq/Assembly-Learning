assume cs:codesg
datasg segment
    db "Beginner's All-purpose Symbolic Instruction Code.", 0
datasg ends

codesg segment
begin:
    mov ax, datasg
    mov ds, ax
    mov si, 0
    call letterc

    mov ax, 4c00h
    int 21h

letterc:
    ; 将[a-z]字符转换为大写字符
    ; ds:si 字符串首地址，结尾为0

    mov al, ds:[si]
    cmp al, 0
    je letterc_end     ; al=0 结尾
    cmp al, 'a'
    jb other           ; al < 'a'
    cmp al, 'z'
    ja other           ; al > 'z'
    and al, 11011111b  ; ASCII第5位0为大写，1为小写

other:
    mov ds:[si], al
    inc si
    jmp letterc

letterc_end:
    ret

codesg ends
end begin