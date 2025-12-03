PROCESSOR 18F25K40
#include <xc.inc>
   
PSECT   code, abs
 ;Après configuration du Timer 2 et test à l?oscilloscope sur la  LED_MATRIX,
; j'ai mesuré une période de 20 microsecondes, ce qui correspond bien au résultat attendu.
; Table des I/O ================================================================
; LED LED0 à la pin RC0
 
; Vecteur de reset =============================================================
org     0x000
goto init 
     
; Vecteur d'interruption haute priorite ========================================
org     0x008
goto High_ISR 

; Vecteur d'interruption basse priorite ========================================
org     0x018
goto Low_ISR    
   
; Programme principal ==========================================================
org 0x100   
  
; J'observe bien un signal rectangulaire rapide avec une fréquence de 50 khz
; Le signal est périodique
 
init:
    call Init_MATRIX     ; Appelle la routine pour configurer LED_MATRIX
    call init_2          ; Appelle la routine d'initialisation du Timer 2
    call init_inter      ; Appelle la routine d'initialisation des interruptions
    
     goto loop           

   
loop: 
    
    goto loop            ; Retourne au début du programme
    
    
  
 
Init_MATRIX:
    BANKSEL TRISB 
    bcf     TRISB,5      ; Mettre RB5 en sortie (LED_MATRIX)
    return
   
 ;Creation d'une routine d'initialisation du Timer 2 telle qui expire toutes les 10 µs

init_2:

    BANKSEL T2PR
    movlw   0x00            
    movwf   T2PR         ; Charge PR2

    BANKSEL T2CON
    movlw   0b10000000   ; Active le Timer2 
    addlw   0b01010000   ; Configure le prescaler
    addlw   0b00000100   ; Configure le postscaler
    movwf   T2CON        
    
    
    BANKSEL T2CLKCON
    movlw   0b00000001   ;Choisit la source du Timer2 : Fosc/4
    movwf   T2CLKCON     

    return
  
init_inter:
    BANKSEL PIE4
    movlw 0b00000010   ;TMR2IE = 1 (bit 1 de PIE4). Active l'interruption du Timer 2.
    movwf PIE4 
    
    BANKSEL INTCON 
    movlw 0b10100000   ; on enable IPEN et les hautes interrupts
    movwf INTCON
    
    BANKSEL IPR4
    movlw 0b00000010   ;TMR2IP = 1 (bit 1 de IPR4). Définit l'interruption TMR2 en HAUTE PRIORITY.
    movwf IPR4
    
    return 
 


    ; Routines d'interruption ======================================================    
High_ISR:
    BANKSEL PIR4 ; Vérifier si l'interruption vient de TMR2IF
    btfsc PIR4, 1
  
    BANKSEL LATB ; Inverse l'état logique de la broche RB5
    btg LATB,5 
    
    retfie      ; Retour de l'interruption
    
 Low_ISR:  
    retfie

   
end  
    
  
   
    




