.equ pagelen, 4096
.equ setregoffset, 28
.equ clrregoffset, 40
.equ prot_read, 1
.equ prot_write, 2
.equ map_shared, 1
.equ sys_open, 5
.equ sys_map, 192
.equ nano_sleep, 162
.equ level, 0x034
.equ on, 1
.equ off, 0

.global _start

.macro nanoSleep timespecnano
        LDR R0,=timespecsec
        LDR R1,=\timespecnano
        MOV R7, #nano_sleep
        SVC 0
.endm

.macro GPIODirectionOut pin
        LDR R2, =\pin
        LDR R2, [R2]
        LDR R1, [R8, R2]
        LDR R3, =\pin @ address of pin table
        ADD R3, #4 @ load amount to shift from table
        LDR R3, [R3] @ load value of shift amt
        MOV R0, #0b111 @ mask to clear 3 bits
        LSL R0, R3 @ shift into position
        BIC R1, R0 @ clear the three bits
        MOV R0, #1 @ 1 bit to shift into pos
        LSL R0, R3 @ shift by amount from table
        ORR R1, R0 @ set the bit
        STR R1, [R8, R2] @ save it to reg to do work
.endm

.macro GPIOValue pin, value
        MOV R0, #40
        MOV R2, #12
        MOV R1, \value
        MUL R5, R1, R2
        SUB R0, R0, R5
        MOV R2, R8
        ADD R2, R2, R0
        MOV R0, #1 @ 1 bit to shift into pos
        LDR R3, =\pin @ base of pin info table
        ADD R3, #8 @ add offset for shift amt
        LDR R3, [R3] @ load shift from table
        LSL R0, R3 @ do the shift
        STR R0, [R2] @ write to the register
.endm


.macro GPIOReadRegister pin
        MOV R2, R8 @Endereço dos registradores da GPIO
        ADD R2, #level @offset para acessar o registrador do pin level
        LDR R2, [R2] @ pino5, 19 e 26 ativos respectivamentes
        LDR R3, =\pin @ base dos dados do pino
        ADD R3, #8 @ offset para acessar a segunda word
        LDR R3, [R3] @ carrega a posiçao do pino -> ex queremos saber o valor do pino5 =2^5= 32 => 00 000 000 000 000 000 000 000 000 100 000
        AND R0, R2, R3 @ Filtrando os outros bits => 00 000 000 000 000 000 000 000 000 100 000
.endm

.macro setDisplay addrs, addb7, addb6, addb5, addb4
        GPIOValue pinE, #0
        GPIOValue pin25rs, #\addrs
        GPIOValue pinE, #1
        GPIOValue pin21d7, #\addb7
        GPIOValue pin20d6, #\addb6
        GPIOValue pin16d5, #\addb5
        GPIOValue pin12d4, #\addb4
        GPIOValue pinE, #0
.endm

.macro Init
        setDisplay 0, 0, 0, 1, 1
        nanoSleep timespecnano5

        setDisplay 0, 0, 0, 1, 1
        nanoSleep timespecnano150

        setDisplay  0, 0, 0, 1, 1


        setDisplay 0, 0, 0, 1, 0
        nanoSleep timespecnano150

        .ltorg

        setDisplay 0, 0, 0, 1, 0

        setDisplay 0, 0, 0, 0, 0
        nanoSleep timespecnano150

        setDisplay 0, 0, 0, 0, 0

        setDisplay 0, 1, 0, 0, 0
        nanoSleep timespecnano150

        setDisplay 0, 0, 0, 0, 0

        setDisplay 0, 0, 0, 0, 1
        nanoSleep timespecnano150

        setDisplay 0, 0, 0, 0, 0

        setDisplay 0, 0, 1, 1, 0
        nanoSleep timespecnano150

        .ltorg
.endm

.macro DisplayOnOff

        setDisplay 0, 0, 0, 0, 0
        setDisplay 0, 1, 1, 1, 0
        nanoSleep timespecnano150

        setDisplay 0, 0, 0, 0, 0
        setDisplay 0, 0, 1, 1, 0
        nanoSleep timespecnano150
        .ltorg
.endm

.macro ClearDisplay
        setDisplay 0, 0, 0, 0, 0

        setDisplay 0, 0, 0, 0, 1
        nanoSleep timespecnano150
.endm

