;
;	Programa Timer modo 0
;	Cria um contador de 10 ms com o timer no modo 1
;	Alison Rodigues de C santos
;	Nathiele 

;	Registradores utilizados
;	TCON e TMOD
;	TH0 e TL1
;	Registrador TMOD
;	0000 1001	9h
;	Registrador Tcon
;	0000 0000	0h;
;	Registradores TL0 e TH0
;	D8h EFh

; |----- Configuração inicial -------|
	org 0000h		;
	mov acc,#0d		;
	ljmp conf_timer		;	Pula para a labgel inicio
; --------------------------------------------------------
;	Área de tratamento de interrupções

; |----- Salta para posição de mémoria da 0Bh -----|
	org 000Bh	;
	mov acc,#10d	;
	reti

; |----- Salta para posição de mémoria da 0B1h -----|
	org 00B1h	;
	reti		;
; Ativa as interrupções e configura o timer
conf_timer:
	mov ie,#10000010b	; ativa as interrupções	
	mov tmod,#00001001b	; configura o registrador do modo de timer
	mov tcon,#0h		; configura o registrador tcon	
	mov th0,#0D8h		; carrega THIGH0 com os bits mais significativos
	mov tl0,#0EFh		; carrega TLOW0 com os bits menos significativos
	ljmp ativar_timer	; Ativa o timer

; 	rotina pricipal
;	Executa um laço enquanto o timer não dispara
inicio:
	CJNE a,#0d,fim	;
	sjmp inicio;

;	Ativa o timer
ativar_timer:
	setb tr0	;
	ljmp inicio	;
;	Desativa o timer
desativar_timer:
	clr TR0		;
	ljmp inicio	;

;	Segura o programa
fim:
	sjmp fim	; segura o programa
	end		;