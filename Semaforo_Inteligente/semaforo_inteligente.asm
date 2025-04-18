;
;	Programa Semâforo Inteligente
;	Alisson Rodrigues e Nathiele
;
;


;	Registradores utilizados
;	TMOD,TCON,TH0,TL0,IE,IP,PSW,ACC,DTPR
;	PORTS Utilizadas
;	P0 = Display de sete Segmentos
;	P3 = Interrupções externas
;	P1.0 Led verde
;	P1.1 Led Amarela
;	P1.2 Led vermelha
;	P1.3 - P1.6 Digitos display
;	Registradores de uso geral utilizados
;	R0 = Contador Ms
;	R1 = Unidade timer
;	R2 = Dezena Timer
;	R3 = Modo do semâforo(Verde,Amarelo,Vermelho)
;	R4 = Quantidade de veiculos
;	Configuração inicial
	ORG 0000H	; Começa do endereço 0h
	LJMP INICIO	; Salta para a label Inicio

;	Endereços de mémorias reservados para as interrupções

; |----- Salta para posição de mémoria da INT0 -----|
	ORG 0003h;
	NOP;
	RETI		; retorna para instrução de parada
	
; |----- Salta para posição de mémoria da TIMER0 -----|
	ORG 000Bh	 ;
	LCALL INTRP_TIMER; Trocar led
	RETI		 ; retorna para instrução de parada
	
; |----- Salta para posição de mémoria da INT1 -----|
	ORG 0013h	;
	NOP		; 
	RETI		; retorna para instrução de parada
; |----- Salta para posição de mémoria da 01Bh -----|
	ORG 001Bh	;

INICIO:
	MOV	DPTR,#BANCO	; Move o endereço base do BANCO para DTPR
	MOV  R4,#0d		; Inicia R4 com o valor 0
	LCALL   CONF_INTERP	; Configura as interrupções
	LCALL	ATIVA_LED_VERDE	; Ativa sinal verde
	ACALL CONF_TIMER_1	; Configura o timer para 1s
	SETB TR0		; Inicia a temporização

PRINCIPAL:
	; verifica se R0 é maior que 10;
	MOV A,R0	; Carrega em A o valor de R0
	MOV B,#10d	; Carrega o valor 10 em B
	DIV AB		; Divide A por B

	MOV R1,B	;
	MOV R2,A	;
	;MOV A,#00000111B;
	;ORL A,P1	; Apaga Digitos do display
	;MOV P1,A	; Move o resultado da AND para P1

	SETB P1.3;
	SETB P1.4;
	SETB P1.5;
	SETB P1.6;
	; Digito 0
	MOV A,R1	; Carrega no Acumulador o valor de unidades no timer
	MOVC A,@A+DPTR	; Carrega em A o valor no endereço deslocado no banco
	MOV P0,A	; Carrega o valor nos segmentos
	CLR P1.3	; Ativa Digito 0
	CALL	DELAY	;
	
	; Digito 1
	SETB P1.3	; Desativa o digito 0
	MOV A,R2	; Carrega no Acumulador o valor de unidades no timer
	MOVC A,@A+DPTR	; Carrega em A o valor no endereço deslocado no banco
	MOV P0,A	; Carrega o valor nos segmentos
	CLR P1.4	; Ativa Digito 1
	CALL	DELAY	;
	
	; Digito 3
	SETB P1.4	; Desativa o digito 1
	MOV A,R4	; Carrega no Acumulador o valor de unidades no timer
	MOVC A,@A+DPTR	; Carrega em A o valor no endereço deslocado no banco
	MOV P0,A	; Carrega o valor nos segmentos
	CLR P1.6	; Ativa Digito 1
	CALL	DELAY	;
	
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

DELAY:
	NOP	;
	NOP	;
	NOP	;
	NOP	;
	NOP	;
	RET	;
