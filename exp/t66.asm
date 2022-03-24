assume cs:code

a segment
    dw 1,2,3,4,5,6,7,8,9,0ah,0bh,0ch,0dh,0eh,0fh,0ffh ; 16个数
a ends

b segment
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 15个0
b ends

code segment
start:
    mov ax, a
    mov ds, ax ; ds:bx ->a
    mov bx, 0

    mov ax, b
    mov ss, ax ; ss:sp ->b
    mov sp, 30

    mov cx, 8  ; 循环8
    s:
        push [bx]
        add bx, 2
    loop s

    mov ax,4c00h
    int 21h

code ends

end start