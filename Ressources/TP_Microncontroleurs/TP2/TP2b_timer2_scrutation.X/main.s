PROCESSOR 18F25K40
#include <xc.inc>

; Configuration ================================================================
config FEXTOSC = OFF           ; Pas de source d'horloge externe
config RSTOSC = HFINTOSC_64MHZ ; Horloge interne de 64 MHz
config WDTE = OFF              ; Desactiver le watchdog    timer
    
PSECT   code, abs
 ;Après configuration du Timer 2 et test à l?oscilloscope sur la  LED_MATRIX,
; j?ai mesuré une période de 20 microsecondes, ce qui correspond bien au résultat attendu.
; Table des I/O ================================================================
; LED LED0 à la pin RC0
   
   LED_PORT equ 0x20
 
   
; Vecteur de reset =============================================================
org     0x000

init:
    call Init_MATRIX     ; Appelle la routine pour configurer LED_MATRIX
    call init_2          ; Appelle la routine d'initialisation du Timer 2
   
 
Init_MATRIX:
    BANKSEL TRISB 
    bcf     TRISB,4      ; Met la broche RB4 en sortie (LED_MATRIX)
    
    
init_2:

    BANKSEL T2PR
    movlw   0            
    movwf   T2PR         ; Charge PR2

    BANKSEL T2CON
    movlw   0b10000000   ; Active le Timer2 
    addlw   0b01010000   ; Configure le prescaler
    addlw   0b00000100   ; Configure le postscaler
    movwf   T2CON        

    BANKSEL T2CLKCON
    movlw   0b00000001   ;Choisit la source du Timer2 : Fosc/4
    movwf   T2CLKCON     

    BANKSEL PIR4
    bcf     PIR4, 1      ;Efface le flag TMR2IF (évènement Timer2)

    goto loop            ;Va voir la boucle principale

 
main:
    
loop:

    BANKSEL PIR4         ;Accède à PIR4
    btfss   PIR4,1       
    goto loop            ;RecommenceR la boucle si la boucle ne marche pas

    bcf     PIR4,1       ;Effacer le flag TMR2IFsi la boucle marche

    BANKSEL LATB         
    btg     LATB,4       

    goto main            ;Retourne au début du programme

end



