`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.05.2022 09:19:21
// Design Name: 
// Module Name: synaps
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


module synaps_block #(parameter In_neurons = 5, parameter Out_neurons = 2,parameter initial_weights = 18'sh0_10000)
                     (input [Out_neurons-1:0] IN_L2,input clk,reset,input [$clog2(In_neurons):0] AER_BUS, output signed [19:0] OUT[Out_neurons-1:0],input T);
                     
   synaps #(In_neurons,20,initial_weights) S[Out_neurons-1:0](clk,reset,IN_L2,AER_BUS,OUT,T);
   
endmodule







module  synaps#(parameter  no_of_neurons = 10,parameter size = 20,parameter initial_weights = 18'sh0_8000)(input clk,reset,post,input [$clog2(no_of_neurons):0] AER_BUS,output [size-1:0] out,input T);

wire [no_of_neurons-1:0]pre_spikes;
wire signed [17:0] weights [no_of_neurons-1:0];
wire [17:0]weight;
reg signed [size-1:0] OUT;


BCM #(initial_weights) TSTDP_BCM[no_of_neurons-1:0](clk&T,reset,pre_spikes,post,weights);    // BCM BLOCKS 
decoder #($clog2(no_of_neurons),no_of_neurons) decode_to_spikes(AER_BUS[$clog2(no_of_neurons)-1:0],pre_spikes);
assign weight = weights[AER_BUS[$clog2(no_of_neurons)-1:0]];
assign out = (AER_BUS[$clog2(no_of_neurons)])?OUT:'b0;

always@(posedge clk) begin
if(reset) OUT <= 'b0;
else begin
if(AER_BUS[$clog2(no_of_neurons)]) OUT <= 'b0;
else OUT <= OUT + {weight[17],weight[17],weight}; 
end
end
endmodule



///////////// decoder module ///////////
module decoder #(parameter in_size = 5,parameter out_size = 10) (input [in_size-1:0] IN, output reg [out_size-1:0] OUT);
always@(*) begin 
for(integer i =0;i<out_size;i = i + 1) begin
if(IN == i) OUT[i] = 1'b1;
else OUT[i] = 1'b0;
end
end
endmodule

