include 'proc16.inc'
        org 100h

EntryPoint:
        mov     [error], 0
        ;open existing file
        mov      ah, 3Dh
        mov      al, 0
        mov      dx, FName
        int      21h
        mov      [FHandle], ax
        call    ParseFileOfDoubles

        ;lea     si, [testbt]
        ;lea     di, [testans]
        ;call    ParseDoubleFromString

        mov     ah, $0F
        int     10h
        mov     [Video.OldMode], al
        mov     [Video.OldPage], bh
        mov     ax, $0013
        int     10h
        mov     ax, $A000
        mov     es, ax

        push    11
        push    6
        push    100
        push    5
        push    5
        call    PlotLine
        add     sp, 10

        push    7
        push    110
        push    310
        push    80
        push    80
        ;call    PlotLine
        add     sp, 10

        push    $28
        push    30
        push    50
        push    50
        call    PlotFilledCircle
        add     sp, 8

        mov     cx, 40
        mov     ax, 3
        mov     bx, 50
        mov     dx, 1
.lp:
        push    dx
        push    bx
        push    50
        push    270
        call    PlotCircle
        add     sp, 8

        sub     bx, ax
        inc     dx
        loop    .lp

        push    13
        push    199
        push    319
        ;call    SetPixel
        add     sp, 6

        call    ReadKey
;Draw 3D Model
        call    ParseFacesAndDraw
;=====================================================
        call    ReadKey

        movzx   ax, [Video.OldMode]
        int     10h
        mov     ah, $05
        mov     al, [Video.OldPage]
        int     10h
        ret

ReadKey:
        mov     ax, $0C08
        int     21h
        test    al, al
        jnz     @F
        mov     ah, $08
        int     21h
@@:
        ret
;=====================================================
;INPUT:
;
;OUTPUT:
;     DI - result (QWORD)
proc  ParseFacesAndDraw c uses si
locals

        chr      rb 1
        counter  dw 0
        a        rw 1
        b        rw 1
        c        rw 1
        x0       rw 1
        y0       rw 1
        x1       rw 1
        y1       rw 1
endl
        xor      si, si         ;bStr w pointer
        lea      di, [vertices] ;vert table pointer
        mov      cx, [N]        ;LIMITER
        push     cx

        jmp      .readlp
        ;skip till #
.skiplp1:
        mov      cx, 1
        mov      bx, [FHandle]
        mov      ah, 3Fh
        lea      dx, [chr]
        int      21h
        cmp      [chr], '#'
        jz       .readlp
        jmp      .skiplp1
        ;skipped til #
        push     2492
.readlp:

        mov     ax, $0800
        int     21h              ;READ KEY

        call    GetFace
        mov     [a], ax
        dec     [a]
        call    GetFace
        mov     [b], ax
        dec     [b]
        call    GetFace
        mov     [c], ax
        dec     [c]
        ;========LINES OF FACES===========
        mov     si, vertices
        mov     ax, [a]
        mov     bx, 16
        mul     bx
        add     si, ax

        push    320
        push    si
        call    RefineView
        add     sp, 4
        mov     [x0], ax

        add     si, 8
        push    200
        push    si
        call    RefineView
        add     sp, 4
        mov     [y0], ax

        mov     si, vertices
        mov     ax, [b]
        mov     bx, 16
        mul     bx
        add     si, ax

        push    320
        push    si
        call    RefineView
        add     sp, 4
        mov     [x1], ax

        add     si, 8
        push    200
        push    si
        call    RefineView
        add     sp, 4
        mov     [y1], ax

        mov      ax, [Screen.Height]
        neg     [y0]
        neg     [y1]
        add     [y0], ax
        add     [y1], ax
        mov      ax, [COEF]
        sub     [y0], ax
        sub     [y1], ax

        push    $0F
        push    [y1]
        push    [x1]
        push    [y0]
        push    [x0]
        call    PlotLine
        add     sp, 10
