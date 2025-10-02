;
; clockupdate.asm: ECE 266 Lab 3 Starter code, fall 2024
;
; Assembly code for updating the 7-seg to show a running clock.
;
; Created by Zhao Zhang
;

; include C header file
			.cdecls "clockupdate.h"
			.text

; Declaration fields (pointers) to seg7 and ClockUpdate
_seg7 .field seg7
_ClockUpdate .field ClockUpdate

;************************************************************************************
; Task 1: Update the clock
;
; C prototype: void ClockUpdate(uint32_t time)
;
; This is the ClockUpdate callback function in assembly. It replaces the
; same function in your lab2_main.c.
;
; This is the STARTER CODE. At this time it only flashes the colon of the 7-seg.
; Complete the code so that it updates all the four clock digits.
;************************************************************************************
			.global ClockUpdate
			.asmfunc
ClockUpdate
	PUSH {LR, r0} ; push return address and event
	; check seg7.colon_on and turn it on/off
	LDR r0, _seg7 ; load the address of seg7 to r0
	LDRB r1, [r0, #4] ; r1 = seg7.colon_on
	CMP r1, #0 ; compare r1 and 0
	BEQ turn_on_colon ; if the colon is turned off, jump to the code turning it on
	MOVS r1, #0 ; now the colon must have been turned on, so turn it off
	STRB r1, [r0, #4] ; store 0 to seg7.colon_on
	B update_seg7_and_return ; jump to return

turn_on_colon
	MOV r1, #1 ; r1 = 1
	STRB r1, [r0, #4] ; store 1 to seg7.colon_on

;**************************************************************
; YOUR CODE STARTS HERE
;**************************************************************
update_digits
	; r0 = &seg7
	; seg7.digit[0]++
	LDRB r1, [r0] ; r1 = seg7.digit[0]
	ADDS r1, #1
	CMP r1, #10
	BNE store_digit0
	; if == 10 reset to 0
	MOVS r1, #0
	STRB r1, [r0] ; seg7.digit[0] = 0

	; seg7.digit[1]++
	LDRB r2, [r0, #1]
	ADDS r2, #1
	CMP r2, #6
	BNE store_digit1
	MOVS r2, #0
	STRB r2, [r0, #1]

	; seg7.digit[2]++
	LDRB r3, [r0, #2]
	ADDS r3, #1
	CMP r3, #10
	BNE store_digit2
	MOVS r3, #0
	STRB r3, [r0, #2]

	; seg7.digit[3]++
	LDRB r4, [r0, #3]
	ADDS r4, #1
	CMP r4, #6
	BNE store_digit3
	; reset whole clock if 60 minutes reached
	MOVS r1, #0
	STRB r1, [r0] ; seg7.digit[0] = 0
	STRB r1, [r0, #1] ; seg7.digit[1] = 0
	STRB r1, [r0, #2] ; seg7.digit[2] = 0
	STRB r1, [r0, #3] ; seg7.digit[3] = 0
	B update_seg7_and_return

store_digit3
	STRB r4, [r0, #3]
	B update_seg7_and_return

store_digit2
	STRB r3, [r0, #2]
	B update_seg7_and_return

store_digit1
	STRB r2, [r0, #1]
	B update_seg7_and_return

store_digit0
	STRB r1, [r0]

;**************************************************************
; YOUR CODE ENDS HERE
;**************************************************************

update_seg7_and_return
	; Physically update the 7-seg
	; Call Seg7Update(&seg)
	BL Seg7Update ; note that r0 = &seg7 at this time

	; Schedule a callback after 0.5 seconds:
	; Call ScheduleCallback(event, event->time + 500);
	POP {r0} ; restore event and time
	LDR r1, [r0, #8] ; r1 = event->time
	ADD r1, #500 ; time += 500
	BL EventSchedule

	POP {PC} ; return
	.end
