`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.04.2023 02:20:50
// Design Name: 
// Module Name: Rate_Coder
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



module Rate_Coder #(parameter cmp = 1)(input clk,rst,input [15:0]In, output spikes);

reg [15:0] LFSR; // LFSR Regester

assign spikes = (In < LFSR)^cmp; // Produce High frequency spikes when input is high When cmp == 1 

always@(posedge clk, negedge rst) begin 
    if(!rst)   LFSR <= 5893;   // reset the lfsr reg
    else       LFSR <= {LFSR[14:0],(((LFSR[15]^LFSR[13])^LFSR[12])^LFSR[10])};  // logic for the LFSR
end

endmodule
