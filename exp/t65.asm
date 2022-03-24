assume cs:code

a segment
    db 1,2,3,4,5,6,7,8
a ends

b segment
    db 1,2,3,4,5,6,7,8
b ends

c segment
    db 1,2,3,4,5,6,7,8
c ends

code segment
start :
    mov ax, a
    mov ds, ax ; ds:bx ->a
    
    mov ax, b
    mov ss, ax ; ss:bx ->b

    mov ax, c
    mov es, ax ; es:bx ->c

    mov bx, 0  ; 指针

    mov cx, 8  ; 循环8次
    s:
        mov dl, ds:[bx] ; dl存a+b
        add dl, ss:[bx]
        mov es:[bx], dl
        inc bx
    loop s
    mov ax,4c00h
    int 21h

code ends

end start