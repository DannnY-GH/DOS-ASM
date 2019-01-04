org 100h
        mov      ah, 3Dh
        mov      al, 0
        mov      dx, FName
        int      21h
        mov      [FHandle], ax

        xor      di, di

        mov      cx, $5D

.lp1:
        push     cx
        mov      cx, 1   ;$95
        mov      bx, [FHandle]
        mov      ah, 3Fh
        lea      dx, [chr]
        int      21h


        pop      cx
        loop     .lp1
        xor      di, di
        mov      cx, $5F
.lp:
        push     cx
        mov      cx, 1   ;$95
        mov      bx, [FHandle]
        mov      ah, 3Fh
        lea      dx, [chr]
        int      21h
        add      di,  [chr]

        pop      cx
        loop     .lp

        ret

FName   db 'e:\crackme\CrackMe4.com', 0
FHandle rw 1
chr     dw 0,0
ans     rw 1


