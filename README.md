<h1 align="center"> PROBLEMA 1 TEC 499 - Sitemas Digitas- Temporizador no LCD em Assembly </h1> 
Para o problema 1 de Sistemas Digitais, foi solicitado o desenvolvimento de um aplicativo de temporização (timer) 
onde terá que apresentar a contagem num display LCD. O tempo deve ser configurado diretamente no código e além disso
deverão ser usados 2 botões de controle: 1 para iniciar/parar a contagem e outro para reiniciar a partir do tempo definido.
 

<h1 align="center"> Sumário </h1>  

• <a href="#Requisitos">Requisitos</a> 

• <a href="#Detalhamento-dos-software-usados">Detalhamento dos software usados no trabalho</a>

• <a href="#Arquitetura-do-computador-usado-nos-testes">Arquitetura do computador usado nos testes</a>  

• <a href="#Instruções-utilizadas">Instruções utilizadas</a>  

• <a href="#Instalação-configuração-de-ambiente-e-execução">Instalação, configuração de ambiente e execução</a>  

• <a href="#Descrição-dos-testes-de-funcionamento-do-sistema">Descrição dos testes de funcionamento do sistema</a>

• <a href="#Considerações-finais">Considerações finais</a>  

• <a href="#Material-utilizado">Material utilizado</a>  

• <a href="#Autores">Autores</a>  


<h1 align="center">Requisitos</h1> 

• Tempo inicial configurado diretamente do código ✅  
• Botão de iniciar/pausar✅  
• Botão de reiniciar o Timer✅  
• O código deve ser escrito em Assembly.✅  
• O sistema deve permitir configurar o tempo de contagem;✅
       Observação: valor limite máximo de 99


<h1 id="Detalhamento-dos-software-usados" align="center"> Detalhamento dos software usados no trabalho </h1> 

• Raspberry Pi Zero: Módulo responsável pelo sistema operacional em que o problema deve ser feito e testado.

• Incluso no brotoboard além do Rapsberry também usamos: Display LCD: HD44780U (LCD-II); Botão tipo push-button

• Visual Studio Code: Software utilizado para melhor visualização do código e alterações do mesmo.

• QEMU: Software disposto para manipular o código em conjunto com o terminal do Windows para debugar o código.


<h1 id="Arquitetura-do-computador-usado-nos-testes" align="center"> Arquitetura do computador usado nos testes </h1>

<h3> Características da Raspberry PI Zero W utilizada: </h3>  

• Chip Broadcom BCM2835, com processador ARM1176JZF-S 1GHz single core;
• O processador conta com arquitetura ARMv6.
• 512MB de memória LPDDR2 SDRAM;

<h3> Periféricos: </h3>

• Display LCD: HD44780U (LCD-II);
• Botão tipo push-button.


<h1 id="Instruções-utilizadas" align="center"> Instruções utilizadas </h1> 

```
.equ = atribui valores absolutos ou realocáveis aos símbolos

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

B =  Faz com que uma ramificação seja .label 
```


<h1 id="Instalação-configuração-de-ambiente-e-execução" align="center">Instalação, configuração de ambiente e execução </h1>

• Antes de tudo obtenha o Raspberry Pi Zero em mãos;

• Para executar é necessário clonar o projeto na sua máquina usando o comando a seguir;

```
$ git clone https://github.com/tassiocarvalho/Problema1LinguagemAssembly.git
```

• Transfira os arquivos baixados no ponto dois para o Raspberry Pi Zero;

• Execute os seguintes comandos: 

```
$ make
```

```
$ sudo ./main
```


<h1 id="Descrição-dos-testes-de-funcionamento-do-sistema" align="center">Descrição dos testes de funcionamento do sistema </h1>

Para a elaboração do sistema foi necessário a execução de sete testes sendo eles detalhados a seguir:

<h3>Primeiro teste:</h3>

• Com o intuito de testar o mapeamento de um componente do circuito a LED foi a escolhida, acompanhada de um código onde quando detectasse a pinagem a LED deveria responder acendendo.

<h3>Segundo teste:</h3>

• A partir desse momento o mapeamento dos botões foram os escolhidos além da diferenciação entre eles, sendo utilizado novamente a LED. O código corresponde um algoritmo que ao detecnar o nível lógico alto de um pino correspondente a um botão acendia a LED. Obtivemos primeiramente a resposta de apertar qualquer botão e obter a resposta da LED e a seguir conseguir diferenciar pelos pinos qual botão seria responsável pelo feito de ter uma resposta da LED.

<h3>Terceiro teste:</h3>

• Ainda sobre o mapeamento chegou a vez do LCD. O terceiro teste teve a inteção de exibir a letra "H" no display, sendo exibido em seguida ocaracter "#" e também números.

<h3>Quarto teste:</h3>

• O quarto teste se deu pela exibição no LCD de um código em assembly com o objetivo de contar em ordem descrescente de 9 a 0, usando até então somente uma casa unitária, sendo assim, o número exibido era apagado e o próximo aparecia no mesmo lugar, sem percorrer o cursor pelo display.

<h3>Quinto teste:</h3>

• A seguir, as funcionalidades a serem testadas integravam os botões e o temporizador. Os botões neste teste possuiam a funcionalidade de iniciar, pausar e reiniciar o temporizador sendo um botão encarregado de iniciar e pausar e o outro de reiniciar. O responsável por pausar e iniciar ocorreu como esperado precisando pressionar o botão para o contador pausar e ao ser solto iniciar a contage novamente. O segundo botão reinicia o sistema aparecendo a mensagem inicial do sistema "Aperte o botão".

<h3>Sexto teste:</h3>

• Ademais, o sexto teste se deu referente a inserção de mais digitos no LCD saindo de casa unitária para decimal.

<h3>Sétimo teste:</h3>

• Por fim, o sétimo e último teste possuia o proposito de aumentar os dígitos visíveis no LCD, saindo de decimal para centena. e somente neste teste o código não funcionou pois não foi possível encerraro o contador ao chegar 000 e não demos prosseguimento.


<h1 id="#Considerações-finais" align="center"> Considerações finais</h1>

Apesar do sistema cumprir os 
<a href="#Requisitos">requisitos</a>
, o mesmo possui suas limitações como:

• O LCD não foi usado em sua capacidade máxima. 

• O botão pausar precisa ser pressionado para o sistema pausar a contagem, sendo o ideal ser clicado e não pressionado.

Contudo, entregamos um temporizador obtendo os requisitos mínimos solicitados em assembly e o display separado como biblioteca. 

Segue um link demonstrativo do código funcionando: 

• [Vídeo demonstrativo](https://www.youtube.com/watch?v=xTtwCqUxBoU)


<h1 id="Material-utilizado" align="center">Material utilizado </h1>  

[Stephen Smith - Raspberry Pi Assembly Language Programming](https://link.springer.com/book/10.1007/978-1-4842-5287-1)

[HD44780U (LCD-16x2)](https://www.sparkfun.com/datasheets/LCD/HD44780.pdf)

[BCM2835 ARM Peripherals](https://www.raspberrypi.org/app/uploads/2012/02/BCM2835-ARM-Peripherals.pdf)

[ARM1176JZF-S Technical Reference Manual](https://developer.arm.com/documentation/ddi0301/h?lang=en)

[Linux system Calls - ARM 32bit EABI](https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md#arm-32_bit_EABI)


<h1 align="center">Autores</h1>  

* <a href="https://github.com/AlanaSampaio">Alana Sampaio</a>  
* <a href="https://github.com/tassiocarvalho">Tassio Carvalho</a>
