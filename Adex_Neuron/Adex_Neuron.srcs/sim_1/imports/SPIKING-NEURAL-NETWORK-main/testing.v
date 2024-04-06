`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.06.2022 23:24:53
// Design Name: 
// Module Name: test
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


module test( );

integer seed1,seed2,seed3,seed4,seed5,var1,var2,var3,var4,var5;
reg clk,reset,T,inhibit_rst;
reg [4:0] input_spikes;
reg [9:0] enable;
wire [9:0] OUT_spikes;

 multi_layer_snn_with_aer#(10,5) dut(clk,reset,input_spikes,OUT_spikes,T,enable,inhibit_rst);

initial begin 
seed1 = 10;seed2=10;seed3=10;seed4=10;seed5=10;
var1=200;var2=200;var3=200;var4=200;var5=200;inhibit_rst = 1;
input_spikes = 'h1F;clk=0;reset=1;T=0;enable = 10'b11_1111_1111;
#100 reset = 0;inhibit_rst = 0;
#100 T = 1;
#20000 enable = 10'b01_1111_1111; inhibit_rst = 1;
#10 inhibit_rst = 0;
#100000
$finish();
end

always#(1) clk = ~clk;
 
 ////////////////// poission spike 1 /////////////////
always#(var1) 
 begin
  var1 = $dist_exponential(seed1,100); 
  input_spikes[0] = 1;
  #2 input_spikes[0] = 0;
 end
 
 ////////////////// poission spike 2 /////////////////
always#(var2) 
 begin
  var2 = $dist_exponential(seed2,200); 
  input_spikes[1] = 1;
  #2 input_spikes[1] = 0;
 end
 
 ////////////////// poission spike 3 /////////////////
always#(var3) 
 begin
  var3 = $dist_exponential(seed3,500); 
  input_spikes[2] = 1;
  #2 input_spikes[2] = 0;
 end
 
 ////////////////// poission spike 4 /////////////////
always#(var4) 
 begin
  var4 = $dist_exponential(seed4,700); 
  input_spikes[3] = 1;
  #2 input_spikes[3] = 0;
 end

 ////////////////// poission spike 5 /////////////////
always#(var5) 
 begin
  var5 = $dist_exponential(seed5,900); 
  input_spikes[4] = 1;
  #2 input_spikes[4] = 0;
 end



endmodule
