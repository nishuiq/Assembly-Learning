





show_str:
    ; 说明: 打印字符串 尾部为0终止 不判断超出4000字符情况，即不会滚屏操作
    ; (dh)=0~24行 (dl)=0~79列 (cl)=颜色 (ds:si)=字符串首地址
    ; es:di显存段
    push ax
    push es
    push di
    push si

    ; 设置显存段偏移指针 di=dl*2
    mov ax, 0
    mov al, dl
    add ax, ax
    mov di, ax  ; di=dl*2

    ; 设置显存段es=b800+dh*10
    mov ax, 0
    mov ah, 10
    mul dh      ; AX
    add ax, 0b800h ; b800+dh*10:di
    mov es, ax


    
    show_str_start:
        mov al, ds:[si]  ; 取 ASCII
        cmp al, 0        
        je show_str_end ; 0字符，结束打印

        mov es:[di], al
        mov es:[di+1], cl
        inc si    ; int_8 char
        add di, 2 ; int_16 char[2]
        jmp show_str_start

    show_str_end:
        pop si
        pop di
        pop es
        pop ax

        ret


divdw:
    ; 说明: 进行非溢出div
    ; 参数:
    ; (dx)=高16位 (ax)=低16位 (cx)=除数
    ; 输出:
    ; (dx)=高16位 (ax)=低16位 (cx)=余数

    push ax     ; 临时保存
    mov ax, dx  
    mov dx, 0   ; 0:DX / CX
    div cx      ; DX:AX 余:商
    mov bx, ax  ; BX=高16位结果

    pop ax      ; (余)DX:AX
    div cx      ; DX:AX / CX

    mov cx, dx  ; 余数
    mov bx, dx  ; 高16位

    ret
