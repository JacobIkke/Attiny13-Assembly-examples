; ASM PWM V1.asm
;
; Created: 29-12-2022 22:10:57
; Author : PeetGaming
;

.def temp = r20
.def PWM = r21

init:
  	ldi temp, 0b0000001	                    ; load bit for PB0 into r20
  	out DDRB, temp                              ; PB0 as output
  	ldi temp, 1<<COM0A1 | 1<<WGM01 | 1<<WGM00   ; PWM setup for OCR0A 
  	out TCCR0A, temp
  	ldi temp, 1<<CS01
  	out TCCR0B, temp

main:
 	out OCR0A, PWM
	inc PWM
	rcall delay1
	rjmp main

delay1:				; The outer loop
    	ldi r16, 255         	; Initial the timers values
    	ldi r17, 255
    	ldi r18, 1
delay_i:			; The inner loop
    	dec  r16            	; dec r16 255 times, 255 x 1 cycle delay
    	brne delay_i		; branch if not equal to beginning of timerb
    	dec  r17            	; if r16 is not equal that dec r17 255, 255 x 1 cycle delay
    	brne delay_i		; branch if not equal to beginning of timer2 - 1 clock * 256, then 1
    	dec  r18		; if r16 is 0 that dec r17 255, 255 x 1 cycle delay
    	brne delay_i       	 ; Branch if not equal to beginning of timer2 - 1 clock * 5, then 1
    	ret  
