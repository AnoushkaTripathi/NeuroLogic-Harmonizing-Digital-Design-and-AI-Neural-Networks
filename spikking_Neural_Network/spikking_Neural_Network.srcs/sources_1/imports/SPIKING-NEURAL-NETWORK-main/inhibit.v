`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2022 14:59:08
// Design Name: 
// Module Name: inhibit
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



module inhibit#(parameter no_of_neurons = 10,parameter inhibit_strength = 0)(input[no_of_neurons-1:0] out_spikes,input clk,reset,input signed [19:0] in_current[no_of_neurons-1:0],output reg [19:0] out_current [no_of_neurons-1:0],output enable);

wire [$clog2(no_of_neurons):0] AER_BUS;
wire signed [19:0] inhibit_mux_out[no_of_neurons-1:0];
reg signed [19:0] inhibit_reg[no_of_neurons-1:0];
typedef logic signed [19:0] new_data_type [no_of_neurons-1:0];
integer i;

AER #(no_of_neurons) AER1(out_spikes,clk,reset,AER_BUS,enable);

//////////// enabeling inhibition mux /////////////
always@(posedge clk)begin 
if(reset) inhibit_reg <= zero();
else begin 
 for(i = 0;i<no_of_neurons;i=i+1) 
  begin 
    if(!(AER_BUS[$clog2(no_of_neurons)]))
     if((AER_BUS[$clog2(no_of_neurons)-1:0]!=i))
      inhibit_reg[i] <= inhibit_reg[i] + inhibit_strength;
    else 
     inhibit_reg[i] <= 'b0;
  //  else  inhibit_reg[i] <= 'b0;
  end
  
end
end

/////////////// modelling inhebition mux ////////////
assign inhibit_mux_out = (AER_BUS[$clog2(no_of_neurons)])?inhibit_reg:zero();

////////////////////  inhibision block //////////////
always@(*) 
begin 
 for(i = 0;i<no_of_neurons;i=i+1) 
  begin 
   out_current[i] = in_current[i] - inhibit_mux_out[i];  // inhibiting the current to neurons
  end
end



/////////////// function which gives zeros according to new data type //////////
function new_data_type zero();
new_data_type var_;
integer i;
for(i = 0;i<no_of_neurons;i=i+1) var_[i] = 'sb0;
return var_;
endfunction

endmodule
