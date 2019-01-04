org 100h
        push  c_str
        call  ROT13
ret

;INPUT
;   STR_PTR
;OUTPUT
;   AX
ROT13:                     ;пролог
        push  bp
        mov   bp, sp
        push  bx
        push  si

        ;length check
        mov   cx, 13
        mov   si, [bp + 4]
        ;rot13
.lp1:
        cmp   byte[si], 0  ;преждевременный ноль
        jz    .no
        movzx ax, byte[si] ;загружаем символ
        sub   al, $30      ;преобразуем в диапазон от 0 до 9
        add   al, 13
        mov   bl, 10
        div   bl           ;ROT13
        test  cx, 1        ;четная нечетная позиция
        jz    .even
        add   [odd], ah
        jmp   .continue
.even:
        add   [even], ah
.continue:
        inc   si
        loop  .lp1
        cmp   byte[si], 0
        jnz   .no         ;если нуля на конце нет

        mov   al, [odd]
        mov   bl, 3
        mul   bl          ;ответ в AX
        add   al, [even]
        adc   ah, 0       ;учет переноса
        xor   dx, dx
        mov   bx, 10      ;DX:AX
        div   bx

        mov   ax, 1       ;тип да
        cmp   dx, 0
        jz    .end
.no:
        mov   ax, 0       ;нет
.end:
        pop si
        pop dx
        mov sp, bp
        pop bp
ret

odd       db 0    ;нечетные
even      db 0    ;четные
c_str     db '1432543255534',0