;=========first two============
        mov     si, vertices
        mov     ax, [a]
        mov     bx, 16
        mul     bx
        add     si, ax

        push    320
        push    si
        call    RefineView
        add     sp, 4
        mov     [x0], ax

        add     si, 8
        push    200
        push    si
        call    RefineView
        add     sp, 4
        mov     [y0], ax

        mov     si, vertices
        mov     ax, [c]
        mov     bx, 16
        mul     bx
        add     si, ax

        push    320
        push    si
        call    RefineView
        add     sp, 4
        mov     [x1], ax

        add     si, 8
        push    200
        push    si
        call    RefineView
        add     sp, 4
        mov     [y1], ax

        mov      ax, [Screen.Height]
        neg     [y0]
        neg     [y1]
        add     [y0], ax
        add     [y1], ax
        mov      ax, [COEF]
        sub     [y0], ax
        sub     [y1], ax

        push    $0F
        push    [y1]
        push    [x1]
        push    [y0]
        push    [x0]
        call    PlotLine
        add     sp, 10
;=========second two============
        mov     si, vertices
        mov     ax, [b]
        mov     bx, 16
        mul     bx
        add     si, ax

        push    320
        push    si
        call    RefineView
        add     sp, 4
        mov     [x0], ax

        add     si, 8
        push    200
        push    si
        call    RefineView
        add     sp, 4
        mov     [y0], ax

        mov     si, vertices
        mov     ax, [c]
        mov     bx, 16
        mul     bx
        add     si, ax

        push    320
        push    si
        call    RefineView
        add     sp, 4
        mov     [x1], ax

        add     si, 8
        push    200
        push    si
        call    RefineView
        add     sp, 4
        mov     [y1], ax


        mov      ax, [Screen.Height]
        neg     [y0]
        neg     [y1]
        add     [y0], ax
        add     [y1], ax
        mov      ax, [COEF]
        sub     [y0], ax
        sub     [y1], ax

        push    $0F
        push    [y1]
        push    [x1]
        push    [y0]
        push    [x0]
        call    PlotLine
        add     sp, 10
;=========third two============

        inc      [drawn]
        pop      cx
        dec      cx
        test     cx, cx
        jz       .eof
        push     cx
        jmp      .readlp
.eof:
        ret
endp
;=====================================================
;INPUT:
;
;OUTPUT:
;     DI - result (QWORD)
proc  ParseFileOfDoubles c uses si
locals
        chr      rb 1
        counter  dw 0
        isdotted db 0  ; _1_ case
endl
        ;open existings
        mov      ah, 3Dh
        mov      al, 0
        mov      dx, FName
        int      21h
        mov      [FHandle], ax

        xor      si, si         ;bStr w pointer
        lea      di, [vertices] ;vert table pointer
        mov      cx, [N]        ;LIMITER
.readlp:
        ;read cx bytes to buf
        mov      cx, 1
        mov      bx, [FHandle]
        mov      ah, 3Fh
        lea      dx, [chr]
        int      21h
        cmp      ax, 0         ;EOF
        jz       .eof
        cmp      [chr], '#'
        jz       .eof

        cmp      [chr], ' '
        jnz      .nextChar

        test     si, si
        jz       .readlp

        cmp      [counter], 2
        jnz       .parse
        mov      [counter], 0
        sub      di, 8
        jmp      .miss

.parse:
        ;cmp     [isdotted], 0
        ;jne      .with
        ;mov      byte[bStr + si], '.'
        ;mov      byte[bStr + si + 1], '0'
        ;add      si, 2
.with:
        ;count
        inc     [drawn]
        mov      byte[bStr + si], ' '
        mov      si, bStr
        call     ParseDoubleFromString
        inc      [counter]
.miss:
        mov      si, 0
        add      di, 8
        jmp      .readlp

.nextChar:
        cmp      byte[chr], '-'
        jz       .add
        cmp      byte[chr], '.'
        jz       .add
        cmp      byte[chr], '0'
        jl       .readlp
        cmp      byte[chr], '9'
        jg       .readlp
.add:
        mov      al, [chr]
        mov      byte[bStr+si], al
        inc      si
        jmp      .readlp
