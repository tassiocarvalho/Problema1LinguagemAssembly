.equ nano_sleep, 162    @SYSCALL DO SISTEMA LINUX PARA REALIZAR UMA "PAUSA" NA EXECUÇAO DO PROGRAMA

@----------------------Macro da nano sleep de ms--------------------@
.macro nanoSleep timespecnano
        LDR R0,=timespecsec @carrega o valor da variavel timespecsec
        LDR R1,=\timespecnano @paramentro da macro
        MOV R7, #nano_sleep
        SVC 0
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

.macro aperte
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
.endm

.data
timespecsec: .word 0 @definição do nano sleep 0s permitindo os milissegundos
timespecnano5: .word 5000000 @valor em milisegundos para lcd
timespecnano150: .word 150000 @valor em milisegundos para LCD