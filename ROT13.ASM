org 100h
        push  c_str
        call  ROT13
ret

;INPUT
;   STR_PTR
;OUTPUT
;   AX
ROT13:
        push  bp
        mov   bp, sp
        push  bx
        push  si

        ;length check
        mov   cx, 13
        mov   si, [bp + 4]
        ;rot13
.lp1:
        cmp   byte[si], 0
        jz    .no
        movzx ax, byte[si]
        sub   al, $30
        add   al, 13
        mov   bl, 10
        div   bl
        test  cx, 1
        jz    .even
        add   [odd], ah
        jmp   .continue
.even:
        add   [even], ah
.continue:
        inc   si
        loop  .lp1
        cmp   byte[si], 0
        jnz   .no

        mov   al, [odd]
        mov   bl, 3
        mul   bl
        add   al, [even]
        adc   ah, 0
        xor   dx, dx
        mov   bx, 10
        div   bx

        mov   ax, 1
        cmp   dx, 0
        jz    .end
.no:
        mov   ax, 0
.end:
        pop si
        pop dx
        mov sp, bp
        pop bp
ret

odd       db 0
even      db 0
c_str     db '1432543255534',0
