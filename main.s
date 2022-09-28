@------------------------------------------------------------------------------@
@ ________________UNIVERSIDADE ESTADUAL DE FEIRA DE SANTANA____________________@
@ ________________PROBLEMA 1 - TEC499- MI SISTEMAS DIGITAIS____________________@
@ -----CÓDIGO PARA REALIZAR CONTAGEM NO DISPLAY LCD COM USO DE BOTOES PARA-----@ 
@ ---------REALIZAR AÇÕES 1 PARA INICIAR/PAUSE E 1 RESTART --------------------@
@ SEMESTRE 2022.2
@ AUTORES - ALANA SAMPAIO PINTO, TÁSSIO CARVALHO RODRIGUES
@Trechos do código tirados do livro ARM "Processor Coding—Stephen Smith" e colegas da turma TP04

@ declaração de constantes
.equ setregoffset, 28   @ OFF SET DO SET DO REGISTRADOR
.equ clrregoffset, 40   @ OFF SET DO CLEAR DO REGISTRADOR
.equ map_shared, 1      @ LIBERAR COMPARTILHAMENTO DE MEMÓRIA (PARA NÃO SER DE USO EXCLUSIVO)
.equ sys_open, 5        @ SYSCALL DE ABERTURA E POSSIBILIDADE DE CRIAR ARQUIVO
.equ sys_map, 192       @ SYSCALL DO SISTEMA LINUX PARA MAPEAMENTO DE MEMÓRIA (GERA ENDEREÇO VIRTUAL)
.equ nano_sleep, 162    @SYSCALL DO SISTEMA LINUX PARA REALIZAR UMA "PAUSA" NA EXECUÇAO DO PROGRAMA
.equ level, 0x034       @VALOR DO PIN LEVEL DOS REGISTRADORES DE 0-31

@------chamada das bibliotecas------@
.include "move.s"
.include "contador.s"
.include "clear.s"
.include "display.s"
.include "gpiomap.s"
.global _start

@----------------Macro da nano sleep de 1s para o contador----------@
.macro nanoSleep1s time1s
        LDR R0,=second  @adiciona o valor da variavel second
        LDR R1,=\time1s @paramentro da macro
        MOV R7, #nano_sleep
        SVC 0
.endm


@--------------------Macro que chama a saida dos pino----------------@
.macro setOut
        GPIODirectionOut pinE      @chamando a macro de saida para o pino Enable
        GPIODirectionOut pin25rs   @chamando a macro de saida para o pino Enable
        GPIODirectionOut pin21d7   @chamando a macro de saida para o pino Enable
        GPIODirectionOut pin20d6   @chamando a macro de saida para o pino Enable
        GPIODirectionOut pin16d5   @chamando a macro de saida para o pino Enable
        GPIODirectionOut pin12d4   @chamando a macro de saida para o pino Enable
        .ltorg
.endm

@------------INICIANDO O MAPEAMENTO DA MEMÓRIA NO START---------------@
        
        mapeamento                  @Chama macro de mapeamento encontra-se no gpiomap.s


        setOut                      @Chama a macro de saida dos pinos
        Init                        @Chama a macro que inicializa o display LCD
        EntryModeSet                @Chamaa a macro que realiza o entryModeSet do LCD

        MOV R13, #4         @movendo o valor x no r13 que foi definido como registrador de decimal
        MOV R4, #9          @movendo o valor x no r4 que foi definido como registrador de unidade
        @---------------Trecho que escreve no LCD Aperte o botão--------------@
        @----aviso ao ver por ex o digito MSB é -> 0.0.0.1 < -LSB-------------@ 
        ClearDisplay        @macro de limpar display
        
        aperte

        contador @chama a macro do arquivo "contador.s"
end:
        MOV R7, #1
        SVC 0

.data
second: .word 1 @definindo 1 segundo no nanosleep
timenano: .word 0000000000 @definindo o milisegundos para o segundo passar no nanosleep
timespecnano1s: .word 999999999 @valor para delay de contador
fileName: .asciz "/dev/mem"
pin6:   .word 0                     @valores do pino do LED
        .word 18
        .word 6
pin26:  .word 8                     @word do pino do botão
        .word 18
        .word 67108864              @ 2^26 resulta nesse valor, em conversão a binário o 1 se encontra na vigesima sétima casa dos 32 bits
pinE:   .word 0                     @words do pino do enable do LCD
        .word 3
        .word 1
pin25rs:.word 8                     @words do pino rs do lcd
        .word 15
        .word 25
pin12d4:  .word 4                   @words do pino db4 do lcd
        .word 6
        .word 12
pin16d5:  .word 4                   @words do pino db5 do lcd
        .word 18
        .word 16
pin20d6:.word 8                     @word do pino db6 do lcd
        .word 0
        .word 20
pin21d7:  .word 8                   @word do pino db6 do lcd
        .word 3
        .word 21
pin19:  .word 4                     @word do pino db6 do lcd
        .word 27
        .word 524288                @2^19 resulta nesse valor, em conversão a binário o 1 se encontra na vigesima casa dos 32 bits