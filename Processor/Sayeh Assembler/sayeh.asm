.data fill 0 0 0 0

.data data	0xa79f 0xeb5b 0x90bc 0xb418 0xb7bf 0xea4a 0xfd9d 0x0d2d  \
			0x258a 0xa6bb 0x982d 0x284b 0x57d0 0xb3a1 0xd76c 0xd21b  \
			0x8867 0xe69a 0xc1c0 0x513d 0x9c58 0xc49c 0x07ac 0xe06d  \
			0x536d 0x1f6d 0x2948 0x7b18 0x7de8 0xee34 0x83ef 0xd60c  \
			0x3426 0x4a42 0xb9cf 0xbf25 0xfd9a 0xe5bb 0x104a 0xb6b1  \
			0xfb5b 0xa4c9 0xceb6 0x48eb 0x09ac 0x1ce3 0xe2a6 0x1ef9  \
			0x0345 0x63cf
;;;;;;;;;;;;;
	; r0: pointer to input
	; r1: pointer ro output
	; r2: op1
	; r3: temp


	mil r0, data
	mih r0, 0

	mil r3, 50+3	; output will be at 3 locations after input finishes
	mih r3, 0

	mvr r1, r0
	ccf
	add r1, r3		; r1 points to output

loop:
	mil r3, 1
	mih r3, 0
	;ccf
	add r3, r0		; r3 point to op2
	lda r2, r3
	lda r3, r0
	;ccf
	add r2, r3

	sta r1, r2

	mil r3, 1
	mih r3, 0
	ccf
	add r0, r3		; increment r0
	add r1, r3		; increment r1

	mil r2, data
	mih r2, 0
	mil r3, 50
	add r2, r3		; r2: input before last

	czf
	cmp r0, r2
jmp:
	brz end-jmp
	mil r3, 0
	mih r3, 0
	jpa r3, loop
end:
	hlt