.eof:
        mov     [bStr], $77
        ret
endp
;=====================================================
;OUTPUT - DI
;
proc    GetFace  c uses bx cx dx
locals
        chr      rb 1
        ten      dw 10
endl
        xor      si, si
        xor      ax, ax
.readlp:
        ;read cx bytes to buf
        push     ax
        mov      cx, 1
        mov      bx, [FHandle]
        mov      ah, 3Fh
        lea      dx, [chr]
        int      21h
        cmp      ax, 0      ;EOF
        jz       .EOF
        cmp      [chr], '/'
        jne       .nextChar
.skiplp2:
        mov      cx, 1
        mov      bx, [FHandle]
        mov      ah, 3Fh
        lea      dx, [chr]
        int      21h
        cmp      [chr], ' '
        jz       .eof      ;EXIT
        jmp      .skiplp2
.nextChar:
        pop      ax
        cmp      byte[chr], '0'
        jl       .readlp
        cmp      byte[chr], '9'
        jg       .readlp
.add:
        xor      dx, dx
        imul     [ten]
        add      al, [chr]
        adc      ah, 0
        sub      ax, '0'
        jmp      .readlp
;==============================
.eof:
        pop      ax
        ret
endp

;=====================================================
;INPUT:
;     A - Real A addr (A from Obj File)
;     B - Width or Height
;OUTPUT:
;     AX - A to print
RefineView:
        push    bp
        mov     bp, sp
        push    bx

        sub     sp, 2
        mov     word[bp - 2], 2   ;scale factor

jmp .jmpp
        ;=====CORRECT=======
        mov     si, vertices
        mov     ax, 23
        mov     bx, 16
        mul     bx
        add     si, ax

        fld     qword[si]
        fld1
        faddp   st1, st
        fild    word[Screen.Width]
        fmulp   st1, st
        mov     word[b], 2
        fild    [b]
        fdivp   st1, st
        fistp   [b]
        ;=====CORRECT+======
.jmpp:
        fninit
        mov     bx, [bp + 4]
        fld     qword[bx]
        fist    [d]
        fld1
        faddp   st1, st
        fist    [d]
        fild    word[bp + 6]
        fist    [d]
        fmulp   st1, st
        fist    [d]
        fild    word[bp - 2]
        fist    [d]
        fdivp   st1, st
        fist    [d]
        fistp   word[bp - 2]
        mov     ax, [bp - 2]

        pop     bx
        mov     sp, bp
        pop     bp
ret
;=====================================================
;INPUT:
;     SI - string source (' ' terminated)
;OUTPUT:
;     DI - result
proc  ParseDoubleFromString c uses ax bx cx dx
locals
        sign db 0
        ten  dq 10.0
        dig  rw 1
endl
        xor  ax, ax
        xor  dx, dx
        cmp  byte[si], '-'
        jnz  .lp
        mov  [sign], 1
        inc  si
        mov  bx, 10
.lp:
        cmp  byte[si], '.'
        jnz  .continue

        jmp  .endofint

.continue:
        mov  cl, [si]
        sub  cl, '0'
        xor  dx, dx
        mul  bx
        add  al, cl
        adc  ah, 0
        inc  si
        loop .lp
.endofint:          ;AX - int part

.while:
        cmp byte[si], ' '
        jz  .realend
        inc si
        jmp .while
.realend:
        dec si
        fninit
        fldz
@@:
        cmp     byte[si], '.'
        jz      .end
        movzx   bx, byte[si]
        sub    bx, '0'
        mov     [dig], bx
        fild    [dig]
        faddp   st1, st
        fld    [ten]
        fdivp   st1, st
        dec     si
        jmp     @B
.end:
        mov     [dig], ax  ;int part
        fild    [dig]      ;1-int 2-real
        faddp   st1, st    ;int + real
        cmp     [sign], 0
        jz     .pos
        fchs
.pos:
        fst   qword[di]
.play:
        fmulp  st1, st
        fistp   [c]
        ret
endp


;==============================================

