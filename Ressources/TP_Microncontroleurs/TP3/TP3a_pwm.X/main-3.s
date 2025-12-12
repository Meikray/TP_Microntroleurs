PROCESSOR 18F25K40
#include <xc.inc>

; --- Configuration du microcontrôleur ---
config FEXTOSC = OFF          ; Pas de source d'horloge externe
config RSTOSC = HFINTOSC_64MHZ ; Horloge interne de 64 MHz (Fosc)
config WDTE = OFF             ; Désactiver le Watchdog Timer

PSECT code, abs

; --- Vecteurs de Reset et d'Interruption ---
org 0x000                     
    goto init_system          

org 0x008                     
    goto High_ISR

org 0x018                     
    goto Low_ISR


org 0x100

init_system:
    call Init_PORTS_PWM ; Configuration des broches pour le PWM
    call Init_Timer2_PWM; Configuration du Timer2 pour la PWM 
    call Init_PWM3 ; Configuration du module PWM3 
    
    goto loop                 

Init_PORTS_PWM:
    
    movlw 0x07 
    BANKSEL RC0PPS; Sélectionne la banque du registre RC0PPS
    movwf RC0PPS 
    
   
    BANKSEL TRISC; Sélectionne la banque du registre TRISC
    bcf TRISC, 0 ; Configure RC0 en sortie 
    
    
    bcf TRISC, 1; RC1 en sortie
    bcf LATC, 1
    return

Init_Timer2_PWM:
    
    BANKSEL T2CLKCON
    movlw 0x01; Source d'horloge pour Timer2 : Fosc/4 
    movwf T2CLKCON

    BANKSEL T2CON
    movlw 0b11011111; TMR2ON=1, Prescaler 1:32, Postscaler 1:16
    movwf T2CON            
    
    BANKSEL T2PR
    movlw 0b11111001; PR2 = 249 
    movwf T2PR	 
    return

Init_PWM3:
    
    BANKSEL PWM3DCH
    movlw 0b00110010          
    movwf PWM3DCH             
    
    BANKSEL PWM3CON
    movlw 0b10000000; PWM3EN=1 
    movwf PWM3CON; Écrit la configuration
    
    return

loop:
    goto loop                 

High_ISR:
    retfie

Low_ISR:
    retfie
    
end