.macro Numero valor
        GPIOValue pinE, #0
        GPIOValue pin25rs, #1
        GPIOValue pinE, #1

        MOV R10, \valor
        MOV R9, #1
        AND R11, R9, R10

        MOV R0, #40
        MOV R2, #12
        MOV R1, R11
        MUL R5, R1, R2
        SUB R0, R0, R5
        MOV R2, R8
        ADD R2, R2, R0
        MOV R0, #1 @ 1 bit to shift into pos
        LDR R3, =pin12d4 @ base of pin info table
        ADD R3, #8 @ add offset for shift amt
        LDR R3, [R3] @ load shift from table
        LSL R0, R3 @ do the shift
        STR R0, [R2] @ write to the register

        LSL R9, #1
        AND R11, R9, R10
        LSR R11, #1

        MOV R0, #40
        MOV R2, #12
        MOV R1, R11
        MUL R5, R1, R2
        SUB R0, R0, R5
        MOV R2, R8
        ADD R2, R2, R0
        MOV R0, #1 @ 1 bit to shift into pos
        LDR R3, =pin16d5 @ base of pin info table
        ADD R3, #8 @ add offset for shift amt
        LDR R3, [R3] @ load shift from table
        LSL R0, R3 @ do the shift
        STR R0, [R2] @ write to the register

        LSL R9, #1
        AND R11, R9, R10
        LSR R11, #2

        MOV R0, #40
        MOV R2, #12
        MOV R1, R11
        MUL R5, R1, R2
        SUB R0, R0, R5
        MOV R2, R8
        ADD R2, R2, R0
        MOV R0, #1 @ 1 bit to shift into pos
        LDR R3, =pin20d6 @ base of pin info table
        ADD R3, #8 @ add offset for shift amt
        LDR R3, [R3] @ load shift from table
        LSL R0, R3 @ do the shift
        STR R0, [R2] @ write to the register


        LSL R9, #1
        AND R11, R9, R10
        LSR R11, #3

        MOV R0, #40
        MOV R2, #12
        MOV R1, R11
        MUL R5, R1, R2
        SUB R0, R0, R5
        MOV R2, R8
        ADD R2, R2, R0
        MOV R0, #1 @ 1 bit to shift into pos
        LDR R3, =pin21d7 @ base of pin info table
        ADD R3, #8 @ add offset for shift amt
        LDR R3, [R3] @ load shift from table
        LSL R0, R3 @ do the shift
        STR R0, [R2] @ write to the register

        GPIOValue pinE, #0
.endm

.macro setOut
        GPIODirectionOut pinE
        GPIODirectionOut pin25rs
        GPIODirectionOut pin21d7
        GPIODirectionOut pin20d6
        GPIODirectionOut pin16d5
        GPIODirectionOut pin12d4
        .ltorg
.endm

_start:
        LDR R0, = fileName
        MOV R1, #0x1b0
        ORR R1, #0x006
        MOV R2, R1
        MOV R7, #sys_open
        SVC 0
        MOVS R4, R0

        LDR R5, =gpioaddr
        LDR R5, [R5]
        MOV R1, #pagelen
        MOV R2, #(prot_read + prot_write)
        MOV R3, #map_shared
        MOV R0, #0
        MOV R7, #sys_map
        SVC 0
        MOVS R8, R0


        setOut
        Init
        DisplayOnOff

        MOV R4, #9
        MOV R5, #9
check:
        GPIOReadRegister pin26
        CMP R0, R3
        BNE verificar
        B check

check2:
        GPIOReadRegister pin26
        CMP R0, R3
        BNE verificar
        B check3

verificar:
        LDR R9, [R8, #level]
        MOV R11, R9
        LDR R9, [R8, #level]
        CMP R9, R11
        BNE verificar
contador:
        MOV R12, #0xfffffff

        ClearDisplay

        setDisplay 1, 0, 0, 1, 1
        Numero R4
        Numero R5
        SUB r4, #1
        CMP r4, #0
        BGE delay
        nanoSleep timespecnano1s
        B _start
delay:
        SUB r12, #1
        CMP r12, #0
        BNE delay
check3:
        GPIOReadRegister pin26
        CMP R0, R3
        BNE check3
        GPIOReadRegister pin19
        CMP R0, R3
        BNE _start
        B contador
end:
        MOV R7, #1
        SVC 0

.data
timespecsec: .word 0
timespecnano20: .word 20000000
timespecnano5: .word 5000000
timespecnano150: .word 150000
timespecnano1s: .word 99999999
fileName: .asciz "/dev/mem"
gpioaddr: .word 0x20200
pin6:   .word 0
        .word 18
        .word 6
pin26:  .word 8
        .word 18
        .word 67108864
pinE:   .word 0
        .word 3
        .word 1
pin25rs:.word 8
        .word 15
        .word 25
pin12d4:  .word 4
        .word 6
        .word 12
pin16d5:  .word 4
        .word 18
        .word 16
pin20d6:.word 8
        .word 0
        .word 20
pin21d7:  .word 8
        .word 3
        .word 21
pin19:  .word 4
        .word 27
        .word 524288