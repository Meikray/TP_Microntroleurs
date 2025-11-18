PROCESSOR 18F25K40
#include <xc.inc>

; Configuration ================================================================
config FEXTOSC = OFF           ; Pas de source d'horloge externe
config RSTOSC = HFINTOSC_64MHZ ; Horloge interne de 64 MHz
config WDTE = OFF              ; Desactiver le watchdog	timer
Compteur_Lo equ 0x20
Compteur_Hi equ 0x21
TEMP1 equ 0x22
PSECT   code, abs
   
 ; Je veux que tu allumes LED0  
 ; PIN RC0/ANC0
 ; Je veux que tu allumes LED1  
 ; PIN RC1/ANC1/CCP2
 ; Je veux que tu allumes LED2  
 ; PIN RC2/ANC2/CCP1
 ; Je veux que tu allumes LED3  
 ; PIN RC3/ANC3/SCK1/SCL1
 ; Je veux que tu allumes LED4  
 ; PIN RC4/ANC4/SDI1/SDA1
 ; Je veux que tu allumes LED5  
 ; PIN RC5/ANC5
 ; Je veux que tu allumes LED6  
 ; PIN RC6/ANC6/TX1
 ; Je veux que tu allumes LED7  
 ; PIN RC7/ANC7/RX1
 
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
  init:
    ; Configurer les PORTC en sortie
    clrf    TRISC
    ; Effacer sortie
    clrf    LATC
    ; Initialiser les deux compteurs
    clrf    Compteur_Lo
    clrf    Compteur_Hi

loop:
    ; Incrémenter 16 bits
    incf    Compteur_Lo, F
    btfss   STATUS, 2          ; Test du flag Z (bit 2 du registre STATUS)
    goto    Display
    incf    Compteur_Hi, F

Display:
    ; Affichage du poids fort sur LEDs
    movf    Compteur_Hi, W
    movwf   LATC

    ; Délai logiciel
    movlw   0xFF
    movwf   TEMP1

DelayLoop:
    decfsz  TEMP1, F
    goto    DelayLoop
    goto    loop

; Routines d'interruption ======================================================    
High_ISR:
    retfie
    
Low_ISR:  
    retfie
     
end