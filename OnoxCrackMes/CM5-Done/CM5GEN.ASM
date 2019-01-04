org 100h

    ;create new file
    mov ah, $3C
    mov dx, FName
    xor cx, cx
    int 21h
    mov [FHandle], ax

    ;randomize S1 and S2
    call RandInit
    mov cx, 4
    mov si, S1
    mov di, S2
.lp1:
    call RandomChr
    mov  [si], al
    call RandomChr
    mov  [di], al
    inc  si
    inc  di
    loop .lp1


    ;create lic string
    mov [min], 0
    mov [max], 3
    call RandomChr
    mov bx, tbl
    xlatb
    mov bl, $08

    mov cx, 4
    lea di, [buf + $29]
.lp2:
    lea si, [S1]
    test al, bl
    jnz .cnt
    lea si, [S2]
.cnt:
    shr bx, 1
    movsd
    inc di
    loop .lp2

    ;write to file
    mov ah, 40h
    mov bx, [FHandle]
    mov cx, $3C
    mov dx, buf
    int 21h
    ;close file
    mov ah, 3eh
    int 21h

    ret

RandInit:
   mov   ah, $2C
   int   21h
   mov   [prev], dx
ret

RandomChr:
    push  dx
    push  bx
    push  cx
    mov   ax, [prev]
    rol   ax, 7
    add   ax, 23
    mov   bx, [max]
    xor   dx, dx
    div   bx
    mov   ax, dx
    add   ax, [min]
    mov   [prev], ax
    pop   cx
    pop   bx
    pop   dx
ret

FName   db 'crackme5.lic', 0
FHandle rw 1
buf     db 8 dup (0), 'Keep Calm and Hack The Planet...', $0A, 4 dup(0),$2D, 4 dup(0),$2D,4 dup(0),$2D, 4 dup(0)
max     dw 26
min     dw 65
S1      rb 4
S2      rb 4
tbl     db 3,5,6
prev    rw 1
