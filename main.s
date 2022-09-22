@------------------------------------------------------------------------------@
@ ________________UNIVERSIDADE ESTADUAL DE FEIRA DE SANTANA____________________@
@ ________________PROBLEMA 1 - TEC499- MI SISTEMAS DIGITAIS____________________@
@ -----CÓDIGO PARA REALIZAR CONTAGEM NO DISPLAY LCD COM USO DE BOTOES PARA-----@ 
@ ---------REALIZAR AÇÕES 1 PARA INICIAR/PAUSE E 1 RESTART --------------------@
@ SEMESTRE 2022.2
@ AUTORES - ALANA SAMPAIO PINTO, TÁSSIO CARVALHO RODRIGUES
@Trechos do código tirados do livro ARM "Processor Coding—Stephen Smith" e colegas da turma TP04

@ declaração de constantes
.equ pagelen, 4096      @ TAMANHO DA MEN 
.equ setregoffset, 28   @ OFF SET DO SET DO REGISTRADOR
.equ clrregoffset, 40   @ OFF SET DO CLEAR DO REGISTRADOR
.equ prot_read, 1       @ MODO DE LEITURA
.equ prot_write, 2      @ MODO DE ESCRITA
.equ map_shared, 1      @ LIBERAR COMPARTILHAMENTO DE MEMÓRIA (PARA NÃO SER DE USO EXCLUSIVO)
.equ sys_open, 5        @ SYSCALL DE ABERTURA E POSSIBILIDADE DE CRIAR ARQUIVO
.equ sys_map, 192       @ SYSCALL DO SISTEMA LINUX PARA MAPEAMENTO DE MEMÓRIA (GERA ENDEREÇO VIRTUAL)
.equ nano_sleep, 162    @SYSCALL DO SISTEMA LINUX PARA REALIZAR UMA "PAUSA" NA EXECUÇAO DO PROGRAMA
.equ level, 0x034       @VALOR DO PIN LEVEL DOS REGISTRADORES DE 0-31

.global _start

@----------------------Macro da nano sleep de ms--------------------@
.macro nanoSleep timespecnano
        LDR R0,=timespecsec @carrega o valor da variavel timespecsec
        LDR R1,=\timespecnano @paramentro da macro
        MOV R7, #nano_sleep
        SVC 0
.endm

@----------------Macro da nano sleep de 1s para o contador----------@
.macro nanoSleep1s time1s
        LDR R0,=second  @adiciona o valor da variavel second
        LDR R1,=\time1s @paramentro da macro
        MOV R7, #nano_sleep
        SVC 0
.endm

@------------------Macro que define a saída de um pino--------------@
.macro GPIODirectionOut pin
        LDR R2, =\pin   @pega o valor da base de dados dos pinos
        LDR R2, [R2]    @carregando o valor dos pinos
        LDR R1, [R8, R2]@endereço de memoria do registrador
        LDR R3, =\pin   @valor do endereço do pino
        ADD R3, #4      @ valor da quantidade de carga a ser deslocada
        LDR R3, [R3]    @carrega o valor do shift
        MOV R0, #0b111  @Mascara para limpar os 3 bits
        LSL R0, R3      @Muda a posiçao
        BIC R1, R0      @Realiza a limpeza dos 3 bits
        MOV R0, #1      @1 bit para realizar a mudança
        LSL R0, R3      @desloca para esquerda pelo valor da tabela
        ORR R1, R0      @defini o bit
        STR R1, [R8, R2]@salva o valor do registrador de memoria
.endm

@------------Macro que define se o pino ta on=1 ou off=0------------@
.macro GPIOValue pin, value
        MOV R0, #40     @valor do clear off set
        MOV R2, #12     @valor que ao subtrair o clear off set resulta 28 o set
        MOV R1, \value  @registra o valor 0 ou 1 no registrador
        MUL R5, R1, R2  @Ex r1 recebe o valor 1, ou seja multiplica o 12 do r2 por 1 resultando 12 no r5
        SUB R0, R0, R5  @valor do r5 que é 12 subtraido por 40 do r0 resultando 28 para o r0 ou seja o set do offset
        MOV R2, R8      @Endereço dos registradores da GPIO
        ADD R2, R2, R0  @adiciona no r2 o valor do set com o endereço dos regs
        MOV R0, #1      @ 1 bit para o shift
        LDR R3, =\pin   @valor dos endereços dos pinos
        ADD R3, #8      @ Adiciona offset para shift 
        LDR R3, [R3]    @carrega o shift da tabela
        LSL R0, R3      @realiza a mudança
        STR R0, [R2]    @Escreve no registro
