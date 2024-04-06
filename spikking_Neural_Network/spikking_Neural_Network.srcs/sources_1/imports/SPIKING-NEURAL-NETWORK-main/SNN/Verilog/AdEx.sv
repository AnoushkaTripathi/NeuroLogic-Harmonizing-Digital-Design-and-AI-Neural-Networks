`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2023 07:09:52
// Design Name: 
// Module Name: AdEx
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

module AdEx#(parameter a1=7,a2 = 16,b1=3,b2=3,c=9,d=10,
              parameter signed W_init = 23'sh0_0780_3,
              parameter signed EL = 23'shF_EDED_3, // EL = 23'shF_EDED_3
              parameter signed exp_init = 38'sh0_0000_0002_B)(input clk,rst,input signed [N-1:0]I,output reg spikes); //exp_init = 38'sh0_0000_0002_B

localparam N = 23;  // no of bits for varaibles 
localparam i = 3;   // no of integer bits in 'N'
localparam Ne = 38; // no of bits for varaible exp
localparam ie = 18; // no of integer bits in 'Ne'
localparam Ndv = 29;
localparam idv = 9;
localparam signed one = 29'sh001_0000_0;

reg signed [Ne-1:0] exp;
wire signed [Ne-1:0] update_exp,shifted_exp;
reg signed [N-1:0] V,W,VP;
wire signed [N-1:0] dv,E;
wire signed [Ndv-1:0] dv_by_dt,dv_by_dt_sqa,exp_mul,exp_mul_mux;
reg [6:0] dv_sign_ext;



mult1 #(N,i,Ndv) M1(dv,dv_by_dt_sqa);
mult2 #(Ne,ie,Ndv,idv) M2(exp,exp_mul_mux,update_exp);
 
assign dv = V - VP;
assign dv_by_dt = {dv_sign_ext,dv[N-2:0]}<<<c;     //////////dv_by_dt = {dv[N-1],6'b0,dv[N-2:0]}<<<c;
assign exp_mul = one + dv_by_dt + dv_by_dt_sqa;
assign exp_mul_mux = (dv[22]&&(|exp_mul[27:20]))?19'b0:exp_mul;
assign shifted_exp = (update_exp>>>a2);
assign E = {shifted_exp[Ne-1],shifted_exp[N-2:0]};
//assign I = (I_ecg[22])?((~I_ecg)+1):I_ecg;

always@(*) begin 
for(int i = 0;i<7;i=i+1) begin 
dv_sign_ext[i] = dv[N-1];
end
end

always@(posedge clk,negedge rst)
begin 
    if(!rst) 
       begin
         V <= EL;
         W <= W_init;
         exp <= exp_init;
         VP <= EL;
         spikes <= 0;
       end
    else 
       begin 
          if(!V[N-1])
                begin 
                   V <= EL;
                   W <= W + W_init;
                   exp <= exp_init;
                   VP <= EL;
                   spikes <= 1;
                  // count = count + 1;   // To track of no of spikes fired
                end
           else 
                begin 
                   VP <= V;
                   V <= V - ((V - EL)>>>a1) + E + (I) - (W>>>d);
                   W <= W  + ((V - EL)>>>b1) - (W>>>b2); //
                   exp <= update_exp;
                   spikes <= 0;
                end
        end
end

endmodule



//////////// / mult1 ////////////
////// out = 0.5*(dv/dt)^2 //////
module mult1 #(parameter N1=23,i1=3,N2=29)(input signed [N1-1:0]IN,output signed [N2-1:0]out);
wire signed [(2*N1)-1:0]P;
assign P = IN*IN;
assign out = (|P[(2*N1)-3:N1-i1+11])?{P[(2*N1)-1],28'h7F_FFFF_F}:{P[(2*N1)-1],P[(2*N1)-1],P[(2*N1)-1],P[(2*N1)-1],P[(2*N1)-1],P[(2*N1)-3:N1-i1]}<<<17; // {P[(2*N1)-1],(i2-2*i1+1)'b0,P[(2*N1)-3:N1-i1]}/(2*dt^2); /// (2*dt^2) = 2^-17  ///
endmodule                                                       ///{P[(2*N1)-1],4'b0,P[(2*N1)-3:N1-i1]}<<<17

///////////////////////// / mult2 /////////////////////////
////// //// out = exp*(1 + (dv/dt) + 0.5*(dv/dt)^2); //////
module mult2 #(parameter N1=38,i1=18,N2=29,i2=9)(input signed [N1-1:0]IN1,input signed [N2-1:0]IN2,output signed [N1-1:0]out); 
wire signed [(N1+N2)-1:0]P;
assign P = IN1*IN2;
assign out = (|P[N1+N2-3:(N1+N2)-(i2+2)+1])?{P[(N1+N2)-1],37'h1FFFF_FFFF_F}:{P[(N1+N2)-1],P[(N1+N2)-(i2+2):N2-i2]};  /// out = exp*(1 + (dv/dt) + 0.5*(dv/dt)^2); N1+N2-3:(N1+N2)-(i2+2)+1
endmodule
