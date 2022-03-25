assume cs:code
code segment
    start:
        mov ax, cs
        mov ds, ax
        mov si, offset do0  ; 设置 ds:si 指向源地址

        mov ax, 0
        mov es, ax
        mov di, 200h        ; 设置 es:di 指向目的地址 将数据写入到 0:200

        mov cx, offset do0end - offset do0  ; 设置 do0 中断0程序长度
        cld                 ; ++传输
        rep movsb

        ; 设置中断向量表
        mov ax, 0
        mov es, ax
        mov word ptr es:[0*4], 200h  ; 中断程序地址->0:200
        mov word ptr es:[0*4 + 2], 0

        ; 故意除法溢出
        mov ax, 4000h
        mov bh, 1
        div bh

        mov ax, 4c00h
        int 21h
    do0:
        jmp short do0start
        db 'divide error!'

    do0start:
        mov ax, cs
        mov ds, ax
        mov si, 202h   ; ds:si 0:202 -> string

        mov ax, 0b800h
        mov es, ax
        mov di, 12*160+33*2

        mov cx, 13
        s:
            mov al, [si]
            mov es:[di], al
            inc si
            add di, 2
        loop s

        mov ax, 4c00h
        int 21h


    do0end: nop

code ends
end start