assume  cs:code,ds:data,es:table

data segment
    db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
    db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
    db '1993','1994','1995'
    ;偏移地址范围0-53h，表示21个年份的21个字符串 
  
    dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
    dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
    ;偏移地址范围54h-0a7h，表示21年公司总收入的21个dword型数据
  
    dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
    dw 11542,14430,15257,17800
    ;偏移地址范围0a8h-0d1h，表示21年公司雇员人数的21个word型数据
data ends

table segment
    db 21 dup('year summ ne ?? ')
table ends

code segment
start:
    ;Warning: 数据存储的方式[内存中]是低地址到高地址，意味着存储数据时也要按照此格式 string不需要，字符2字节
    ;ds=data es=table cx=21
    ;year  :  ds:[bx] ds:[bx+2]         => es:[di]    es:[di+2]
    ;income:  ds:[bx+54h] ds:[bx+56h]   => es:[di+5]  es:[di+7] 低 : 高
    ;num   :  ds:[si+0a8h]              => es:[di+10]
    ;aver  :  DX  :AX ->AX:DX 
    ;         32位:16位  商:余

    mov ax, data
    mov ds, ax

    mov ax, table
    mov es, ax

    mov bx, 0
    mov di, 0
    mov si, 0
    mov cx, 21
    s:
        ; year 4字节 正常读
        mov ax, ds:[bx]
        mov es:[di], ax
        mov ax, ds:[bx+2]
        mov es:[di+2], ax

        ; income 4字节 低高地址区分 int_32
        mov ax, ds:[bx+56h]  ; 读入高16位
        mov es:[di+7], ax
        mov ax, ds:[bx+54h]  ; 读入低16位
        mov es:[di+5], ax

        ; num 2字节 无须区分 一次读入 int_16
        mov ax, ds:[si+0a8h]
        mov es:[di+10], ax

        ; aver
        mov dx, ds:[bx+56h]  ; 读入高16位
        mov ax, ds:[bx+54h]  ; 读入低16位
        div word ptr es:[di+10] ; income/num
        mov es:[di+0dh], ax  ; ax商

        add bx, 4   ; int_32[] 下一个元素
        add si, 2   ; int_16[] 下一个元素
        add di, 16  ; table 换行
    loop s


    mov ax, 4c00h
    int 21h

code ends

end start