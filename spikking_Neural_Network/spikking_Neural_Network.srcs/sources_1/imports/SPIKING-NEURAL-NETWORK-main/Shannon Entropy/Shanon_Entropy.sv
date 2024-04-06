`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.01.2023 11:29:02
// Design Name: 
// Module Name: Shanon_Entropy
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Shanon_Entropy(input clk,rst,NR,input [17:0] RR, output reg signed [31:0] Entropy); 

reg [5:0] Symbol_Array[129:0];        // storing all 128 RR symbols into an array. 
reg [6:0] Probability_Array[127:0];   // array representing the histogram of the Stored RR intervels
reg [17:0] Max_Word,Min_Word;         // Max & Min word size for caliculating histogram
reg signed [31:0] shanon_entropy;
reg [7:0] cnt,P_cnt;
reg [31:0]nlogn[127:0];
wire signed [31:0] Ni,wire1,wire2,wire3,wire4;
wire [17:0] Current_Word,word_step;   // current word represents the word computed form the above symbol_array --> Word(n) = (S(n-2)*2^12  +  S(n-1)*2^6  + S(n))

reg [2:0] state;  // state register for ASM 
localparam Reset = 0;        
localparam Hold = 1;
localparam Load_Symbol = 3;
localparam Max_Min = 2;
localparam Histogram = 6;
localparam Calic_Entropy = 7;

assign Ni = {13'b0,Probability_Array[cnt],12'b0};
assign Current_Word = ((Symbol_Array[cnt+2]<<12) + (Symbol_Array[cnt+1]<<6) + Symbol_Array[cnt]);
assign word_step = (Max_Word - Min_Word)>>7;

mult mult4({12'b0,P_cnt,12'b0},shanon_entropy,wire4);

assign wire1 = (Ni<<<3) - nlogn[Probability_Array[cnt]];
assign wire2 = wire1 - Ni;
assign wire3 = shanon_entropy + wire2;

int i = 0;

initial $readmemh("V:/VLSI/NEUROMORPHIC_CIRCUITS/Project/Shanon_Entropy_vivado/nlogn.txt",nlogn);

always@(posedge clk, negedge rst) begin 
    if(!rst) begin 
               for(i=0;i < 128;i=i+1) begin 
                   Symbol_Array[i]      <= 0;
                   Probability_Array[i] <= 0;
               end
               Symbol_Array[128]      <= 0;
               Symbol_Array[129]      <= 0;
               Max_Word <= 0;
               Min_Word <= 0;
               Entropy  <= 0;
               state    <= 0;
               shanon_entropy <= 0;
               cnt <= 0;
               P_cnt <= 0;
             end
    else begin 
        case(state) 
            Reset: begin 
                     for(i=0;i < 128;i=i+1) begin 
                         Probability_Array[i] <= 0;
                     end
                     Max_Word <= 0;
                     Min_Word <= 17'h1_FFFF;
                     Entropy  <= wire4;//shanon_entropy;//{12'b0,P_cnt,12'b0};
                     shanon_entropy <= 0;
                     state    <= Hold;
                     cnt <= 0;
                     P_cnt <= 0;
                   end
            Hold: begin 
                    if(NR) begin 
                             state <= Load_Symbol;
                             Symbol_Array[129:1] <= Symbol_Array[128:0];
                           end   
                    else   state <= Hold;
                  end
     
     Load_Symbol: begin 
                    Symbol_Array[0] <= (RR>504)?63:RR>>3; 
                    state <= Max_Min;
                    cnt <= 0;
                  end
         Max_Min: begin 
                    if(cnt<128) begin 
                            if(Max_Word < Current_Word) Max_Word <= Current_Word;
                            if(Min_Word > Current_Word) Min_Word <= Current_Word;
                            cnt <= cnt + 1;
                            state <= Max_Min;
                    end
                    else begin state <= Histogram; cnt <= 0; end
                  end
       Histogram: begin 
                    if(cnt<128) begin
                       
                            Probability_Array[(Current_Word - Min_Word)/word_step] = Probability_Array[(Current_Word - Min_Word)/word_step] + 1;
                            cnt <= cnt + 1;
                            state <= Histogram;
                    end
                    else begin state <= Calic_Entropy; cnt <= 0; shanon_entropy <= 0; end
                  end
   Calic_Entropy: begin 
                    if(cnt<128) begin 
                      
                            if(Probability_Array[cnt]!=0) begin 
                                    shanon_entropy <= wire3;
                                    P_cnt = P_cnt + 1;
                            end
                            cnt <= cnt + 1;
                            state <= Calic_Entropy;
                            
                    end
                    else begin state <= Reset; cnt <= 0;end
                  end
        endcase
    end
            
end

endmodule


//////////// / mult1 ////////////
module mult #(parameter N1=32,i1=20,N2=32)(input signed [N1-1:0]IN1,IN2,output signed [N2-1:0]out);
wire signed [(2*N1)-1:0]P;
assign P = IN1*IN2;
assign out = {P[(2*N1)-1],P[42:12]}; // {P[(2*N1)-1],(i2-2*i1+1)'b0,P[(2*N1)-3:N1-i1]}/(2*dt^2); /// (2*dt^2) = 2^-17  ///
endmodule                                                       ///{P[(2*N1)-1],4'b0,P[(2*N1)-3:N1-i1]}<<<17