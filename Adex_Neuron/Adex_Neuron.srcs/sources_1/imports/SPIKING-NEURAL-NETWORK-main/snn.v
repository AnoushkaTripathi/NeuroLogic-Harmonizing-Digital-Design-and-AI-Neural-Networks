`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.05.2022 09:15:53
// Design Name: 
// Module Name: snn_architecture
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



module multi_layer_snn_with_aer#(parameter  no_of_neurons = 10,parameter In_neurons = 5)
                                 (input clk,reset,input [In_neurons-1:0] input_spikes,output [no_of_neurons-1:0] OUT_spikes,input T,input [no_of_neurons-1:0] enable,input inhibit_rst);

 
localparam size = 20;

wire enable_IN_N,enable_EX_N;
wire [$clog2(In_neurons):0] AER_BUS;
wire [size-1:0] EX_N_IN_current[no_of_neurons-1:0];
wire signed [size-1:0] inhibit_in_current [no_of_neurons-1:0] ;


/////////////////////////////////////  AER BOLCK FOR LAYERS 1&2 ////////////////////////////////////
AER #(In_neurons) AER1(input_spikes,clk,reset,AER_BUS,enable_IN_N);
// *********************************    generating  synaps  ***************************//
synaps_block #(In_neurons,no_of_neurons) SB1(OUT_spikes,clk,reset,AER_BUS,inhibit_in_current,T);
// *********************************    generating  inhibit block  ***************************//
inhibit #(no_of_neurons,20'sh0_2000) inhibit1(OUT_spikes,clk,inhibit_rst,inhibit_in_current,EX_N_IN_current,enable_EX_N);
//============================================= generating neurons   ======================================================///////
neuron #('sh0_1999,'sh0_3333,'shF_599A,'sh0_051E)  HL1_N[no_of_neurons-1:0](reset,EX_N_IN_current,clk,(enable&{10{enable_EX_N}}),OUT_spikes);



endmodule
