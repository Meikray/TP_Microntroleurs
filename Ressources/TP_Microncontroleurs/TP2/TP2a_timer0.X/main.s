PROCESSOR 18F25K40
#include <xc.inc>

; Configuration ================================================================
config FEXTOSC = OFF           ; Pas de source d'horloge externe
config RSTOSC = HFINTOSC_64MHZ ; Horloge interne de 64 MHz
config WDTE = OFF              ; Desactiver le watchdog    timer
    
PSECT   code, abs
   
 
   
; Vecteur de reset =============================================================
org     0x000

; Programme principal ==========================================================
org 0x100   

;   Configuration du Timer0
;   Overflow ? 0,5 seconde

init:
    
    BANKSEL TRISB          ; Sélection du registre TRISB
    bcf     TRISB,4        ; Met RB4 en sortie

    movlw   0b01001111     ; Configuration du Timer0 : Fosc/4 + prescaler
    BANKSEL T0CON1         ; Sélection du registre T0CON1
    movwf   T0CON1         ; Charge la configuration dans T0CON1

    
    movlw   0b11000000     ; Active Timer0 en mode 8 bits + postcaler
    BANKSEL T0CON0         
    movwf   T0CON0         ; Active Timer0

    goto loop              ; Va à la boucle principale


main:
    
loop:

    BANKSEL PIR0           ; Sélection du registre PIR0
    btfss   PIR0,5         ; Test si le flag Timer0 (TMR0IF) est à 1
    goto loop              ; Retourne au début de la boucle si sa ne marche pas

    bcf     PIR0,5         ; effacer le flag TMR0IF si sa marche

    BANKSEL LATB           ; Sélection du registre LATB
    btg     LATB,4         ; Inverse l'état de la LED sur RB4 (toggle)

    goto main              ; Retour au début du programme (boucle continue)

end