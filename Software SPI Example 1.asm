;
; Assembly Software SPI example For Attiny13.asm
;
; Created: 27-12-2022 16:46:01
; Author : PeetGaming
;
;PB0 = CLK
;PB1 = MOSI
;PB2 = Latch
;
;For this example I used a slow delay loop, but be free to replace it with faster delay loop.

.include "tn13def.inc"
.equ Data_byte = 0b01100100		; number of bytes in array
                   
init:
  	ldi r16, 0b00000111		; load bits for DDRB into r16    
  	out DDRB, r16         		; Load r16 into DDRB

main:
	
	ldi r21, 8			; Inial SPI loop bit counter for sending byte  
	ldi r22, 0			; variable for shift function

	ldi r20, Data_byte		; move byte to send into R20 
	rcall spi_loop			; call the spi loop

	rjmp main

spi_loop:		
	mov r22, r21			; Data_byte[i]
	ldi r20, Data_byte		; Load data into r20 that we use as send registers. 

	rcall shift_right		; Jump to shift_right loop. Shift right by N bits			
	andi r20, 1			; mask r16 & 1

	cpi r20, 1			; compare if the bit is high
	breq set_high			; if bit is 1 set pin high
	return1:			; Return label

	cpi r20, 0			; compare bit high or low in byte to send
	breq set_low			; if bit is 0 set pin low
	return2:			; Return label
	  
  	sbi PORTB, PB2              	; Clock HIGHG
 	rcall delay_1			; Delay    
  	cbi PORTB, PB2              	; clcok LOW
  	rcall delay_1			; Delay

	dec r21				; Decrease the bit counter
	cpi r21, 0			; Compare the bit counter, if counter is 0
	brne spi_loop			; If bit counter is not 0 jump back to SPI_loop label

	sbi PORTB, PB0      		; Latch pin HIGH
  	rcall delay_1			; call the delay loop
	cbi PORTB, PB0      		; Latch pin LOW
 	rcall delay_1			; call the delay loop  
	        
   	 rjmp main

shift_Right:
	lsr r20				; shift right
	inc r22				 
  cpi	r22, 8				; compare 
	brlo shift_Right		; jump if R22 is lower than 8
	ret	
	 		
set_high:
	sbi PORTB, PB1        		; Set HIGH
	rcall delay_1			; Call timer
	rjmp return1			; Jump back to main loop

set_low:					
  	cbi   PORTB, PB1      		; Set LOW
	rcall delay_1			; Call the timer
	rjmp  return2			; jump back to main loop

delay_1:				; The outer loop
    	ldi r16, 255        		; Initial the timers values
    	ldi r17, 255
    	ldi r18, 5
delay_i:				; The inner loop
   	dec  r16           		; dec r16 255 times, 255 x 1 cycle delay
   	brne delay_i			; branch if not equal to beginning of timerb
	dec  r17             		; if r16 is not equal that dec r17 255, 255 x 1 cycle delay
    	brne delay_i			; branch if not equal to beginning of timer2 - 1 clock * 256, then 1
   	dec  r18			; if r16 is 0 that dec r17 255, 255 x 1 cycle delay
    	brne delay_i        		; Branch if not equal to beginning of timer2 - 1 clock * 5, then 1
    	ret                 		; End after 256 * 256 * 5 = 327.680 cycles delay                                