.endm

@------------Macro que define que compara o pino do botão----------@
.macro GPIOReadRegister pin
        MOV R2, R8      @Endereço dos registradores da GPIO
        ADD R2, #level  @offset para acessar o registrador do pin level 0x34 
        LDR R2, [R2]    @ pino5, 19 e 26 ativos respectivamentes
        @00 000 100 000 010 000 000 000 000 100 000
        LDR R3, =\pin   @ base dos dados do pino
        ADD R3, #8      @ offset para acessar a terceira word
        LDR R3, [R3]    @ carrega a posiçao do pino -> 
        @ex queremos saber o valor do pino5 =2^5= 32 => 00 000 000 000 000 000 000 000 000 100 000
        AND R0, R2, R3  @ Filtrando os outros bits => 00 000 000 000 000 000 000 000 000 100 000
        @CMP R0, R3     @Compara r0 com r3, para saber se o pino esta ativo
        @BEQ _ligado    @Se R0 == r3, o pino está ativo
        @BNE _desligado @Se R0 != R3, o pino não esta ativo
.endm

@----Macro que define os valores dos pinos do LCD on=1 ou off=0----@
.macro setDisplay addrs, addb7, addb6, addb5, addb4
        GPIOValue pinE, #0             @define o valor do pino enable como 0
        GPIOValue pin25rs, #\addrs     @chama o parametro do pino rs
        GPIOValue pinE, #1             @define o valor do pino enable como 1
        GPIOValue pin21d7, #\addb7     @chama o parametro do pino db7
        GPIOValue pin20d6, #\addb6     @chama o parametro do pino db6
        GPIOValue pin16d5, #\addb5     @chama o parametro do pino db5
        GPIOValue pin12d4, #\addb4     @chama o parametro do pino db4
        GPIOValue pinE, #0             @define o valor do pino enable como 0
.endm

@------Macro que realiza a inicialização do LCD e o fuction set----@
.macro Init
        setDisplay 0, 0, 0, 1, 1   @define o db4=1; db5=1; db6=0; db7=0; rs=0
        nanoSleep timespecnano5    @realiza um delay de 5 milisegundos

        setDisplay 0, 0, 0, 1, 1   @define o db4=1; db5=1; db6=0; db7=0; rs=0
        nanoSleep timespecnano150  @realiza um delay de 15 milisegundos

        setDisplay  0, 0, 0, 1, 1  @define o db4=1; db5=1; db6=0; db7=0; rs=0


        setDisplay 0, 0, 0, 1, 0   @define o db4=0; db5=1; db6=0; db7=0; rs=0
        nanoSleep timespecnano150  @realiza um delay de 15 milisegundos

        .ltorg  @Programas grandes podem exigir vários pools literais. Coloque as diretivas LTORG após ramificações incondicionais ou instruções de retorno de sub-rotina para que o processador não tente executar as constantes como instruções.

        setDisplay 0, 0, 0, 1, 0  @define o db4=0; db5=1; db6=0; db7=0; rs=0

        setDisplay 0, 0, 0, 0, 0  @define o db4=0; db5=0; db6=0; db7=0; rs=0
        nanoSleep timespecnano150 @realiza um delay de 15 milisegundos

        setDisplay 0, 0, 0, 0, 0  @define o db4=0; db5=0; db6=0; db7=0; rs=0

        setDisplay 0, 1, 0, 0, 0  @define o db4=0; db5=0; db6=0; db7=1; rs=0
        nanoSleep timespecnano150 @realiza um delay de 15 milisegundos

        setDisplay 0, 0, 0, 0, 0  @define o db4=0; db5=0; db6=0; db7=0; rs=0

        setDisplay 0, 0, 0, 0, 1  @define o db4=1; db5=0; db6=0; db7=0; rs=0
        nanoSleep timespecnano150 @realiza um delay de 15 milisegundos

        setDisplay 0, 0, 0, 0, 0  @define o db4=0; db5=0; db6=0; db7=0; rs=0

        setDisplay 0, 0, 1, 1, 0  @define o db4=0; db5=1; db6=1; db7=0; rs=0
        nanoSleep timespecnano150 @realiza um delay de 15 milisegundos

        .ltorg @Programas grandes podem exigir vários pools literais. Coloque as diretivas LTORG após ramificações incondicionais ou instruções de retorno de sub-rotina para que o processador não tente executar as constantes como instruções.
