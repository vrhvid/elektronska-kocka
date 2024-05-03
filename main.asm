;
; projekt_koda.asm
;
; Created: 23.2.2017 21:13:36
; Author : Vid
;SPREMEMBE:koda napisana za �ip Attiny13A; ta verzija je kon�na!
/*uporabljeni so pini:pin2(PB3, vhod), pin3(PB4, izhod), pin5(PB0, izhod), pin6(PB1, izhod), pin7(PB2, izhod)
/****INICIALIZACIJA**INICIALIZACIJA**INICIALIZACIJA**INICIALIZACIJA**INICIALIZACIJA**INICIALIZACIJA**INICIALIZACIJA**INICIALIZACIJA**INICIALIZACIJA****/
    .include  "tn13adef.inc"
/******registra r16 in r17 sta �e zasedena!!!!!***/
	.def preverjanje_register = r16
	.def stetje_register = r17
	.def zakasnitev = r18
	.def i_register = r19
	
	.CSEG

;
; ***************************************
;      Reset and Interrupt-Vectors
; ***************************************
;

    .ORG 0x0000
	rjmp zacetek ; Reset
	reti ; INT0 Interrupt
	reti ; PCINT0
	reti ; TIM1_COMPA
	reti ; TIM1_OVF
	reti ; TIM0_OVF 
	reti ; EE_RDY
	reti ; ANA_COMP
	reti ; ADC
	reti ; TIM1_COMPB
	reti ; TIM0_COMPA
	reti ; TIM0_COMPB
	reti ; WDT
	reti ; USI_START 
	reti ; USI _OVF

	

zacetek:
    ldi r31, low(RAMEND)
	out spl, r31
    
	cli
;***************************************************************************************************************************
;vse pine razen pina 4 definiramo kot izhode;pin 4 definiramo kot vhod in postavimo pull-up upor****************************
;***************************************************************************************************************************
	ldi r20, 0b00001000
	out PORTB, r20
	ldi r20, 0b11110111      
	out DDRB, r20          
	 
	nop
	           
/*pri�gemo vse lu�ke*/
    sbi PORTB, 0      
	sbi PORTB, 1
	sbi PORTB, 2
	sbi PORTB, 4

	ldi zakasnitev, 0x64     ;50x ponovimo 100ms zakasnitev
    rcall deset_milisekunde

/*ugasnemo vse lu�ke*/
	cbi PORTB, 0
	cbi PORTB, 1
	cbi PORTB, 2
	cbi PORTB, 4
	nop
	nop
	nop

/****DEBUNCING********************************************************************************************************************************************************/
odvzemanje:
    ldi zakasnitev, 0x01
	rcall deset_milisekunde

	in i_register, pinb          ;v r20 nalo�imo vrednost iz pina
	sbrc i_register, 3           ;preverimo, ali je vrednost na pinu 0(ali je gumb pritisnjen)
	rjmp odvzemanje

	ldi zakasnitev, 0x01
	rcall deset_milisekunde

	in i_register, pinb          ;v r20 nalo�imo vrednost iz pina
	sbrc i_register, 3           ;preverimo, ali je vrednost na pinu 0(ali je gumb pritisnjen)
	rjmp odvzemanje
	
	
/*********************************************************************************************************************************************************************/
	ldi stetje_register, 0x01
	 
 stetje:
    rcall preverjanje                    ;pokli�emo na preverjanje, ali je gumb �e vedno pritisnjen
	cpi preverjanje_register, 0x00       ;preverimo, ali je gumb �e vedno pritisnjen
	breq output1                          ;�e ugotovimo,da gumb ni ve� pritisnjen, potem sku�imo na pri�iganje LED diod
	inc stetje_register                  ;�e je gumb �e vedno pritisnjen, potem registru,v katerem �elimo dobiti naklju�no �tevilo med 1 in 6, pri�tejemo 1 
	cpi stetje_register, 0x07            ;�e gumb �e vedno ni spu��en, potem preverimo, ali je vrednost registra, v katerem �tejemo, enaka 6
	brne stetje                          ;�e ni enaka 6, potem se vrnemo na za�etek podprograma
	ldi stetje_register, 0x01                  ;�e je vrednost registra 6, potem ga postavimo na 1
	rjmp stetje                          ;vrnemo se na za�etek podprograma

/****************************************************************************************************************************************/

output1:
    cpi stetje_register, 0x01      ;preverimo ali je naklju�no �tevilo 1
	brne output2                   ;�e ni, sko�imo na preverjanje za naslednje �tevilo
	sbi PORTB, 0
	ldi zakasnitev, 0xFF
	rcall deset_milisekunde
	cbi PORTB, 0
	rjmp odvzemanje

output2:
    cpi stetje_register, 0x02
	brne output3
	sbi PORTB, 2
	ldi zakasnitev, 0xFF
	rcall deset_milisekunde
	cbi PORTB, 2
	rjmp odvzemanje

output3:
    cpi stetje_register, 0x03
	brne output4
	sbi PORTB, 0
	sbi PORTB, 2
	ldi zakasnitev, 0xFF
	rcall deset_milisekunde
	cbi PORTB, 0	
	cbi PORTB, 2
	rjmp odvzemanje

output4:
    cpi stetje_register, 0x04
	brne output5
	sbi PORTB, 1
	sbi PORTB, 2
	ldi zakasnitev, 0xFF
	rcall deset_milisekunde
	cbi PORTB, 1
	cbi PORTB, 2
	rjmp odvzemanje

output5:
    cpi stetje_register, 0x05
	brne output6
    sbi PORTB, 0
    sbi PORTB, 1
    sbi PORTB, 2
	ldi zakasnitev, 0xFF
	rcall deset_milisekunde
    cbi PORTB, 0
    cbi PORTB, 1
    cbi PORTB, 2
	rjmp odvzemanje

output6:
    sbi PORTB, 1
    sbi PORTB, 2
    sbi PORTB, 4
	ldi zakasnitev, 0xFF
	rcall deset_milisekunde
	cbi PORTB, 1
    cbi PORTB, 2
    cbi PORTB, 4
	rjmp odvzemanje

/*********************************************************************************************************************************************************************/
preverjanje:
    clr preverjanje_register
	in i_register, pinb          ;v r20 nalo�imo vrednost iz pina
	sbrc i_register, 3           ;preverimo, ali je vrednost na pinu 0(ali je gumb pritisnjen)
	ret
	ldi preverjanje_register, 0x01
	ret

/****NESKONCNA_ZANKA**100ms*******************************************************************************************/
deset_milisekunde:  
;------------------------------------------------------------
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
;---------------------------------------------------
nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
;---------------------------------------------------
nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
;---------------------------------------------------
nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
;---------------------------------------------------
nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
;---------------------------------------------------
    dec zakasnitev
	breq loop_ret
	rjmp deset_milisekunde

loop_ret:
	ret










