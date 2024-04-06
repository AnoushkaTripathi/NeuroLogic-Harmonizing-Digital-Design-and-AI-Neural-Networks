`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2023 07:22:26
// Design Name: 
// Module Name: SNN
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


module SNN(input clk,rst,RR,RRL,RRH,RRL1,RRH1,PRRL,PRRH,PQRSL,PQRSH,QRSH,QRSL, output V,S,SA,ST,N,WT,NT,WB,NB);


wire signed [22:0] Iv,Is,Isa,Ist,In,Iwt,Int,Iwb,Inb;  // input currents for neurons 

/// instanciating neurons for classification of different arrhythmia /////
AdEx V_Neuron(clk,rst,Iv,V);
AdEx S_Neuron(clk,rst,Is,S);
AdEx SA_Neuron(clk,rst,Isa,SA);
AdEx ST_Neuron(clk,rst,Ist,ST);
AdEx N_Neuron(clk,rst,In,N);
AdEx WT_Neuron(clk,rst,Iwt,WT);
AdEx NT_Neuron(clk,rst,Int,NT);
AdEx WB_Neuron(clk,rst,Iwb,WB);
AdEx NB_Neuron(clk,rst,Inb,NB);



////////////////////        assigning weights  for input neuron spikes      ////////////////////////////
//// Here RRH ---> Spikes continuesly producing by rate coder for RR interval (Lower RR correspomds to Low frequency spikes)
//// Here RRH ---> Spikes when RR interval is > Nrr (where Nrr will vary according to the mean of RR interval)
//// Here RRL ---> Spikes when RR interval is < Nrr (where Nrr will vary according to the mean of RR interval)
//// Here PRRH ---> Spikes when previous RR interval is > Nrr (where Nrr will vary according to the mean of RR interval)
//// Here PRRL ---> Spikes when previous RR interval is < Nrr (where Nrr will vary according to the mean of RR interval)
//// Here RRH1 ---> Spikes when RR interval is > N (where N is a const)
//// Here RRL1 ---> Spikes when RR interval is < N (where N is a const)
//// Here QRSL ---> Spikes when QRS interval is < Nqrs
//// Here QRSH ---> Spikes when QRS interval is > Nqrs
//// Here PQRSL ---> Spikes when previous QRS interval is < Nqrs
//// Here PQRSH ---> Spikes when previous QRS interval is > Nqrs
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

assign Is = ( ((RRH)?40000:0) - ((RRL)?60000:0) + ((PRRL)?40000:0) - ((PRRH)?60000:0)) + ( ((PQRSL)?15000:0) - ((PQRSH)?100000:0) - ((RR)?18000:0) )>>>0;
assign Iv = ( ((RRH)?40000:0) - ((RRL)?60000:0) + ((PRRL)?40000:0) - ((PRRH)?60000:0)) + ( ((PQRSH)?15000:0) - ((PQRSL)?80000:0) - ((RR)?18000:0))>>>0;
assign Isa = ((RRH1)?40000:0) - ((RRL1)?150000:0) - ((RR)?5000:0) ;
assign Ist = ((RRL1)?30000:0) - ((RRH1)?150000:0) - ((RR)?5000:0);

assign In = ((RR)?4000:0) - ((RRH1)?25000:0) - ((RRL1)?25000:0); 

assign Iwt = (((RRL1)?80000:0) - ((RRH1)?15000:0) - ((RR)?40000:0) - ((QRSL)?8000:0) + ((QRSH)?80000:0))>>>2;
assign Int = (((RRL1)?80000:0) - ((RRH1)?15000:0) - ((RR)?40000:0) - ((QRSH)?5000:0) + ((QRSL)?80000:0))>>>2;
assign Iwb = (((RRH1)?100000:0) - ((RRL1)?15000:0) - ((RR)?40000:0) - ((QRSL)?8000:0) + ((QRSH)?80000:0))>>>1;
assign Inb = (((RRH1)?100000:0) - ((RRL1)?15000:0) - ((RR)?40000:0) - ((QRSH)?5000:0) + ((QRSL)?80000:0))>>>0;



endmodule