proc PlotCircle c uses ax bx cx dx si, \
        x0: WORD, y0: WORD, R: WORD, COLOR:WORD
locals
        x     rw 1
        y     rw 1
        delta rw 1
        error rw 1
endl
        mov   [x], 0
        push  [R]
        pop   [y]
        mov   ax, [R]
        mov   bx, -2
        imul  bx
        inc   ax
        mov   [delta], ax
        mov   [error], 0
.while:
        cmp   [y], 0
        jl    .end

        push  [COLOR]
        mov   ax, [y0]
        add   ax, [y]
        push  ax
        mov   ax, [x0]
        add   ax, [x]
        push  ax
        call  SetPixel
        add   sp, 6

        push  [COLOR]
        mov   ax, [y0]
        sub   ax, [y]
        push  ax
        mov   ax, [x0]
        add   ax, [x]
        push  ax
        call  SetPixel
        add   sp, 6

        push  [COLOR]
        mov   ax, [y0]
        add   ax, [y]
        push  ax
        mov   ax, [x0]
        sub   ax, [x]
        push  ax
        call  SetPixel
        add   sp, 6

        push  [COLOR]
        mov   ax, [y0]
        sub   ax, [y]
        push  ax
        mov   ax, [x0]
        sub   ax, [x]
        push  ax
        call  SetPixel
        add   sp, 6

        mov   ax, [delta]
        add   ax, [y]
        mov   bx, 2
        imul  bx
        dec   ax

        cmp   [delta], 0
        jnl   .next
        cmp   ax, 0
        jg    .next
        inc   [x]
        mov   ax, [x]
        mov   bx, 2
        imul  bx
        inc   ax
        add   [delta], ax
        jmp   .while
.next:
        mov   ax, [delta]
        sub   ax, [x]
        mov   bx, 2
        imul  bx
        dec   ax

        cmp  [delta], 0
        jng  .preend
        cmp  ax, 0
        jng  .preend
        dec  [y]
        mov  ax, [y]
        mov  bx, -2
        imul bx
        inc  ax
        add  [delta], ax
        jmp  .while
.preend:
        inc  [x]
        mov  ax, [x]
        sub  ax, [y]
        mov  bx, 2
        imul bx
        add  [delta], ax
        dec  [y]
        jmp  .while
.end:
        ret
endp
;==============================================

proc PlotFilledCircle c uses ax bx cx dx si, \
        x0: WORD, y0: WORD, R: WORD, COLOR:WORD
locals
        x           rw 1
        y           rw 1
        chY         rb 1
        delta       rw 1
        error       rw 1
endl
        mov   [x], 0
        push  [R]
        pop   [y]
        mov   [chY], 0
        mov   ax, [R]
        mov   bx, -2
        imul  bx
        inc   ax
        mov   [delta], ax
        mov   [error], 0
.while:
        cmp   [y], 0
        jl    .end


        push  [x]
        mov   cx, 1
        cmp   [chY], 1
        jnz    .lp
        mov   [chY], 0
        add   cx, [x]
.lp:
        push  [COLOR]
        mov   ax, [y0]
        add   ax, [y]
        push  ax
        mov   ax, [x0]
        add   ax, [x]
        push  ax
        call  SetPixel
        add   sp, 6

        push  [COLOR]
        mov   ax, [y0]
        sub   ax, [y]
        push  ax
        mov   ax, [x0]
        add   ax, [x]
        push  ax
        call  SetPixel
        add   sp, 6

        push  [COLOR]
        mov   ax, [y0]
        add   ax, [y]
        push  ax
        mov   ax, [x0]
        sub   ax, [x]
        push  ax
        call  SetPixel
        add   sp, 6

        push  [COLOR]
        mov   ax, [y0]
        sub   ax, [y]
        push  ax
        mov   ax, [x0]
        sub   ax, [x]
        push  ax
        call  SetPixel
        add   sp, 6

        dec   [x]
        loop  .lp

        pop   [x]

        mov   ax, [delta]
        add   ax, [y]
        mov   bx, 2
        imul  bx
        dec   ax

        cmp   [delta], 0
        jnl   .next
        cmp   ax, 0
        jg    .next
        inc   [x]
        mov   ax, [x]
        mov   bx, 2
        imul  bx
        inc   ax
        add   [delta], ax
        jmp   .while
