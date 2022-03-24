assume cs:codesg, ds:datasg

; 大写字符 xx0xxxxx  大->小 or  00_1_00000b 00100000b
; 小写字符 xx1xxxxx  小->大 and 11_0_11111b 11011111b

datasg segment
    db 'BaSic'
    db 'iNfOrMaTiOn'
datasg ends

codesg segment
start:
    mov ax, datasg
    mov ds, ax
    mov bx, 0
    
    mov cx, 5
    s:
        mov al, [bx]
        and al, 11011111b ; 转换为大写
        mov [bx], al
        inc bx
    loop s

    mov cx, 11
    mov bx, 5
    s0:
        mov al, [bx]
        or al, 00100000b ; 转换为小写
        mov [bx], al
        inc bx
    loop s0

    mov ax, 4c00h
    int 21h

codesg ends
end start