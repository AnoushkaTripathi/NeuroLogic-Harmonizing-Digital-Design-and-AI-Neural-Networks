`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.05.2022 09:17:22
// Design Name: 
// Module Name: neuron
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




/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module neuron (input KEY,input signed [size-1:0] i,input CLOCK_50,enable,output reg spike);


parameter a = 'sh0_1999;
parameter b = 20'sh0_3333;
parameter c = 'shF_599A;
parameter d = 'sh0_051E;
localparam size = 20;
localparam signed p =  'sh0_4CCC ; //peak overshoot
localparam signed c14 = 'sh1_6666; // constants

//state variables
reg signed [size-1:0] v1, u1; // 
wire signed [size-1:0] v1new, u1new, ureset ; //state variable combinatorial updates
wire signed [size-1:0] v1xv1, du, v1xb ;   //signed mult outputs


//analog simulation of neuron
	always @ (posedge CLOCK_50) 
	begin
		
		if (KEY == 1 ) //reset
		begin	
			v1 <= c;     
			u1 <= d;         
			spike <= 1'b0;
		end
			
		else if(enable) //if (count==0) 
		begin
			if ((v1 > p)) 
			begin 
				v1 <= c ; 		
				u1 <= ureset ;
				spike <= 1'b1;
			end
			else
			begin
				v1 <= v1new ;
				u1 <= u1new ; 
			    spike <= 1'b0; 
			end 
		end 
	end
	
	// dt = 1/16 or 2>>4
	// v1(n+1) = v1(n) + dt*(4*(v1(n)^2) + 5*v1(n) +1.40 - u1(n) + I)
	// but note that what is actually coded is
	// v1(n+1) = v1(n) + (v1(n)^2) + 5/4*v1(n) +1.40/4 - u1(n)/4 + I/4)/4
	signed_mult #(size)v1sq(v1xv1, v1, v1);
	assign v1new = v1 + ((v1xv1 + v1+(v1>>>2) + (c14>>>2) - (u1>>>2) + (i>>>2))>>>2);
	
	// u1(n+1) = u1 + dt*a*(b*v1(n) - u1(n))
	signed_mult #(size) bb(v1xb, v1, b);
	signed_mult #(size) aa(du, (v1xb-u1), a);
	assign u1new = u1 + (du>>>4); 
	assign ureset = u1 + d ;
  
endmodule

//////////////////////////////////////////////////
//// signed mult of 2.16 format 2'comp////////////
//////////////////////////////////////////////////

module signed_mult #(parameter size = 18)(out, a, b);
 
	output 		[size-1:0]	out;
	input 	signed	[size-1:0] 	a;
	input 	signed	[size-1:0] 	b;
	
	wire	signed	[size-1:0]	out;
	wire 	signed	[(2*size)-1:0]	mult_out;

	assign mult_out = a * b;      
	//assign out = mult_out[33:17];
	assign out = {mult_out[(2*size)-1],mult_out[size+14:32], mult_out[31:16]};
	////////////// sign bit ---------// integer bits /// fractional bits ////
endmodule


