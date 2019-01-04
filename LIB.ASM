org 100h
include 'proc16.inc'

jmp start
;DATA
strAsk1          db 'A = $'
strAsk2          db 'B = $'
strResult        db 'A/B - 7*B = $'
stringBuf        db 101, 100 dup('$')
num1             dw ?
num2             dw ?
strAsk           db 'Please, enter your first number: $'
ans              rb 3
mnpos            dw '?'
mxpos            dw '?'
cnt              dw 0
s                db 'Hello My Dear Friend!$'
buf              dw 10 dup('$')
n                db 10'
arr1             dw 900,2,-3,4,5,6,7,-888,9,11, '$'
arr2             dw 1,-2,3,4,555,-6,7,88,10,9, '$'
arr3             dw 11 dup('?')
endLine          db 13,10,'$'
strNotFound      db 'No such element found...', 13, 10,'$'

;--------------------------------------------

start:
;=============INPUT=============
   mov  di, strAsk1
   call printStr

   mov bx, stringBuf
   call readWordFromConsole ;to buf
   mov  bx, ax              ;A - BX

   mov  di, strAsk2
   call printStr

   call readWordFromConsole ;B - AX
   xchg ax, bx              ;A - AX, B - BX

;===========CALCULATE============
;   mov di, strResult
;   call printStr
     push ax
     push bx
     call CalculationRegisters
     call NumToStr.Print
     call endl

     pop  [num2]
     pop  [num1]
     push [num2]
     push [num1]
     call CalculateGlobal
     call NumToStr.Print
     call endl

    ;push bx
    ;push ax
    call CalculateStack
    add  sp, 4
    call NumToStr.Print
    call endl

;   mov di, strResult
;   call printStr
;   call NumToStr.Print

   call waitKey
   ret

proc CalculationRegisters         ; proc
   mov  dx, 0
   idiv bx
   push ax
   mov  ax, bx
   mov  cx, 7
   imul cx
   neg  ax
   pop  bx
   add  ax, bx
   ret
endp

proc CalculateGlobal
   mov  ax, [num1]
   mov  bx, [num2]
   mov  dx, 0
   idiv bx
   push ax
   mov  ax, bx
   mov  cx, 7
   imul cx
   neg  ax
   pop  bx
   add  ax, bx
   ret
endp

CalculateStack:
   push bp
   mov  bp, sp

   mov  ax, [bp+4]
   mov  bx, [bp+6]
   mov  dx, 0
   idiv bx
   push ax
   mov  ax, bx
   mov  cx, 7
   imul cx
   neg  ax
   pop  bx
   add  ax, bx

   mov  sp, bp
   pop  bp
   ret

NumToStr.Print:
   mov  di, stringBuf
   call word_to_sdec_str
   mov  di, stringBuf
   call printStr
   call endl
   ret

readArrayFromConsole:

ret
;--------------------------------------------

;INPUT:
;   BX - string buffer address
;OUTPUT:
;   AX - number
readWordFromConsole:
    push  cx
    push  dx
    push  di

    mov   dx, bx
    mov   ah, 0Ah
    int   21h

    call  endl

    mov   ax, 0
    mov   di, 10  ;10base
    movzx cx, byte[bx + 1]
    mov   si, 2
    cmp   byte[bx + si], '-'
    jnz   .unsigned
    push  1
    inc   si
    dec   cx
    jmp   .lp
.unsigned:
    push  0
.lp:
    mul   di
    sub   byte[bx + si], '0'
    add   al, byte[bx + si]
    adc   ah, 0
    inc   si
loop .lp

    pop  si
    test si, si
    jz   .end
    neg  ax
.end:
    pop di
    pop dx
    pop cx
ret
;--------------------------------------------
OutputStr:         ; Вывод строки
        push  ax

        mov   ah, $09
        int   21h

        pop   ax
        ret

;--------------------------------------------
getAllEven:     ; BX - source
    push   ax
    push   cx
    push   si
    push   di

    call print_word_arr
    xor    si, si
    xor    di, di
    movzx  cx, [n]
.lp:
    mov    ax, [bx + si]
    test   ax, 1
    jnz     .miss
    inc    word[cnt]
    mov    [arr3 + di], ax
    mov    [arr3 + di + 2], '$'
    add    di, 2
.miss:
    add    si, 2
    loop   .lp

    mov  bx, arr3
    call print_word_arr

    mov  ax, [cnt]
    mov di,  buf
    call word_to_udec_str
    mov di, buf
    call printStr

    pop di
    pop si
    pop cx
    pop ax
ret
;------------------------------------------------------

