assume cs:codesg

data segment
    
    db 'welcome to masm!',0

data ends

codesg segment

start:
    ; B800 显存段 2 绿色
    ; ds:si 字符串首地址指针
    ; es:bx 显存段
    ; dh dl 显存段偏移量


    ; 初始化字符串指针
    mov ax, data
    mov ds, ax
    mov si, 0

    ; 初始化 显存段 es:bx
    mov ax, 0b800h
    mov es, ax
    mov bx, 1824   ; 初始化 行列 dh=0~24 dl=0~79

    ; 由于有3行，取25/2-1=11行，取80/2=40列，16/2=8列字符串占用，(40-8)*2每列占用2字节。
    ; 11*160 + (40-8)*2
    ; 25/2=12, 80/2=40, 16/2=8 占用8列

    ; 0_100_0_000=02h 绿色
    ; 0_010_0_100=24h 绿底红
    ; 0_111_0_001=71h 白底蓝
    ; 加偏移 +160 下一行

    ; 获取字符，并判断非0
work:
    mov cl, ds:[si]
    mov ch, 0
    jcxz ok ; 为0则跳出
    
    mov byte ptr es:[bx], cl
    mov byte ptr es:[bx+160],cl
    mov byte ptr es:[bx+320],cl

    mov byte ptr es:[bx+1], 02h
    mov byte ptr es:[bx+160+1], 24h
    mov byte ptr es:[bx+320+1], 71h

    inc si
    inc bx
    inc bx
    jmp short work

ok:
    mov ax, 4c00h
    int 21h

codesg ends
end start