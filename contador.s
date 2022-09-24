.macro contador
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
        AND R6, R13, R4         @Faz um and dentro do R14 o valor do r13 e r4 que sempre é 9
        CMP R6, #9              @compara r14 se é = 9, na tabela do and 9 só é 9 quando faz and com 0 ou seja r13 tem que tá 0 para finalizar a contagem
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
.endm