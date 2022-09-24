.equ pagelen, 4096      @ TAMANHO DA MEN 
.equ prot_read, 1       @ MODO DE LEITURA
.equ prot_write, 2      @ MODO DE ESCRITA
.equ map_shared, 1      @ LIBERAR COMPARTILHAMENTO DE MEMÓRIA (PARA NÃO SER DE USO EXCLUSIVO)
.equ sys_open, 5        @ SYSCALL DE ABERTURA E POSSIBILIDADE DE CRIAR ARQUIVO
.equ sys_map, 192       @ SYSCALL DO SISTEMA LINUX PARA MAPEAMENTO DE MEMÓRIA (GERA ENDEREÇO VIRTUAL)
.equ level, 0x034       @VALOR DO PIN LEVEL DOS REGISTRADORES DE 0-31

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

.macro mapeamento
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
.endm

gpioaddr: .word 0x20200             @ OFFSET BASE DOS GPIO