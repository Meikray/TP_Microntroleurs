PROCESSOR 18F25K40          
#include <xc.inc>           


    config FEXTOSC = OFF    
    config RSTOSC  = HFINTOSC_64MHZ 
    config WDTE    = OFF   


compteur_1 equ 0x20          ; Définit 'compteur_1' à l'adresse 0x20
Limit_C equ 0x21             ; Définit 'Limit_C' (seuil du compteur) à l'adresse 0x21


PSECT code, abs             



org 0x000                    
    goto init_system         

org 0x008                    
    goto High_ISR            

org 0x018                    
    goto Low_ISR             


;Routines d'Initialisation 

org 0x100                   

init_system:                 ; Routine principale d'initialisation
    call Init_PORTS          
    call Init_Timer0         ; Appelle la routine pour configurer le Timer 0
    call Init_Timer2         ; Appelle la routine pour configurer le Timer 2
    call Init_Variables      ; Appelle la routine pour initialiser les compteurs
    call Init_Interrupts     

    goto wait                ;


Init_PORTS:
    
    BANKSEL TRISC            
    clrf TRISC               
    BANKSEL LATC             
    movlw 0x01               ; Charge la valeur 0x01 dans W
    movwf LATC               ; Écrit 0x01 dans LATC 

    ; Configuration de la broche LED de clignotement
    BANKSEL TRISB            
    bcf TRISB, 4             ; Configure la led RB4 en sortie 
    return                   ; Retour 

Init_Variables:
    movlw 0x19               ; Charge la valeur hexadécimale 0x19 
    movwf Limit_C            
    clrf compteur_1          ; Initialisation du compteur à zéro
    return                    


Init_Timer0:; Configuration du Timer 0  pour un clignotement lent
    BANKSEL T0CON0           
    movlw 0b10010000 ; Active TMR0 et le met en mode 16 bits 
    movwf T0CON0             
    
    BANKSEL T0CON1           
    movlw 0b01001111 ; Configure Fosc/4 et le Prescaler
    movwf T0CON1             
    
    
    BANKSEL TMR0H            
    movlw 0xFF               
    movwf TMR0H	                                        
    return                   


Init_Timer2: ; Configuration du Timer 2 (Haute priorité) pour la base de temps rapide
    BANKSEL T2CON ; Sélectionne la banque du registre T2CON
    movlw 0b11011001 ; Active TMR2 et le Prescaler et le Postscaler 
    movwf T2CON              
    
    BANKSEL T2CLKCON ; Sélectionne la banque de T2CLKCON
    movlw 0b00000001 ; Sélectionne Fosc/4 comme source d'horloge
    movwf T2CLKCON           
    
    BANKSEL T2PR; Sélectionne la banque de T2PR 
    movlw 0b11111001 ; PR2 = 249 
    movwf T2PR	             
    return                 


Init_Interrupts:
    
    BANKSEL IPR4; Sélectionne la banque IPR4 
    movlw 0b00000010         
    movwf IPR4               
    
    BANKSEL IPR0 ; Sélectionne la banque IPR0
    movlw 0x00   ; TMR0 est en Basse Priorité 
    movwf IPR0              
    
  
    BANKSEL PIE4 ; Sélectionne la banque PIE4 
    movlw 0b00000010 ; Active TMR2IE 
    movwf PIE4              
    
    BANKSEL PIE0; Sélectionne la banque PIE0
    movlw 0b00100000 ; Active TMR0IE 
    movwf PIE0             
    
    ; Activation globale
    BANKSEL INTCON           
    movlw 0b11100000        
    movwf INTCON          
    return                  


wait:                        
    goto wait                



; Routines de Service d'Interruption (ISR)


High_ISR:
    
    BANKSEL PIR4    
    btfss PIR4, 1 ; Teste TMR2IF Si le bit est à 1, saute la ligne suivante
    goto end_high ; Si le bit est à 0 l'interruption n'est pas pour nous

    bcf PIR4, 1              

   
    INCF compteur_1 , F ; Incrémente le compteur logiciel 
    
    movf compteur_1 , W ; Charge la valeur du compteur dans le registre W
    CPFSEQ Limit_C ; Compare W à Limit_C. Si W est égal à 1 la ligne suivante est SAUTÉE
    goto end_high  ; Si W n'es égal à 0 on attend la prochaine interruption
    
    
    BANKSEL LATC             
    rlncf LATC, F            
    
    clrf compteur_1 ; Réinitialise le compteur logiciel à zéro
    
end_high:
    retfie                   


Low_ISR:
   
    BANKSEL PIR0            
    btfss PIR0, 5            
    goto end_low            

    bcf PIR0, 5              

    
    BANKSEL TMR0H            
    movlw 0xFF               
    movwf TMR0H              
    movlw 0x13              
    movwf TMR0L             


    BANKSEL LATB             
    btg LATB, 4              

end_low:
    retfie ; Retour d'interruption 

end