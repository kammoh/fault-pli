;;;;;;;;;;;;;;;;;
;               ;
;  SAYEH   ASM  ;
;               ;
;;;;;;;;;;;;;;;;;

;.set var 123

.data myvar 0 1 2 f 2 2

start:   ; let's go
begin:
	nop

	szf
	scf

	;sta r1, r2

; syntax is
; op <dest> <, source> <, immediate>

	;r0 is the counter
	sub r0, r0 		; set r0 to zero
	mil r0, 50		; set lsb of r0 to number of elements

	lda r1, r0		; load first summation operand into r1
loop:
	mih r3, 0
	mil r3, 1
	ccf				; make sure no carry
	add r0, r3		; increment pointer (r0)
	lda r2, r0		; load second sum operand into r2

	ccf				; clear carry
	add r1, r2		; actual summation

	sta r3,r1

	mih r3, 0
	mil r3, 0
	jpa r3, loop

	hlt


