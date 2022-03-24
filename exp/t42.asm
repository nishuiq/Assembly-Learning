assume cs:code

code segment
    mov ax,cs      ;______ 代码补全
    mov ds,ax
    mov ax,0020h
    mov es,ax
    mov bx,0
    mov cx,0017h   ;______ 先随意置入一个数，再Debug进行反编译查看 mov ax, 4c00h 的地址
    s:
        mov al,[bx]
        mov es:[bx],al
        inc bx
    loop s

    mov ax,4c00h
    int 21h
code ends

end