;
;	Programa interrupção externa
;	configura a interrupção externa no Port3.3 e POrt 3.2
;	Para incrementar e decrementar um botão
;	
;	Nathiele 
;
;	Registradores utilizados
;	Acc = acumula o valor do botão
;	IR =	Configura as interrupções
;	IP = 	Configura a prioridade da interrupção
;	TCON =	Configura o tipo de disparo
;	PSW.C = Utiliza o bit de carry para leitura do botão	
; -----	Configuração inicial	-----
;	
	org 0000h	; Endereço de inicio
	ljmp 23h;	; pula para área de inicio
; |----- Salta para posição de mémoria da INT0 -----|
	org 0003h;
	inc 	A	; incrementa Acc
	reti		; retorna para instrução de parada
; |----- Salta para posição de mémoria da INT1 -----|
	org 0013h;
	Dec	A	; 
	reti		; retorna para instrução de parada
; |----- Salta para posição de mémoria da 23h -----|
	org 0023h	;
conf_int:
	mov IE,#085h		; Move a constante 81h para IE ativando as interrupções e habilitando a interrupção EX0 e EX1
	mov IP,#05h		; Move a constante 5h para IP dando prioridade máxima para EX0 e EX1
	clr	IT0	; Limpa o bit IT0 configurando a interupção EX0 por nível
	clr	IT1	; Limpa o bit IT1 configurando a interupção EX1 por nível
inicio:
	; verifica se ocorreu a interrupção em IE0;
	mov 	c,IE0	;
	orl 	c,IE1	;
	jc  	conf_int	; Pula para rearmar as interrupções
	sjmp inicio;
	end;
	