.endm

@---------------Macro que realiza o entryModeSet do LCD-----------@

.macro EntryModeSet

        setDisplay 0, 0, 0, 0, 0  @define o db4=0; db5=0; db6=0; db7=0; rs=0
        setDisplay 0, 1, 1, 1, 0  @define o db4=0; db5=1; db6=1; db7=1; rs=0
        nanoSleep timespecnano150 @realiza um delay de 15 milisegundos

        setDisplay 0, 0, 0, 0, 0  @define o db4=0; db5=0; db6=0; db7=0; rs=0
        setDisplay 0, 0, 1, 1, 0  @define o db4=0; db5=1; db6=1; db7=0; rs=0
        nanoSleep timespecnano150 @realiza um delay de 15 milisegundos
        .ltorg  @Programas grandes podem exigir vários pools literais. Coloque as diretivas LTORG após ramificações incondicionais ou instruções de retorno de sub-rotina para que o processador não tente executar as constantes como instruções.
.endm

@---------------Macro que realiza a limpeza do LCD----------------@
.macro ClearDisplay
        setDisplay 0, 0, 0, 0, 0  @define o db4=0; db5=0; db6=0; db7=0; rs=0

        setDisplay 0, 0, 0, 0, 1  @define o db4=1; db5=0; db6=0; db7=0; rs=0
        nanoSleep timespecnano150 @realiza um delay de 15 milisegundos
.endm