;--------------------------
chtoto:
    ;call cntEqualsInTwoArrays
    mov   byte[buf], 4
    mov   ah, 0ah
    mov   dx, buf
    int   21h

    ;mov   di, buf+2
    call  endl

    CLD
    mov   cx, 21
    mov   di, s
    mov   al, byte[buf+2]
    repne scasb

    mov   bx, di

    CLD
    mov   cx, 21
    mov   di, s
    mov   al, byte[buf+4]
    repne  scasb

    sub   bx, di
    test  bx, bx
    jns   .good
    neg   bx
.good:
    inc   bx
    mov ax,  bx
    mov  di, buf
    call word_to_sdec_str
    mov di, buf
    call printStr
    ;call  printStr

    ;mov  bx, arr1
    ;call getAllEven

    ;call cntOddNumbers

    ;mov  bx, arr1
    ;call findMin
    ;mov  bx, arr1
    ;call findMax

    ;cmp  ah, al
    ;jb   .ok
    ;xchg  ah, al
    call waitKey
    ret
.ok:

    movzx   si, ah
    mov   bl, al
    sub   bl, ah
    movzx ax, bl
    mov   bh, 2
    div   bh
    movzx cx, al
    add    si, 2
    dec    cx


.lp:
    mov   [arr1 + si], 0
    add   si, 2
    loop .lp

    ;mov   [arr1 + si], '$'
    mov bx, arr1
    call print_word_arr

    call waitKey
ret
;--------------------------------------------
findMin:      ;BX - source
    push   cx ;cycle
    push   dx ;out value
    push   si ;source
    push   di ;source string
    push   ax ;busffer

    call print_word_arr
    xor    si, si
    xor    di, di
    movzx  cx, [n]
    mov    dx, $7FFF    ;min+
.lp:
    mov    ax, [bx + si]
    cmp    dx, ax
    jl     .miss
    mov    dx, ax
    mov    [mnpos], si
.miss:
    add    si, 2
    loop   .lp

    mov  ax, [mnpos]
    ;mov  bl, 2
    ;div  bl
    mov  ah, 0
    mov di,  buf
    ;call word_to_sdec_str
    ;mov di, buf
    ;call printStr
    jmp  .end

.nfound:
    mov di, strNotFound
    call printStr

.end:
    mov bx, ax
    pop ax ;busffer
    mov ah, bl
    pop di
    pop si
    pop dx
    pop cx
ret
;--------------------------------------------
findMax:     ;BX - source
    push   cx
    push   dx
    push   si
    push   di
    push   ax ;busffer
    call print_word_arr
    xor    si, si
    xor    di, di
    movzx  cx, [n]
    mov    dx, $ffff    ;min+
.lp:
    mov    ax, [bx + si]
    cmp    dx, ax
    jg     .miss
    mov    dx, ax
    mov    [mxpos], si
    add    di, 2

.miss:
    add    si, 2
    loop   .lp

    mov  ax, [mxpos]
    ;mov  bl, 2
    ;div  bl
    mov di,  buf
    ;call word_to_sdec_str
    ;mov di, buf
    ;call printStr
    jmp  .end

.nfound:
    mov di, strNotFound
    call printStr

.end:
    mov bx, ax
    pop ax
    mov al, bl
    pop di
    pop si
    pop dx
    pop cx
ret
;--------------------------------------------
findMinPositive:     ;BX - source
    push   ax
    push   cx
    push   dx
    push   si
    push   di

    call print_word_arr
    xor    si, si
    xor    di, di
    movzx  cx, [n]
    mov    dx, $FFFF    ;min+
.lp:
    mov    ax, [bx + si]
    test   ax, ax
    js     .miss
    cmp    dx, ax
    jb     .miss
    mov    dx, ax
    inc    word[cnt]
    mov    [arr3 + di], ax
    mov    [arr3 + di + 2], '$'
    add    di, 2
.miss:
    add    si, 2
    loop   .lp

    cmp  word[cnt], 0
    jz   .nfound
    mov  ax, dx
    mov di,  buf
    call word_to_sdec_str
    mov di, buf
    call printStr
    jmp  .end

.nfound:
    mov di, strNotFound
    call printStr

.end:
    pop di
    pop si
    pop dx
    pop cx
    pop ax
ret

;--------------------------------------------
cntOddNumbers:     ; BX - source
    push   ax
    push   cx
    push   si
    push   di

    call print_word_arr
    xor    si, si
    xor    di, di
    movzx  cx, [n]
.lp:
    mov    ax, [bx + si]
    test   ax, 1
    jz    .miss
    inc    word[cnt]
    mov    [arr3 + di], ax
    mov    [arr3 + di + 2], '$'
    add    di, 2
