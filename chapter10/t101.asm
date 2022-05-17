title Onlyfortest
DOSSEG
.model small
.stack 100h

.data
  table db 21 dup('year summ ne ?? ')  ; 输出表格

  year db '1975','1976','1977','1978','1979','1980','1981','1982','1983','1984','1985','1986','1987','1988','1989','1990','1991','1992','1993','1994','1995'
    ;偏移地址范围0-53h，表示21个年份的21个字符串 

  income dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514,345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
  ;偏移地址范围54h-0a7h，表示21年公司总收入的21个dword型数据

  number dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226,11542,14430,15257,17800
    ;偏移地址范围0a8h-0d1h，表示21年公司雇员人数的21个word型数据

  buffer db 400 dup (0)
  .const
  mmod dw 10  ; 取模10，方便32位除法
.code


; show_str
; Purpose:  打印字符串 ds:si 到显示屏中第 dh 行 第 dl 列
; Input:    (dh)=0~24行 (dl)=0~79列 (cl)=颜色 (ds:si)=字符串首地址
; Output:   None
; To Call:  call show_str
show_str proc
  ; 保护现场 
  push ax
  push es
  push di
  push si

  ; 设置显存段指针 di=dl*2
  mov ax, 0
  mov al, dl
  add ax, ax
  mov di, ax

  ; 设置显存段es=b800+dh*10  ; es:di显存段
  mov ax, 10
  mul dh     ; dh*160=(dh*10+b800h)<<4
  add ax, 0b800h
  mov es, ax

  show_str_start:
    mov al, ds:[si]
    cmp al, 0
    je show_str_ret  ; 字符串末尾，结束
    mov es:[di], al
    mov es:[di+1], cl
    inc si     ; int_8 char 下一个字符
    add di, 2  ; int_16 char[2]
    jmp show_str_start

  show_str_ret:  ; 恢复现场
    pop si
    pop di
    pop es
    pop ax
    ret
show_str endp

; divdw
; Purpose:  32位的除法操作，不溢出
; Input:    (dx)=高16位 (ax)=低16位 (cx)=除数
; Output:   (dx)=高16位 (ax)=低16位 (cx)=余数
; To Call:  call divdw
divdw proc
  ; 保护现场
  push bx

  ; 思路就是分部除法，高 16 位除，低 16 位除，以防止 div 爆 ax
  ; 先把高位 dx 放到低位 ax 中，dx:ax=0:dx 去除 cx，进行 32 位除法，这样就不会使得 ax 溢出
  ; 高位除法后的余数dx，dx:ax(低16位) / cx => ax低16位商
  push ax
  mov ax, dx
  mov dx, 0
  div cx      ; dx:ax=0:dx/cx => dx:ax 余:商
  mov bx, ax  ; 保存高16位商结果
  pop ax
  div cx      ; (余)dx:ax/cx => ax低16位商
  mov cx, dx  ; 余数
  mov dx, bx  ; dx高16位商

  ; 恢复现场
  pop bx
  ret
divdw endp

; dtoc16
; Purpose:  将 word 16 位数字转成 10 进制字符串，字符串以 0 结尾
; Input:    (ax)=word  (ds:si) 字符串首地址
; Output:   None
; To Call:  call dtoc16
dtoc16 proc
  ; 保护现场
  push ax
  push cx
  push dx
  push si

  mov cx, 0
  dtoc16_start:
    mov dx, 0     ; 每次执行除法前先将dx置0，dx:ax=0:ax 因为16位除法ax除10很容易溢出(al商溢出)，因此必须32位除法
    div mmod      ; dx:ax 余:商 这里mmod设置成dw以进行32位除法
    add dx, 30h   ; 30h=48='0'ASCII，将数字转成ASCII的字符串数字
    push dx
    inc cx        ; 计数，压栈，后续弹栈结果是顺序的

    cmp ax, 0
    je dtoc16_ret
    jmp dtoc16_start


  dtoc16_ret:
  dtoc16_loop:
    pop dx
    mov ds:[si], dl
    inc si
    loop dtoc16_loop

    ; 尾0
    mov byte ptr ds:[si], 0
    ; 恢复现场

    pop si
    pop dx
    pop cx
    pop ax
    ret
dtoc16 endp