@--Macro que irá distribuir valores de 0 e 1 para os pinos do LCD--@
.macro Numero valor
        GPIOValue pinE, #0    @define o valor do pino enable como 0
        GPIOValue pin25rs, #1 @define o valor do pino RS como 1
        GPIOValue pinE, #1    @define o valor do pino E como 1

        MOV R10, \valor       @r10 recebe o valor do decimal e é distribuido seus valores em binários nos pinos
        MOV R9, #1            @r9 recebe 0001 
        AND R11, R9, R10      @faz um and no r9 com r10, vamos supor que há uma and entre R9= 0001 AND R10 = 0100, R11 = 0000
                              @----aviso ao ver por ex o digito MSB é -> 0.0.0.1 < -LSB 
        MOV R0, #40           @valor do clear off set
        MOV R2, #12           @valor que ao subtrair o clear off set resulta 28 o set
        MOV R1, R11           @seguindo o exemplo de cima: r11 está com 0 que entra no R1
        MUL R5, R1, R2        @r2 = 12 x r1 = 0 resulta em 0 dentro do R5
        SUB R0, R0, R5        @r0= 40  - r5= 0 resulta em 40 dentro do R0
        MOV R2, R8            @Endereço dos registradores da GPIO
        ADD R2, R2, R0        @adiciona no r2 o valor do set =0 com o endereço dos regs
        MOV R0, #1            @ 1 bit para o shift
        LDR R3, =pin12d4      @valor do endereço do pino db4
        ADD R3, #8            @ Adiciona offset para shift
        LDR R3, [R3]          @carrega o shift da tabela
        LSL R0, R3            @realiza a mudança
        STR R0, [R2]          @Escreve no registro

                              @----aviso ao ver por ex o digito MSB é -> 0.0.0.1 < -LSB-------------@        
        LSL R9, #1            @usando o exemplo acima como antes o valor que estava em r9 era 0001 ele sofre um load shift para esquerda ficando 0010
        AND R11, R9, R10      @realizando um and de r9 = 0010 and R10 = 0100 resultará em 0000
        LSR R11, #1           @realiza um load shift a direita de 0000 mantendo-se o mesmo valor

        MOV R0, #40           @valor do clear off set
        MOV R2, #12           @valor que ao subtrair o clear off set resulta 28 o set
        MOV R1, R11           @seguindo os exemplos de cima: r11 está com 0 que entra no R1
        MUL R5, R1, R2        @r2 = 12 x r1 = 0 resulta em 0 dentro do R5
        SUB R0, R0, R5        @r0= 40  - r5= 0 resulta em 40 dentro do R0
        MOV R2, R8            @Endereço dos registradores da GPIO
        ADD R2, R2, R0        @adiciona no r2 o valor do set =0 com o endereço dos regs
        MOV R0, #1            @ 1 bit para o shift
        LDR R3, =pin16d5      @valor do endereço do pino db5
        ADD R3, #8            @ Adiciona offset para shift
        LDR R3, [R3]          @carrega o shift da tabela
        LSL R0, R3            @realiza a mudança
        STR R0, [R2]          @Escreve no registro

                              @----aviso ao ver por ex o digito MSB é -> 0.0.0.1 < -LSB-------------@  
        LSL R9, #1            @usando o exemplo acima como antes o valor que estava em r9 era 0010 ele sofre um load shift para esquerda ficando 0100
        AND R11, R9, R10      @realizando um and de r9 = 0100 and R10 = 0100 resultará em 0100
        LSR R11, #2           @realiza um load shift a direita de 0100 2 vezes resultando em 0001

        MOV R0, #40           @valor do clear off set
        MOV R2, #12           @valor que ao subtrair o clear off set resulta 28 o set
        MOV R1, R11           @seguindo os exemplos de cima: r11 está com 1 que entra no R1
        MUL R5, R1, R2        @r2 = 12 x r1 = 1 resulta em 12 dentro do R5
        SUB R0, R0, R5        @r0= 40  - r5= 12 resulta em 28 dentro do R0
        MOV R2, R8            @Endereço dos registradores da GPIO
        ADD R2, R2, R0        @adiciona no r2 o valor do set =1 com o endereço dos regs
        MOV R0, #1            @ 1 bit para o shift
        LDR R3, =pin20d6      @valor do endereço do pino db6
        ADD R3, #8            @Adiciona offset para shift
        LDR R3, [R3]          @carrega o shift da tabela
        LSL R0, R3            @realiza a mudança
        STR R0, [R2]          @Escreve no registro


        LSL R9, #1            @usando o exemplo acima como antes o valor que estava em r9 era 0100 ele sofre um load shift para esquerda ficando 1000
        AND R11, R9, R10      @realizando um and de r9 = 1000 and R10 = 0100 resultará em 0000
        LSR R11, #3           @realiza um load shift a direita de 0000 3 vezes resultando em 0000 no r11

        MOV R0, #40           @valor do clear off set
        MOV R2, #12           @valor que ao subtrair o clear off set resulta 28 o set
        MOV R1, R11           @seguindo os exemplos de cima: r11 está com 1 que entra no R1
        MUL R5, R1, R2        @r2 = 12 x r1 = 0 resulta em 0 dentro do R5
        SUB R0, R0, R5        @r0= 40  - r5= 0 resulta em 40 dentro do R0
        MOV R2, R8            @Endereço dos registradores da GPIO
        ADD R2, R2, R0        @adiciona no r2 o valor do set =0 com o endereço dos regs
        MOV R0, #1            @ 1 bit para o shift
        LDR R3, =pin21d7      @valor do endereço do pino db7
        ADD R3, #8            @ Adiciona offset para shift
        LDR R3, [R3]          @carrega o shift da tabela
        LSL R0, R3            @realiza a mudança
        STR R0, [R2]          @Escreve no registro

        GPIOValue pinE, #0    @define o valor do pino enable como 0
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
_start:
        LDR R0, = fileName          @Carrega a abertura do arquivo
        MOV R1, #0x1b0              @Leitura e Escrita do arquivo aberto valor que permite o direito de acesso
        ORR R1, #0x006              @Leitura e Escrita do arquivo aberto 
        MOV R2, R1                  @movendo r1 em r2
        MOV R7, #sys_open           @Syscall de abertura do arquivo
        SVC 0                       @Finaliza a chamada
        MOVS R4, R0                 @movendo o valor de r0 em r4

        LDR R5, =gpioaddr           @carrega o endereço base do GPIO
        LDR R5, [R5]                @ Carrega no registrador r5  o endereço base dos GPIO
        MOV R1, #pagelen            @Tamanho do arquivo
        MOV R2, #(prot_read + prot_write)        @movendo a soma do modo de leitura + modo de escrita 
        MOV R3, #map_shared         @opções de compartilhamento do arquivo
        MOV R0, #0                  @movendo o valor 0 no r0
        MOV R7, #sys_map            @ syscall do mmap2
        SVC 0                       @finaliza a sycall
        MOVS R8, R0                 @salvando o descritor do arquivo


        setOut                      @Chama a macro de saida dos pinos
        Init                        @Chama a macro que inicializa o display LCD
        EntryModeSet                @Chamaa a macro que realiza o entryModeSet do LCD

        MOV R13, #4         @movendo o valor x no r13 que foi definido como registrador de decimal
        MOV R4, #9          @movendo o valor x no r4 que foi definido como registrador de unidade
        @---------------Trecho que escreve no LCD Aperte o botão--------------@
        @----aviso ao ver por ex o digito MSB é -> 0.0.0.1 < -LSB-------------@ 
        ClearDisplay        @macro de limpar display
        setDisplay 1, 0, 1, 0, 0 @A    @define o db4=0; db5=0; db6=1; db7=0; rs=1
        Numero #1                      @Valor 0001 que representa o 'A' da tabela ascci do display em 4 bit na coluna 0100
        EntryModeSet                   @chamada da macro de entry mode Set pula para outra linha
        setDisplay 1, 0, 1, 1, 1 @p    @define o db4=1; db5=1; db6=1; db7=0; rs=1
        Numero #0                      @Valor 0000 que representa o 'p' da tabela ascci do display em 4 bit na coluna 0111
        EntryModeSet                   
        setDisplay 1, 0, 1, 1, 0 @e    @define o db4=0; db5=1; db6=1; db7=0; rs=1
        Numero #5                      @Valor 0101 que representa o 'e' da tabela ascci do display em 4 bit na coluna 0110
        EntryModeSet                   @chamada da macro de entry mode Set pula para outra linha para escrever
        setDisplay 1, 0, 1, 1, 1 @r    @define o db4=1; db5=1; db6=1; db7=0; rs=1
        Numero #2                      @Valor 0010 que representa o 'r' da tabela ascci do display em 4 bit na coluna 0111
        EntryModeSet                   
        setDisplay 1, 0, 1, 1, 1 @t    @define o db4=1; db5=1; db6=1; db7=0; rs=1
        Numero #4                      @Valor 0100 que representa o 't' da tabela ascci do display em 4 bit na coluna 0111
        EntryModeSet                   
        setDisplay 1, 0, 1, 1, 0 @e    @define o db4=0; db5=1; db6=1; db7=0; rs=1 
        Numero #5                      @Valor 0101 que representa o 'e' da tabela ascci do display em 4 bit na coluna 0110
        EntryModeSet                   
        setDisplay 1, 0, 0, 1, 0 @_    @define o db4=0; db5=1; db6=0; db7=0; rs=1 
        Numero #0                      @Valor 0000 que representa o ' ' da tabela ascci do display em 4 bit na coluna 0010
        EntryModeSet                   
        setDisplay 1, 0, 1, 1, 0 @o    @define o db4=0; db5=1; db6=1; db7=0; rs=1 
        Numero #15                     @Valor 1111 que representa o 'o' da tabela ascci do display em 4 bit na coluna 0110
        EntryModeSet                   
        setDisplay 1, 0, 0, 1, 0 @_    @define o db4=0; db5=1; db6=0; db7=0; rs=1 
        Numero #0                      @Valor 0000 que representa o ' ' da tabela ascci do display em 4 bit na coluna 0010
        EntryModeSet                   
        setDisplay 1, 0, 1, 1, 0 @b    @define o db4=0; db5=1; db6=1; db7=0; rs=1 
        Numero #2                      @Valor 0010 que representa o ' ' da tabela ascci do display em 4 bit na coluna 0110
        EntryModeSet
        setDisplay 1, 0, 1, 1, 0 @o    @define o db4=0; db5=1; db6=1; db7=0; rs=1
        Numero #15                     @Valor 1111 que representa o 'o' da tabela ascci do display em 4 bit na coluna 0110
        EntryModeSet
        setDisplay 1, 0, 1, 1, 1 @t    @define o db4=1; db5=1; db6=1; db7=0; rs=1
        Numero #4                      @Valor 0100 que representa o 't' da tabela ascci do display em 4 bit na coluna 0111
        EntryModeSet
        setDisplay 1, 1, 1, 1, 0 @ã    @define o db4=0; db5=1; db6=1; db7=1; rs=1
        Numero #1                      @Valor 0001 que representa o 'ä' da tabela ascci do display em 4 bit na coluna 1110
        EntryModeSet
        setDisplay 1, 0, 1, 1, 0 @o    @define o db4=0; db5=1; db6=1; db7=0; rs=1  
        Numero #15                     @Valor 1111 que representa o 'o' da tabela ascci do display em 4 bit na coluna 0110
        .ltorg