.miss:
    add    si, 2
    loop   .lp

    mov  bx, arr3
    call print_word_arr

    mov  ax, [cnt]
    mov di,  buf
    call word_to_sdec_str
    mov di, buf
    call printStr

    pop di
    pop si
    pop cx
    pop ax
ret
;--------------------------------------------
cntEqualsInTwoArrays:
    push ax
    push bx
    push cx
    push si
    push di

    xor ax, ax
    xor bx, bx
    xor   si, si
    movzx cx, [n]

.lp1:
    push cx
    movzx cx, [n]
    xor di, di

  .lp2:
    mov ax, [arr2 + di]
    cmp word[arr1 + si], ax
    jne .notequal
    mov [arr3 + bx], ax
    mov [arr3 + bx + 2], '$'
    add bx, 2
    inc word[cnt]
.notequal:
    add di, 2
    loop .lp2

    pop cx
    add si, 2

loop    .lp1

    mov  bx, arr1
    call print_word_arr
    mov  bx, arr2
    call print_word_arr
    mov  bx, arr3
    call print_word_arr

    mov  ax, [cnt]
    mov di,  buf
    call word_to_sdec_str
    mov di, buf
    call printStr

    pop di
    pop si
    pop cx
    pop bx
    pop ax

ret
;--------------------------------------------
print_word_arr:          ;$-terminated
    push si
    push ax
    push cx
    mov  cx, '$'          ;BX - sourse
    xor  si, si
pwaLP:
    cmp cl, byte[bx + si]
    je pwaEND
    mov ax,[bx + si]
    mov  di, buf
    call word_to_sdec_str
    mov di, buf
    call printStr
    mov dl, ' '
    call printChar
    add si, 2
    jmp  pwaLP
pwaEND:
    call endl
    pop cx
    pop ax
    pop si
ret
;--------------------------------------------

calculate_sum:
   mov dx, word[bx+si]
   test dx,1
   jnz miss
 
   add ax, dx
 
miss:
   add si, 2
   loop calculate_sum
   mov di, buf
   call word_to_sdec_str
   mov di, buf
   call printStr
   mov dl, ' '
   call printChar
   call endl
   call waitKey
ret
 
lp1:
   mov ax, [bx + si]
   mov  di, buf
   call word_to_sdec_str
   mov  di, buf
   call printStr
   mov dl, ' '
   call printChar
   add si, 2
   loop lp1;
   call endl
   call waitKey
   ret
;--------------------------------------------
printStr:      ;DI - source
   push ax
   mov   ah, 09h
   xchg dx, di
   int   21h
   xchg dx, di
   pop ax
ret
;--------------------------------------------
waitKey:
   mov ah, 08h
   int 21h
ret
;--------------------------------------------
endl:
   push di
   mov di,endLine
   call printStr
   pop di
ret
;--------------------------------------------
printChar:                 ;from DL
   mov ah, 02h
   int 21h
ret
;--------------------------------------------
word_to_sdec_str:
   push ax
   test ax,ax              ;Проверка знака AX
   jns wtsds_no_sign       ;Если >= 0, преобразуем как беззнаковое
   mov byte[di],'-'        ;Добавление знака в начало строки
   inc di                  ;Инкремент DI
   neg ax                  ;Изменение знака значения AX
wtsds_no_sign:
   call word_to_udec_str   ;Преобразование беззнакового значения
   pop ax
   ret
;--------------------------------------------
byte_to_udec_str:
   push ax
   xor ah,ah               ;Преобразование байта в слово (без знака)
   call word_to_udec_str   ;Вызов процедуры для слова без знака
   pop ax
   ret

;--------------------------------------------
word_to_udec_str:
   push ax                 ;сохраняем регистр общего назначения
   push cx
   push dx
   push bx
   xor cx,cx               ;Обнуление CX - четчик символов
   mov bx,10               ;В BX делитель (10 для десятичной системы)
 
wtuds_lp1:                  ;Цикл получения остатков от деления
   xor dx,dx               ;Обнуление старшей части двойного слова
   div bx                  ;Деление AX=(DX:AX)/BX, остаток в DX
   add dl,'0'              ;Преобразование остатка в код символа
   push dx                 ;Сохранение в стеке
   inc cx                  ;Увеличение счетчика символов
   test ax,ax              ;Проверка AX
   jnz wtuds_lp1           ;Переход к началу цикла, если частное не 0.
 
wtuds_lp2:                 ;Цикл извлечения символов из стека
   pop dx                  ;Восстановление символа из стека
   mov [di],dl             ;Сохранение символа в буфере
   inc di                  ;Инкремент адреса буфера
   loop wtuds_lp2          ;Команда цикла
   mov byte[di], '$'
   pop bx
   pop dx
   pop cx
   pop ax
   ret