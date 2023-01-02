;
; ASM read input pins.asm
;
; Created: 28-12-2022 20:41:09
; Author : PeterGaming
;

.include "tn13def.inc"

init_gpio:
    ldi r16, 0b00000011			; load bit for PB3 into r16    
    out DDRB, r16               ; PB3 as output
	ldi r16, 0b00010000	
	out PORTB, r16

main:
    sbi PORTB, PB1              ; Heart beat HIGH
    rcall delay_long			; Delay
    cbi PORTB, PB1              ; Heart beat LOW
	rcall delay_long			; Delay

	in r20, PINB				; Read pins of port B
	ldi r19, 4					; N of shifts
	rcall shift_right			; Shift left by N time stored in r19
	andi r20, 1					; Mask, & 1

	cpi	r20, 1					; compare if PB4 is 1 (not pushed)
	breq set_high				; if cpi is 1 jump to set_high
	return1:					; a return label

	cpi	r20,  0					; compare if PB4 is 0 (pushed)
	breq set_low				; if cpi is 0 jump to set_low
	return2:					; a return label

	rjmp main					; jump back to label main


set_high:
	sbi PORTB, PB0              ; Set HIGH
	rcall delay_long			; Call the delay function
	rjmp return1				; Jump back to main loop

set_low:				
    cbi PORTB, PB0              ; Set LOW
	rcall delay_long			; Call the delay function
	rjmp return2				; jump back to main loop

shift_right:
	lsr r20						; shift by x times number in r16
	dec r19						; if r16 is not equal that dec
    brne shift_right	
	ret

delay_long:						; The outer loop
    ldi r16,255                 ; Initial the timers values
    ldi r17,255
    ldi r18,5
delay_i:						; The inner loop
    dec r16                     ; dec r16 255 times, 255 x 1 cycle delay
    brne delay_i				; branch if not equal to beginning of timerb
	dec r17                     ; if r16 is not equal that dec r17 255, 255 x 1 cycle delay
    brne delay_i				; branch if not equal to beginning of timer2 - 1 clock * 256, then 1
    dec r18						; if r16 is 0 that dec r17 255, 255 x 1 cycle delay
    brne delay_i                ; Branch if not equal to beginning of timer2 - 1 clock * 5, then 1
    ret                         ; End after 256 * 256 * 5 cycles delay  
