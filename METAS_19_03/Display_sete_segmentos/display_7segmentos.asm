;
;	Programa Contagem 0 a 9 display de 7 segmentos
;	utiliza um banco para salvar os valores dos digitos para os segmentos
;	acessa o banco utilizando o dptrs
;	Alisson R C Santos
;	Nathiele 

; --- Vetor de RESET ---
        org     0000h           ;
        mov     r0,#0d          ;
        mov     dptr,#banco     ;

; --- Rotina Principal ---
princ:
        mov     a,r0            ;Move o conteúdo de r0 para o acc
        movc    a,@a+dptr       ;Move o byte relativo de dptr somado
                                ;com o valor de acc para o acc
        mov     p0,a            ;Move o conteúdo de acc para Port0
        inc     r0              ;Incrementa r0
        cjne    r0,#10d,princ    ;Compara r0 com 0 e pula se não for igual
        ajmp    $               ;Segura o código nesta linha

; --- Banco ---
banco:
        db      0C0h             ;
        db      0F9h             ;
        db      0A4h             ;
        db      0B0h             ;
        db      099h             ;
        db      092h             ;
        db      082h             ;
        db      0F8h             ;
        db      080h             ;
        db      090h             ;

        end                     ;Final do Programa