.next:
        mov   ax, [delta]
        sub   ax, [x]
        mov   bx, 2
        imul  bx
        dec   ax

        cmp  [delta], 0
        jng  .preend
        cmp  ax, 0
        jng  .preend
        dec  [y]
        mov  [chY], 1
        mov  ax, [y]
        mov  bx, -2
        imul bx
        inc  ax
        add  [delta], ax
        jmp  .while
.preend:
        inc  [x]
        mov  ax, [x]
        sub  ax, [y]
        mov  bx, 2
        imul bx
        add  [delta], ax
        dec  [y]
        mov  [chY], 1
        jmp  .while
.end:
        ret
endp
;=========================================================
proc PlotLine c uses ax bx cx dx si, \
        x1: WORD, y1: WORD, x2: WORD, y2: WORD, COLOR:WORD
locals
     deltaX rw 1
     deltaY rw 1
     signX  rw 1
     signY  rw 1
     error  rw 1
endl
     cmp [x1], 0
     jl  .end
     cmp [x1], Screen.Width
     jge .end
     cmp [y1], 0
     jl .end
     cmp [y1], Screen.Height
     jge  .end

     cmp [x2], 0
     jl .end
     cmp [x2], Screen.Width
     jge  .end
     cmp [y2], 0
     jl .end
     cmp [y2], Screen.Height
     jge  .end
.plot:
     mov ax, [x2]
     sub ax, [x1]
     cmp ax, 0
     jng .signedX
     mov [signX], 1
     jmp @F
.signedX:
     mov [signX], -1
     neg ax
@@:
     mov [deltaX], ax
     mov ax, [y2]
     sub ax, [y1]
     cmp ax, 0
     jng  .signedY
     mov [signY], 1
     jmp @F
.signedY:
     mov [signY], -1
     neg ax
@@:
     mov [deltaY], ax
     neg [deltaY]

     mov  ax, [deltaX]
     add  ax, [deltaY]
     mov  [error], ax

     push [COLOR]
     push [y2]
     push [x2]
     call SetPixel
     add  sp, 6
.while:
     mov  ax, [x2]
     cmp [x1], ax
     jnz .continue
     mov ax, [y2]
     cmp [y1], ax
     jnz .continue
     jmp .end
.continue:
     push [COLOR]
     push [y1]
     push [x1]
     call SetPixel
     add  sp, 6

     mov  ax, [error]
     mov  bx, 2
     imul bx
     cmp  ax, [deltaY]
     jng  .next
     mov  bx, [deltaY]
     add  [error], bx
     mov  bx, [signX]
     add  [x1], bx
.next:
     cmp  ax, [deltaX]
     jnl  .while
     mov  bx, [deltaX]
     add  [error], bx
     mov  bx, [signY]
     add  [y1], bx
     jmp  .while
.end:
     ret
endp

SetPixel:
     push bp
     mov  bp, sp
     push ax
     push bx
     mov  ax, $0C08
     ;int 21h
     mov  ax, [bp + 6]
     mov  bx, 320
     imul bx
     add  ax,[bp + 4]
     mov  di, ax
     mov  ax, [bp + 8]
     mov  byte[es:di], al
     pop  bx
     pop  ax
     mov  sp, bp
     pop  bp
ret

Video.OldMode   db      ?
Video.OldPage   db      ?
bStr    rb  25
a       dq  -0.12785    ;3.541592653589793238643383279502
b       rw  1
c       dw  1000
e       dq  99.0
d       rw  1
FName   db 'e:\work\head.obj', 0
FHandle rw 1
tname        db 'e:\work\test.obj', 0
testbt       db '0.5 '
testans      rb 1
Screen.Width  dw  320
Screen.Height dw 200
vertices     dq  2516  dup(0)
N            dw  2516
drawn        dw  0
error        dw  0
COEF         dw  0