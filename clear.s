@---------------Macro que realiza a limpeza do LCD----------------@
.macro ClearDisplay
        setDisplay 0, 0, 0, 0, 0  @define o db4=0; db5=0; db6=0; db7=0; rs=0

        setDisplay 0, 0, 0, 0, 1  @define o db4=1; db5=0; db6=0; db7=0; rs=0
        nanoSleep timespecnano150 @realiza um delay de 15 milisegundos
        .ltorg
.endm