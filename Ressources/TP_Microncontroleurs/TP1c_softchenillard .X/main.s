PROCESSOR 18F25K40
#include <xc.inc>

; Configuration ================================================================
config FEXTOSC = OFF           
config RSTOSC = HFINTOSC_64MHZ 
config WDTE = OFF              
	
PSECT   code, abs

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
    ; Initialisation
    BANKSEL ANSELA
    bcf ANSELA, 6       
    bcf ANSELA, 7       
    BANKSEL TRISA
    bsf TRISA, 6        
    bsf TRISA, 7        
    
    clrf TRISC           ; LEDs LD0?LD7 en sortie

    clrf 0x20            ; compteur LSB
    clrf 0x21            ; compteur MSB
    
    movlw 0x01           ; motif chenillard : LED0
    movwf 0x22
    
    goto main
    
;====================================================================
main:

    ; Si BP1 pressé (RA6 = 0)
    btfss PORTA, 6
    goto loop

    ; Si BP0 pressé (RA7 = 0)
    btfss PORTA, 7
    goto loop

    ; Aucun bouton appuyé ? reste sur place
    goto main

;====================================================================
loop:
    ; Incrémente LSB
    addlw 1             
    bc addMSByte         ; si overflow ? gérer MSB

    ; Petit délai pour ralentir
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

    goto main

;====================================================================
High_ISR:
    retfie
    
Low_ISR:  
    retfie
    
;====================================================================
addMSByte:
    movf 0x21, W         
    addlw 1              
    movwf 0x21           

    ; si overflow MSB ? bouger chenillard
    bc moveChenilars      

    goto main

;====================================================================
moveChenilars:
    movf 0x22, W     

    ; BP1 pressé ? rotation à droite
    btfss PORTA, 6       
    rrncf 0x22          

    ; BP0 pressé ? rotation à gauche
    btfss PORTA, 7       
    rlncf 0x22           

    movff 0x22, LATC     ; afficher LEDs

    goto main

end

