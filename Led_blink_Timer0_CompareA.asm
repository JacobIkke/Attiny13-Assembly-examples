;
; ASM timer TIM0_COMPA v1.asm
;
; Created: 21-1-2023 17:08:37
; Author : @PeetGaming (Peethobby)
;

.include "tn13def.inc" ; Include ATtiny13 definitions

.org 0x000
;Interrupt Vectors
.org	0x000 rjmp SETUP		; Reset Handler
;.org	0x001 rjmp EXT_INT0		; IRQ0 Handler
;.org	0x002 rjmp PCINT0
; .org	0x003 rjmp TIM0_OVF		; Timer0 Overflow Handler
;.org	0x004 rjmp EE_RDY
;.org	0x005 rjmp ANA_COMP		; Analog Comparator Handler
.org	0x006 rjmp TIM0_COMPA		; Timer0 CompareA Handler
;.org	0x007 rjmp TIM0_COMPB		; Timer0 CompareB Handler
;.org	0x008 rjmp WATCHDOG		; Watchdog Interrupt Handler
;.org	0x009 rjmp ADC			; ADC Conversion Handler

.org 0x00A
; Program starts at 0x00A
.def counter = r20
.def tmp = r16

SETUP:
    	ldi tmp, 0b00001111			; Set pins as output
    	out DDRB, tmp				; load r16 into DDRB	
	ldi tmp, 0b00001111			; Set pins as high or low
    	out PORTB, tmp				; load r16 into PORTB	

    	LDI tmp, (1<<COM0A1) | (1<<WGM01)	; 0b0100_0010 Set CTC mode
	OUT TCCR0A,tmp

	LDI tmp, (1<<CS02) | (1<<CS00)		; Set the prescaler to 1024       
	OUT TCCR0B,tmp        

	LDI tmp, (1 << OCIE0A)			; Enable Timer0 Compare A Interupt
	out TIMSK0, tmp

	ldi tmp, 255				; Set the valu to timer
	out OCR0A, tmp				; load tmp into OCR0A
	sei					; Enable global Interupts

; Main code loop
main:	
	; Your code goes her
	rjmp main

; ISR Interupt
TIM0_COMPA:
	push r16		; Save the registers, but not counter.
	push r17

	inc counter		; Increment the counter
   	cpi counter, 5		; If counter == xxx
    	breq reset		; If counter equal(counter == xxx) jump to reset:

	end:
	pop r17			; Restore the registers
	pop r16
    	reti

; Reset counter and Toggle the state of PB1
reset:
    	ldi counter, 0x00	; Toggle the state of PB1
    	in r16, PORTB		; Read the current state of PORTB into r16
    	ldi r17, (1<<PB1)   	; Load the value for PB1 into r17
    	eor r16, r17		; Toggle the state of PB1 in r16
   	out PORTB, r16		; Write the updated value of r16 back to PORTB
    	rjmp end		; Jump back to ISR and finish the interupt. 

