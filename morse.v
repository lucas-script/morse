// Lucas Costa, quarta 13 julho de 2016 21:00:00
// o esquema de switches da placa em questão é assim
// sw8	sw7	sw6	sw5	sw4	sw3	sw2	sw1	sw0
// |	| 	| 	| 	| 	| 	| 	| 	...	 |	... 

// os 5 primeiros switches [0:4] são para configurarmos qual letra/numero será mostrado, o valor é lido da esquerda para a direita sw0 -> sw4
// os 3 subsequentes são para indicar o tamanho do código morse pois ele varia entre 1 e 5, [sw5 - sw7] com o mais significativo em sw5
// ex: E -> .					A -> . _			K -> _ . _
// ex: 0 -> _ _ _ _ _		9-> _ _ _ _ .	H -> . . . .
// a chave SW[8] é o botão que liga e desliga o programa
// quando ligada mostra o código previamente configurado nos switches
// quando desligada mostra fica piscando de 1/2 em 1/2 segundo 

module morse(SW, CLOCK_50, LEDR, LEDG);
	input [0:8] SW; // os 5(código) 3(tamanho cód)
	input CLOCK_50; // clock 50 mhz
	output reg [0:17] LEDR;	// leds
	output reg [0:7] LEDG;	// leds

	parameter meioSeg = 5000000;
	parameter umSeg = 25000000;
	parameter umSegEMeio = 50000000;
	
	parameter [0:17] ligarLeds = 18'b111111111111111111;
	parameter [0:17] desligarLeds = 18'b000000000000000000;
	parameter [0:17] fimExecucao = 18'b110011001101101100;
	parameter [0:17] standby1 = 18'b101010101010101010;
	parameter [0:17] standby2 = 18'b010101010101010101;
	parameter [0:7] sucesso = 8'b11111111;
	parameter [0:7] standbyg1 = 8'b10101010;
	parameter [0:7] standbyg2 = 8'b01010101;
	parameter indexInicial = 3'b000;
	
	reg [0:25] contadorSegundos; // cotador de segundos
	reg [0:4] morse; // codigo morse
	reg [0:2] tamanho; // tamanho codigo morse
	
	reg standby = 0; // controle standby
	reg sinal = 0; // controle do led, valor do led 1 | 0
	integer indexAtual = indexInicial;
	integer delay = meioSeg;
	
	
	// inicializa as variaveis	
	always @(SW[8])
	begin
		if (SW[8] == 1'b1) begin
			morse <= SW[0:4];
			tamanho <= SW[5:7];
		end else begin
			morse <= 5'b00000;
			tamanho <= 3'b000;
		end
	end

	// clock
	always @(posedge CLOCK_50)
	begin
		if (SW[8] == 1'b1) begin // caso esteja ligado
						
			if (indexAtual <= tamanho) begin
				
				if (contadorSegundos < delay) begin
					contadorSegundos <= contadorSegundos + 1;		
				end else begin
				
					if (sinal == 1) begin
						
						// cada vez que tenho que mostrar um bit
						
						// dot
						if (morse[indexAtual] == 0) begin
							delay <= meioSeg;
							LEDG[0:7] = 8'b10000000;
						// dash		
						end else if (morse[indexAtual] == 1) begin
							delay <= umSegEMeio;
							LEDG[0:7] = 8'b11000000;
						end
						
						// LEDG[0] <= morse[indexAtual];
						indexAtual = indexAtual + 1;
						
						LEDR <= ligarLeds;
						contadorSegundos <= 0;
						sinal <= ~sinal;
					
					end else begin
						delay = 50000000;
						LEDR <= desligarLeds;
						contadorSegundos <= 0;
						sinal <= ~sinal;				
					
					end			
				end
				
			end else begin 
				
				LEDR <= desligarLeds;
				LEDG <= sucesso;
				
			end
		
		end else begin // caso não esteja ligado, fica em standby
			indexAtual <= 3'b000;
			if (contadorSegundos < meioSeg) begin
				contadorSegundos <= contadorSegundos + 1;		
			end else begin
				if (standby == 1) begin
					LEDR <= standby1;
					LEDG <=standbyg1;
					contadorSegundos <= 0;
					standby <= ~standby;
				end else begin
					LEDR <= standby2;
					LEDG <=standbyg2;
					contadorSegundos <= 0;
					standby <= ~standby;				
				end			
			end
		end
	end
	
endmodule
