<h1 align="center"> PROBLEMA 1 TEC 499 - Sitemas Digitas- Temporizador no LCD em Assembly </h1> 
Para o problema 1 de Sistemas Digitais, foi solicitado o desenvolvimento de um aplicativo de temporização (timer) 
onde terá que apresentar a contagem num display LCD. O tempo deve ser configurado diretamente no código e além disso
deverão ser usados 2 botões de controle: 1 para iniciar/parar a contagem e outro para reiniciar a partir do tempo definido.
 

<h1 align="center"> Sumário </h1>  

• <a href="#Requisitos">Requisitos</a>  
• <a href="#Detalhamento dos software usados no trabalho">Detalhamento dos software usados no trabalho</a> 
• <a href="#Arquitetura do computador usado nos testes">Arquitetura do computador usado nos testes</a>  
• <a href="#Instruções utilizadas">Instruções utilizadas</a>  
• <a href="#roadmap">Roadmap</a>  
• <a href="#contribuicao">Contribuição</a>  
• <a href="#licenc-a">Licença</a>  
• <a href="#Autores">Autores</a>  

<h1 align="center">Requisitos</h1> 
• Tempo inicial configurado diretamente do código ✅  

• Botão de iniciar/pausar✅  
• Botão de reiniciar o Timer✅  
• O código deve ser escrito em Assembly.✅  
• O sistema deve permitir configurar o tempo de contagem;✅
       Observação: valor limite máximo de 99

<h1 align="center"> Detalhamento dos software usados no trabalho </h1> 

• Raspberry Pi Zero: Módulo responsável pelo sistema operacional em que o problema deve ser feito e testado.
• Incluso no brotoboard além do Rapsberry também usamos: Display LCD: HD44780U (LCD-II); Botão tipo push-button
• Visual Studio Code: Software utilizado para melhor visualização do código e alterações do mesmo.
• QEMU: Software disposto para manipular o código em conjunto com o terminal do Windows para debugar o código.


<h1 align="center"> Arquitetura do computador usado nos testes </h1>

Características da Raspberry PI Zero W utilizada:

• Chip Broadcom BCM2835, com processador ARM1176JZF-S 1GHz single core;
• O processador conta com arquitetura ARMv6.
• 512MB de memória LPDDR2 SDRAM;

Periféricos:

• Display LCD: HD44780U (LCD-II);
• Botão tipo push-button.

<h1 align="center"> Instruções utilizadas </h1> 

.equ = atribui valores absolutos ou realocáveis ​​aos símbolos

.global = Torna um símbolo global, necessário para ser referência de outros arquivos pois informa onde a execução do programa começa.

.macro = Uma macro é uma sequência de instruções, atribuída por um nome e pode ser usada em qualquer lugar do programa.

.endm = Indica o fim de uma macro.

.LTORG = Utilizada para que o montador possa coletar e montar literais em um pool de literais para que o processador não tente executar as constantes como instruções.

.data = Usada para declarar dados ou constantes inicializados, estes dados  não mudam em tempo de execução.

.word = Define o armazenamento para inteiros de 32 bits

.asciz = Define a memória para uma string ASCII e adiciona um terminador NULL.


MOV = Copia o valor do operando fonte para o operando destino.

MOVS = é usada para copiar um item de dados, podendo ser byte ou word, da string de origem para a string de destino.
SVC = o modo do processador muda para Supervisor podendo, entre outras coisas, encerrar a chamada.
STR = Armazena um valor de registro na memória.
LDR = Carrega um valor de registro na memória.

ADD = Soma o valor do operando destino com o valor do operando fonte, armazena o valor em um operador informado ou no próprio operador destino.
MUL = Multiplica os operandos informados.
SUB = Subtrai o valor do operando destino com o valor do operando fonte.

LSL = Deslocamento lógico para a esquerda.
LSR = Deslocamento lógico para a direita.

BIC = Utilizado para limpar bits.

AND = Faz uma operação "E" bit a bit nos operandos e armazena o resultado no operando destino.
ORR = Faz uma operação "OU" bit a bit nos operandos e armazena o resultado no operando destino.

CMP = Compara o valor dos dois operandos.

BEQ = Condição para quando os operadores comparados forem iguais.
BGE = Condição para quando um operador comparado for maior ou igual que o outro.
BNE = Condição para quando os operadores comparados forem diferentes.
B =  Faz com que uma ramificação seja .label ###


<h1 align="center">Objetivo</h1>

<h1 align="center">Autores</h1>  

* <a href="https://github.com/AlanaSampaio">Alana Sampaio</a>  
* <a href="https://github.com/tassiocarvalho">Tassio Carvalho</a>