; dtoc32
; Purpose:  将 dword 32 位数字转成 10 进制字符串，字符串以 0 结尾
; Input:    (高16位dx:低16位ax)=dword  (ds:si) 字符串首地址
; Uses:     divdw
; Output:   None
; To Call:  call dtoc32
dtoc32 proc
  ; 保护现场
  push ax
  push bx
  push cx
  push dx
  push si

  mov bx, 0   ; bx计次位
  dtoc32_start:
    mov cx, 10
    call divdw
    add cx, 30h  ; 30h=48='0'ASCII，将数字转成ASCII的字符串数字
    push cx
    inc bx
    cmp dx, 0
    je dtoc32_t1
    jmp dtoc32_start

  dtoc32_t1: 
    cmp ax, 0       ; ds=0,ax=0 break
    je dtoc32_loop_init
    jmp dtoc32_start

  dtoc32_loop_init:
    mov cx, bx
  dtoc32_loop:
    pop bx
    mov ds:[si], bl
    inc si
    loop dtoc32_loop

    ; 尾0
    mov byte ptr ds:[si], 0

  dtoc32_ret:
    ; 恢复现场
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
dtoc32 endp

main proc
start:
  ;Warning: 数据存储的方式[内存中]是低地址到高地址，意味着存储数据时也要按照此格式 string不需要，字符2字节
  ;ds=data es=table cx=21
  ;year  :  ds:[bx] ds:[bx+2]         => es:[di]    es:[di+2]
  ;income:  ds:[bx+54h] ds:[bx+56h]   => es:[di+5]  es:[di+7] 低 : 高
  ;num   :  ds:[si+0a8h]              => es:[di+10]
  ;aver  :  DX  :AX ->AX:DX 
  ;         32位:16位  商:余

  ; table 数据
  mov ax, @data
  mov ds, ax
  mov es, ax

  lea bx, year
  lea di, table
  lea si, number
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
    mov ax, ds:[si]
    mov es:[di+10], ax

    ; aver
    mov dx, ds:[bx+56h]  ; 读入高16位
    mov ax, ds:[bx+54h]  ; 读入低16位
    div word ptr es:[di+10] ; income/num
    mov es:[di+0dh], ax  ; ax商

    mov byte ptr es:[di+4], 0

    add bx, 4   ; int_32[] 下一个元素
    add si, 2   ; int_16[] 下一个元素
    add di, 16  ; table 换行
  loop s

  ; 开始处理数据，每行打印一次数据
  mov bx, 0
  mov ax, @data
  mov ds, ax
  lea si, table   ; ds:si 指向 table

  ; 设置打印参数
  mov dh, 2
  mov dl, 10
  mov cx, 21
  ; 先打印 year 再打印 income 再打印 employee 再打印 avg
  ; call show_str ==> year
  ; dx:ax -> call dtoc32 -> buffer -> idx:5 call show_str ==> income
  ; call dtoc16 -> buffer -> idx:12 call show_str ==> employee
  ; call dtoc16 -> buffer -> idx:18 call show_str ==> avg
  test_print:
    ; 先打印 year
    push cx
    mov cl, 2
    call show_str

    ; 再打印收入
    push dx    ; 保存现场，dx 与打印参数有关
    mov bp, si ; 保存现场，不能 push si 方法，有问题
    mov dx, ds:[si+7]
    mov ax, ds:[si+5]
    lea si, buffer
    call dtoc32
    pop dx
    add dl, 5
    call show_str

    ; 打印雇员数
    mov si, bp   ; 恢复现场，不能 pop si
    mov ax, ds:[si+0ah]
    mov bp, si   ; 保存现场
    lea si, buffer
    call dtoc16
    add dl, 8
    call show_str

    ; 打印人均收入
    mov si, bp  ; 恢复现场
    mov ax, ds:[si+0dh]
    mov bp, si  ; 保存现场
    lea si, buffer
    call dtoc16
    add dl, 6
    call show_str

    ; 进行下一轮
    mov si, bp  ; 恢复现场
    pop cx      ; 恢复循环次数
    inc dh      ; 下一行
    mov dl, 10  ; 重新拉回列
    add si, 10h

  loop test_print


  mov ax, 4c00h
  int 21h
main endp
end main