@-----------BOTÃO DO PINO 26 QUE IRÁ REALIZAR A INICIALIZAÇÃO DO CONTADOR-------@ 
check:
        GPIOReadRegister pin26         @Chamada da macro que define qual botão foi pressionado
        CMP R0, R3                     @Compara o valor de r0 com r3 onde está o endereço do pino
        BNE verificar                  @Se os valores de r0 e r3 forem diferentes o loop pula para o "verificar"
        B check                        @se forem iguais permanecem sempre no loop até que seja pressionado

@-------BOTÃO DO PINO 26 QUE IRÁ REALIZAR A PAUSA DO CONTADOR DETECTA CLICK-----@ 
check2:
        GPIOReadRegister pin26   @Detecta com mais precisão um click para o pause
        CMP R0, R3               @Compara o valor de r0 com r3 onde está o endereço do pino
        BNE verificar            @Se os valores de r0 e r3 forem diferentes o loop pula para o "verificar"
        B check3                 @se forem iguais simplesmente pula para o check3 mantendo-se em contagem

verificar:
        LDR R9, [R8, #level]     @carrega o valor lógico alto do botão dentro do r9
        MOV R11, R9              @valor de r9 no registrador no r11
        LDR R9, [R8, #level]     @carrega novamente o valor lógico alto do botão dentro do r9
        CMP R9, R11              @compara se r9 é igual r11
        BNE verificar            @se forem diferente mantem-se no loop de verificar

contador:
        ClearDisplay             @macro que realiza limpeza no display na casa decimal
        setDisplay 1, 0, 0, 1, 1 @macro que ativa a coluna ascii do LCD dos numeros
        Numero R13               @registrador que tem o valor decimal registrado logo acima do código
        ClearDisplay             @macro que realiza limpeza no display na casa da unidade
        setDisplay 1, 0, 0, 1, 1 @macro que ativa a coluna ascii do LCD dos numeros
        Numero R4                @registrador que tem o valor decimal registrado logo acima do código
        SUB r4, #1               @Subtrai a unidade por 1
        CMP r4, #0               @Compara a unidade por se r4 >=0 pula para o delay se for menor pressegue para SUB r13 
        BGE delay                @Pula ao delay caso o r4 seja >=0 
        SUB R13, #1              @Se r4 < 0 ele subtrai 1 na casa decimal
        MOV R4, #9               @adiciona 9 na casa unitária
        AND R14, R13, R4         @Faz um and dentro do R14 o valor do r13 e r4 que sempre é 9
        CMP R14, #9              @compara r14 se é = 9, na tabela do and 9 só é 9 quando faz and com 0 ou seja r13 tem que tá 0 para finalizar a contagem
        BEQ _start               @Se realmente a condição de cima for igual ele finaliza a contagem 
        nanoSleep1s timenano     @passa um nanoSleep de 1s
        B contador               @retorna ao contador caso não entre em alguma branch acima
delay:
        nanoSleep1s timenano     @nanosleep de 1s para contagem de unidade
check3:
        GPIOReadRegister pin26   @detector de click para pausar dentro do loop
        CMP R0, R3               @Compara o valor de r0 com r3 onde está o endereço do pino
        BNE check3               @Se for diferente o contador pausa e a execução fica presa no loop até soltar o botão
        GPIOReadRegister pin19   @Botão para dar um restart (ele detecta sempre se foi pressionado dentro do contador)
        CMP R0, R3               @Compara o valor de r0 com r3 onde está o endereço do pino
        BNE _start               @Se for diferente o código volta para a inicialização retornando a contagem
        B contador               @caso não entre em nenhuma branch(condição acima) volta para o contador
end:
        MOV R7, #1
        SVC 0

.data
second: .word 1 @definindo 1 segundo no nanosleep
timenano: .word 0000000000 @definindo o milisegundos para o segundo passar no nanosleep
timespecsec: .word 0 @definição do nano sleep 0s permitindo os milissegundos
timespecnano20: .word 20000000 @chamada de nanoSleep
timespecnano5: .word 5000000 @valor em milisegundos para lcd
timespecnano150: .word 150000 @valor em milisegundos para LCD
timespecnano1s: .word 999999999 @valor para delay de contador
fileName: .asciz "/dev/mem"
gpioaddr: .word 0x20200             @ OFFSET BASE DOS GPIO
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