`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.05.2022 09:18:17
// Design Name: 
// Module Name: aer
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


module AER#(parameter no_of_neurons = 5)(input [no_of_neurons - 1:0] spikes,input clk,reset,output[$clog2(no_of_neurons):0] AER_BUS,output  neuron_enable);

localparam init = 0;         // state 0
localparam serial_send = 1;  // state 1
localparam fifo_size = 4;

reg [no_of_neurons - 1:0] memory[fifo_size-1:0];
reg [no_of_neurons - 1:0] fifo_out;
reg [$clog2(fifo_size):0] fifo_ptr;



reg fifo_enable;
reg state;
reg [no_of_neurons - 1:0]data;

// neuron enable
assign neuron_enable = fifo_enable;

encoder #(no_of_neurons) E(data,AER_BUS);             // priority encoder used for encoding the adress



////  FIFO
// This fifo is used as a buffer for this AER transmiter
always@(posedge clk, posedge reset) begin : FIFO
if(reset) begin
  memory[0] <= 'b0;
  memory[1] <= 'b0;
  memory[2] <= 'b0;
  memory[3] <= 'b0;
  fifo_out  <= 'b0;
  fifo_ptr  <= 'b0;
end
else begin
  if(fifo_enable) begin
    if(fifo_ptr == 3'b0) begin         // when buffer is empty
      fifo_out <= spikes;
    end
    else begin                         // when buffer is not empty
      fifo_out <= memory[0];
      if(|spikes) begin             // if atleast one neuron is spiking 
        memory <= {'b0,memory[fifo_size-1:1]};
        memory[fifo_ptr - 1] <= spikes;    // add to the buffer 
      end  
      else begin                       // if all neurons are not spiking 
        memory <= {'b0,memory[fifo_size-1:1]};  // shift right
        fifo_ptr <= fifo_ptr - 1;
      end
    end
  end 
  else begin
  if((fifo_ptr < fifo_size) & (|spikes))begin
    memory[fifo_ptr] <= spikes;        // load the spikes into buffer
    fifo_ptr <= fifo_ptr + 1;
                        end
  end
end
end


//// CONTROLLER BLOCK,
// This block is responcable for transmiting the adresses of the neurons which are spiking in serial bus, while keeping enable = 0;
/// It is a Finite State Meachine with two states  1-> init  2->  transmit_data

always@(posedge clk, posedge reset) begin
if(reset) begin
   fifo_enable <= 'b1;
   state <= 'b0;
   data <= 'b0;
end
else begin
  case(state)
  
    init: begin 
            if(fifo_out == 'b0) begin 
              state <= init;
              fifo_enable <= 1'b1; 
            end
            else begin 
              state = serial_send;
              fifo_enable <= 1'b0;
              data <= fifo_out;
            end
          end
          
    serial_send: begin
                   if(&AER_BUS) begin   // if data is empty .
                     state <= init;
                     fifo_enable <= 1'b1;
                   end
                   else begin 
                     state <= serial_send;
                     fifo_enable <= 1'b0;
                     data[AER_BUS[$clog2(no_of_neurons)-1 : 0]] <= 1'b0;   // dissabeling the bit from the data after transmission
                   end
                 end
  endcase
end
end

 
endmodule


///// PRIORITY ENCODR //////////
/*
module encoder #(parameter size = 5)(input [size -1:0] IN, output reg [$clog2(size):0] OUT);

always@(*) begin 
casex(IN) 
5'bxxxx1: OUT = 'd0;
5'bxxx10: OUT = 'd1;
5'bxx100: OUT = 'd2;
5'bx1000: OUT = 'd3;
5'b10000: OUT = 'd4;
default : OUT = 'b111111;
endcase
end

endmodule
*/

module encoder #(parameter size = 5)(input [size -1:0] IN, output [$clog2(size):0] OUT);

integer i;
reg [$clog2(size):0] wires[size:0];
assign OUT = wires[0];
assign wires[size] = ~'b0;

always@(*) begin

    for(i = size-1; i >= 0;i = i - 1) begin 
       if(IN[i] == 1'b1) wires[i] = i;
       else wires[i] = wires[i+1];
                                   end
       end
  
endmodule