;	Configura as interrupções para o programa
CONF_INTERP:
	MOV IE,#10010111b	; Ativa as interrupções externas 0 e 1 e do timer 0
	MOV IP,#00000101b	; Da prioridade para IT0 depois IT1 e depois  T0
	MOV TCON,#00000000b	; Configura as interrupções no modo de nivel
	RET;
;	Configura o timer para contar 10ms

;	troca o led aceso
INTRP_TIMER:
	DEC R0			; Decrementa R0
	MOV A,R0		; Move o contedo de R0 para ACC
	JZ  TROCAR_LED		; Salta Para trocar LED se o acumulador chegou em 0
INTRP_TIMER1:
	ACALL CONF_TIMER_1	; Configura o timer para 1s
	SETB TR0		; Inicia a temporização
	RET
;	Verifica qual o modo atual e troca para o proximo
TROCAR_LED:
	MOV A,R3		; Move para o Acumulador o valor de R3(modo do sinal)
	JZ AUX1			; Se R3 era igual a 0 então o sinal estava verde
	DEC A			; Decrementa o acumulador
	JZ AUX2			; Se R3 era igual a 1 então o sinal estava amarelo
	; Se A não possuia 0 ou 1 então só pode ser 2
	ACALL	AUX3	; Ativa led verde
	RET			; Retorna a chamada da subrotina
;	AUX1 ativa a led amarela
AUX1:
	ACALL ATIVA_LED_AMARELA	; Chama a rotina para ativar led amarela
	AJMP INTRP_TIMER1	; Continua tratamento da interrupção
;	AUX2 ativa a led vermelha
AUX2:
	ACALL ATIVA_LED_VERMELHA; Chama a rotina para ativar ler amarela
	AJMP INTRP_TIMER1	; Continua tratamento da interrupção
AUX3:
	ACALL ATIVA_LED_VERDE; Chama a rotina para ativar led verde
	AJMP INTRP_TIMER1	; Continua tratamento da interrupção
; Ativa led_verde;
ATIVA_LED_VERDE:
	MOV R3,#0d		; Move o valor 0 para R3, com R3 em 0 indica que o lede verde está ativo
	;ACALL CONF_TIMER_1	; Configura o timer para 1s
	MOV R0,#10d		; Carrega R0 com 10
	;SETB TR0		; Inicia a temporização
	MOV P1,#0FFh		; Apaga todas LEds da P1
	CLR P1.0		; Ativa Led verde
	RET			; Retorna para função que chamou a subrotina

; Ativa led_amarela;
ATIVA_LED_AMARELA:
	MOV R3,#1d		; Move o valor 1 para R3, com R3 em 1 indica que o led amarelo está ativo
	;ACALL CONF_TIMER_1	; Configura o timer para 1s
	MOV R0,#3d		; Carrega R0 com 3
	;SETB TR0		; Inicia a temporização
	MOV P1,#0FFh		; Apaga todas LEds da P1
	CLR P1.1		; Ativa Led Amarela
	RET			; Retorna para função que chamou a subrotina

; Ativa led_vermelha;
ATIVA_LED_VERMELHA:
	MOV R3,#2d		; Move o valor 2 para R3, com R3 em 2 indica que o led vermelho está ativo
	;ACALL CONF_TIMER_1	; Configura o timer para 1ms
	MOV R0,#7d		; Carrega R0 com 7
	;SETB TR0		; Inicia a temporização
	MOV P1,#0FFh		; Apaga todas LEds da P1
	CLR P1.2		; Ativa Led vermelha
	RET			; Retorna para função que chamou a subrotina
		
CONF_TIMER_1:
	; Para contar 1ms o timer deve contar 1 milpulsos
	; O timer é iniciado com 64536d em hexa FC18
	MOV TMOD,#00001001b	; Configura o timer 0 no modo de timer 16 bits com interrupção
	MOV TH0,#0FCh		; Carrega THIGH0 com os bits mais significativos 
	MOV TL0,#018h		; Carrga TLOW0 com os bits menos significativos
	RET;

	END;