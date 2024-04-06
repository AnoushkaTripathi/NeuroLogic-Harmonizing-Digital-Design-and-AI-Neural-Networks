`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.01.2023 15:31:19
// Design Name: 
// Module Name: Test
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


module Test( );

reg clk,rst,NR;
reg [17:0] RR;
wire spikes;
wire [22:0]I;
//wire signed [22:0] Filtered_RR;
//reg [22:0] ECG_file [20000:0];
//reg [22:0] ECG;
reg [17:0] RR_file[61914:0];
wire [31:0] Entropy_;

initial $readmemh("V:/VLSI/NEUROMORPHIC_CIRCUITS/Project/SNN/Python/Hex_Data/04043.txt",RR_file);

//initial $readmemh("V:/VLSI/NEUROMORPHIC_CIRCUITS/ECG_DATA_SET/Python/mit_bih_hex/100.hex",ECG_file);

Shanon_Entropy Entropy(clk,rst,NR,RR,Entropy_);
AdEx Neuron(clk,rst,I,spikes);
assign I = Entropy_>>>16;

initial begin 
clk = 0; rst = 1; NR = 0;
#5 rst = 0;
#20 rst = 1; 


for(int i = 0;i<61915;i=i+1) begin 

RR = RR_file[i];
NR = 1;
#20 NR = 0;
#1000 NR = 0;

end

end

always#(0.5) clk = ~clk;

endmodule
