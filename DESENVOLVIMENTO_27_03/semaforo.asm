;
;	Programa Semâforo Inteligente
;	Alisson Rodrigues e Nathiele
;
;


;	Registradores utilizados
;	TMOD,TCON,TH0,TL0,IE,IP,PSW,ACC,DTPR
;	PORTS Utilizadas
;	P0 = Display de set Segmentos
;	P3 = Interrupções externas
;	P1.0 Led verde
;	P1.1 Led Amarela
;	P1.2 Led vermelha
;	Registradores de uso geral utilizados
;	R0 = Unidade timer
;	R1 = Dezena timer
;	R2 = Quantidade de veiculos
;	R3 = Modo do semâforo(Verde,Amarelo,Vermelho)

;	Configuração inicial
	ORG 0000H	; Começa do endereço 0h
	LJMP INICIO	; Salta para a label Inicio

;	Endereços de mémorias reservados para as interrupções

; |----- Salta para posição de mémoria da INT0 -----|
	ORG 0003h;
	NOP;
	RETI		; retorna para instrução de parada
; |----- Salta para posição de mémoria da TIMER0 -----|
	ORG 000Bh	;
	LCALL TROCAR_LED; Trocar led
	RETI		; retorna para instrução de parada
	
; |----- Salta para posição de mémoria da INT1 -----|
	ORG 0013h	;
	NOP		; 
	RETI		; retorna para instrução de parada
; |----- Salta para posição de mémoria da 01Bh -----|
	ORG 001Bh	;

INICIO:
	MOV	DPTR,#BANCO	; Move o endereço base do BANCO para DTPR
	LCALL   CONF_INTERP	; Configura as interrupções
	LCALL	ATIVA_LED_VERDE	; Ativa sinal verde

PRINCIPAL:
	NOP		;
	NOP		;
	NOP		;
	AJMP  PRINCIPAL	;
;	Banco com os valores para o display de sete segmentos	
BANCO:
	DB      0C0h             ; Numero 0
	DB      0F9h             ; Numero 1
        DB      0A4h             ; Numero 2
        DB      0B0h             ; Numero 3
        DB      099h             ; Numero 4
        DB      092h             ; Numero 5
        DB      082h             ; Numero 6
        DB      0F8h             ; Numero 7
        DB      080h             ; Numero 8
        DB      090h             ; Numero 9
        
;	Configura as interrupções para o programa
CONF_INTERP:
	MOV IE,#10010111b	; Ativa as interrupções externas 0 e 1 e do timer 0
	MOV IP,#00000101b	; Da prioridade para IT0 depois IT1 e depois  T0
	MOV TCON,#00000000b	; Configura as interrupções no modo de nivel
	RET;
;	Configura o timer para contar 10ms

;	troca o led aceso
TROCAR_LED:
	MOV A,R3		; Move o contedo de R3 para ACC
	JZ  AUX1		; Pula para aux1 se A estiver em 0
	; Se ACC possuir o valor 1
	DEC A			; Decrementa o ACC
	JZ AUX2			; Pula para aux2 se A estiver em 0
	; se não R3 não carregava nem 0 nem 1 então possui 2
	ACALL ATIVA_LED_VERDE	; Ativa lede verde
	RET

;	AUX1 ativa a led amarela
AUX1:
	ACALL ATIVA_LED_AMARELA	; Chama a rotina para ativar led amarela
	RET			; Retorna a chamada da subrotina
;	AUX2 ativa a led vermelha
AUX2:
	ACALL ATIVA_LED_VERMELHA; Chama a rotina para ativar ler amarela
	RET			; Retorna a chamada da subrotina
	
; Ativa led_verde;
ATIVA_LED_VERDE:
	MOV R3,#0d		; Move o valor 0 para R3, com R3 em 0 indica que o lede verde está ativo
	ACALL CONF_TIMER_10	; Configura o timer para 10ms
	SETB TR0		; Inicia a temporização
	MOV P1,#0FFh		; Apaga todas LEds da P1
	CLR P1.0		; Ativa Led verde
	RET			; Retorna para função que chamou a subrotina

; Ativa led_amarela;
ATIVA_LED_AMARELA:
	MOV R3,#1d		; Move o valor 1 para R3, com R3 em 1 indica que o led amarelo está ativo
	ACALL CONF_TIMER_3	; Configura o timer para 10ms
	SETB TR0		; Inicia a temporização
	MOV P1,#0FFh		; Apaga todas LEds da P1
	CLR P1.1		; Ativa Led Amarela
	RET			; Retorna para função que chamou a subrotina

; Ativa led_vermelha;
ATIVA_LED_VERMELHA:
	MOV R3,#2d		; Move o valor 2 para R3, com R3 em 2 indica que o led vermelho está ativo
	ACALL CONF_TIMER_7	; Configura o timer para 10ms
	SETB TR0		; Inicia a temporização
	MOV P1,#0FFh		; Apaga todas LEds da P1
	CLR P1.2		; Ativa Led vermelha
	RET			; Retorna para função que chamou a subrotina
		
CONF_TIMER_10:
	; Para contar 10ms o timer deve contar 10 milpulsos
	; O timer é iniciado com 55536d em hexa D8F0
	MOV TMOD,#00001001b	; Configura o timer 0 no modo de timer 16 bits com interrupção
	MOV TH0,#0D8h		; Carrega THIGH0 com os bits mais significativos 
	MOV TL0,#0F0h		; Carrga TLOW0 com os bits menos significativos
	RET;

;	Configura o timer para contar 7ms
CONF_TIMER_7:
	; Para contar 7ms o timer deve contar 7 mil pulsos
	; O timer é iniciado com 58536 em hexa E4A8
	MOV TMOD,#00001001b	; Configura o timer 0 no modo de timer 16 bits com interrupção
	MOV TH0,#0E4h		; Carrega THIGH0 com os bits mais significativos 
	MOV TL0,#0A8h		; Carrga TLOW0 com os bits menos significativos
	RET;

;	Configura o timer para contar 3ms
CONF_TIMER_3:
	; Para contar 3ms o timer deve contar 3 mil pulsos
	; O timer é iniciado com 62536 em hexa F448
	MOV TMOD,#00001001b	; Configura o timer 0 no modo de timer 16 bits com interrupção
	MOV TH0,#0F4h		; Carrega THIGH0 com os bits mais significativos 
	MOV TL0,#048h		; Carrga TLOW0 com os bits menos significativos
	RET;

;	Configura o timer para contar 3ms
CONF_TIMER_15:
	; Para contar 15ms o timer deve contar 15 mil pulsos
	; O timer é iniciado com 50536 em hexa D8F0
	MOV TMOD,#00001001b	; Configura o timer 0 no modo de timer 16 bits com interrupção
	MOV TH0,#0D8h		; Carrega THIGH0 com os bits mais significativos 
	MOV TL0,#0F0h		; Carrga TLOW0 com os bits menos significativos
	RET;

	END;