@------Macro que move cursor para esquerda ou direita-------@
.macro move CD RL
        setDisplay 0, 0, 0, 0, 1  @define o db4=1; db5=0; db6=0; db7=0; rs=0

        setDisplay 0, \CD ,\RL, 0, 0
        .ltorg
.endm