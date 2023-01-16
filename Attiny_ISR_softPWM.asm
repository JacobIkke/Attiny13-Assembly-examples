;
; Created: 15-1-2023 18:23:27
; Author : Peetgaming
;
.include "tn13def.inc"

.equ pin_red = PB0				; PWM pins 
.equ pin_green = PB1				; PWM pins 
.equ pin_blue = PB2				; PWM pins 

.def red_pwm = r19				; Register to store PWM value
.def green_pwm = r20				; Register to store PWM value
.def blue_pwm = r21				; Register to store PWM value

.def counter = r22

;Interrupt Vectors, see datasheet
.org	0x000 rjmp RESET 			; Reset Handler
;.org	0x001 rjmp EXT_INT0 			; IRQ0 Handler
;.org	0x002 rjmp PCINT0
.org	0x003 rjmp TIM0_OVF 			; Timer0 Overflow Handler
;.org	0x004 rjmp EE_RDY
;.org	0x005 rjmp ANA_COMP 			; Analog Comparator Handler
;.org	0x006 rjmp TIM0_COMPA 			; Timer0 CompareA Handler
;.org	0x007 rjmp TIM0_COMPB 			; Timer0 CompareB Handler
;.org	0x008 rjmp WATCHDOG 			; Watchdog Interrupt Handler
;.org	0x009 rjmp ADC 				; ADC Conversion Handler


.org 0x00A 					
;Settup/init
RESET: 
    	ldi r16, 0b00011111;			; Set RGB pins as output
    	out DDRB, r16				; Set initial color		
	ldi r16, 0b00011111			; Set RGB pins as output
    	out PORTB, r16				; Set initial color											
    	ldi r16, (1 << CS00)			; Load bit CS00 for TCCR0B into r16 
   	out TCCR0B, r16				; Set Timer0 for overflow interrupt
    	ldi r16, (1 << TOIE0)			; load bit for TOIE0 register into r16
    	out TIMSK0, r16				; set TIMSK0 
    	sei					; Enable interrupts
						
	ldi green_pwm, 255			; Main loop starts with green dec, so we preload green with 255

;main program
main_loop:

	red_to_green:
		rcall delay_loop		; Call the delay routine, short delay
		inc red_pwm			; Increase channel red
		dec green_pwm			; Decrease channel green
		cpi green_pwm, 0		; Check if green is 0
		brne red_to_green		; If green is 0, if it is 0 than jump to next color loop

	green_to_blue:
		rcall delay_loop		; Call the delay routine, short delay
		inc blue_pwm			; Increase channel blue
		dec red_pwm			; Decrease channel red
		cpi red_pwm, 0			; Check if red is 0
		brne green_to_blue		; if red is 0, if it is 0 than jump to next color loop

	blue_to_green:
		rcall delay_loop		; Call the delay routine, short delay
		inc green_pwm			; Increase channel green
		dec blue_pwm			; decrease channel blue
		cpi blue_pwm, 0			; Check if blue is 0
		brne blue_to_green		; if green is 0, if it is 0 than jump to next color loop

	rjmp main_loop				; jump back to main loop, ininity loop

;Delay loop
delay_loop:					; The outer loop
    ldi r23,255                 		; Initial the timers values
    ldi r24,64
inner_loop:					; The inner loop
    dec r23                     		; Dec r16 255 times, 255 x 64 cycle delay
    brne inner_loop				; Branch if not equal to beginning of timerb
dec r24                     			; If r23 is not equal that dec r24
    brne inner_loop				; Branch if not equal 
    ret                         		; End after 255 * 64 cycles 

;Interrupt Service Routines
TIM0_OVF:		
	push red_pwm				; save the  registers
	push green_pwm				
	push blue_pwm

 	red:
		cp counter, red_pwm		; Compare the counter with duty 	
		brlo red_off			; if counter is lower than red_pwm jump to green, led stays on for now
		sbi PORTB, PB0			; Turn PB0 on (red)
		rjmp green			; Jump to label green
	red_off:
		cbi PORTB, PB0			; Turn off red LED

	green:
		cp counter, green_pwm
		brlo green_off			; if the counter is lower than green_pwm then jump to blue, led stays on for now
		sbi PORTB, pin_green		; Turn on green LED
		rjmp blue			; Jump to label blue
	green_off:
		cbi PORTB, pin_green		; Turn off green LED
	
	blue:
		cp counter, blue_pwm  
		brlo blue_off			; If the counter is lower than blue_pwm then jump to end, led stays on for now
		sbi PORTB, pin_blue		; Turn on blue LED
		rjmp end_compare		; Jump to label end
	blue_off:
		cbi PORTB, pin_blue		; Turn off blue LED

	end_compare:

    inc counter					; Counter++
    cpi counter, 0xFF				; Compare PWM counter 
    breq reset_counter				; If equal branch to reset:  ;reset = load counter with 0x00
	
	end:
	pop blue_pwm				; restore the registers
	pop green_pwm
	pop red_pwm
    reti					; End Interrupt Service Routines

reset_counter:					; Reset the counter
	ldi r22, 0x00				; Load counter with 0x00
	rjmp end				; jump back to end or ISR
