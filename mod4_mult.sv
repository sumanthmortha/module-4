`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2024 10:57:29 AM
// Design Name: 
// Module Name: mod4_mult
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

// to avoid overflow we should take output c as q i1+i2:f1+f2 
module mod4_mult 
#(parameter i1 = 2,  
  parameter f1 = 14,
  parameter i2 = 2, 
  parameter f2 = 14,
  parameter i3 =  2,
  parameter f3 = 14,
  parameter sign1 =1,
  parameter sign2 =1,
  parameter osign = (sign1|sign2))(
  input clk,
  input reset_n,
  input [i1+f1-1:0] input_tdata_a,
  input input_tvalid_a,
  output input_tready_a,
  input [i2+f2-1:0] input_tdata_b,
  input input_tvalid_b,
  output input_tready_b,
  output [i3+f3-1:0] output_tdata,
  output output_tvalid,
  input output_tready,
  output overflow
    );
    
    localparam mult_width =  i1+i2+f1+f2;
    reg  [i1+f1-1:0]r_input_tdata_a;       // registers to store the input data
    reg  [i2+f2-1:0]r_input_tdata_b;
    wire [mult_width-1 : 0]r_mult;             // size of output q format should be int1+int2+frac1+frac2
    wire r_overflow;
    reg [i3+f3-1:0]r_output_tdata;
   // reg [i3+f3-1:0]r_output_tdata_comp;
    reg r_output_tready;
    reg r_output_tvalid;
    wire check;
    wire [1:0]check1;   // you shuld get only one bit
    wire [14:0]check2;
    wire [i1+f1-1:0]r_input_tdata_a_comp;
    wire [i2+f2-1:0]r_input_tdata_b_comp;
    
    
    assign input_tready_a = (!reset_n) ? 0 : 1;  // giving conditons for the ready
    assign input_tready_b = (!reset_n) ? 0 : 1;
    assign overflow = r_overflow;
    
    
    always@(posedge clk)              // for given control signals data is going inside the registers
    begin
    if(!reset_n)begin
     r_input_tdata_a <= 0;
     r_input_tdata_b <= 0;
     end
    else if (input_tvalid_a && input_tready_a && input_tvalid_b &&  input_tready_b) begin
                                 if (sign1) r_input_tdata_a <= $signed(input_tdata_a);       // we are representing input as signed so that i will consider first bit as signed
                                 else r_input_tdata_a <= input_tdata_a;
                                 if (sign2) r_input_tdata_b <= $signed(input_tdata_b);
                                 else r_input_tdata_b <= r_input_tdata_b;
         end
    else begin
    r_input_tdata_a <= r_input_tdata_a;
    r_input_tdata_b <= r_input_tdata_b;
    end
    end
    
    
    generate  
    assign r_input_tdata_a_comp = ~r_input_tdata_a + 1;
    assign r_input_tdata_b_comp = ~r_input_tdata_b + 1; 
                                                                                           // we use generate funcation to limit the resourse usage
    if(sign1 && sign2) assign r_mult = (r_input_tdata_a_comp * r_input_tdata_b_comp);
    else if(sign2) assign r_mult =  r_input_tdata_b_comp * r_input_tdata_a;
    else if(sign1) assign r_mult =   r_input_tdata_a_comp * r_input_tdata_b;
    else assign r_mult = r_input_tdata_a * r_input_tdata_b;
    
    if(osign) assign r_overflow = |r_mult[mult_width-2:mult_width-2-(i1+i2-i3)];
    else  assign r_overflow = |r_mult[mult_width-1:mult_width-1-(i1+i2-i3)];
    endgenerate

    assign check = r_input_tdata_a[i1+f1-1] ^ r_input_tdata_b[i2+f2-1];
    assign check1 = r_mult[mult_width-2-(i1+i2-i3): mult_width-(i1+i2)];
    assign check2 = r_mult[mult_width-1-(i1+i2): mult_width-1-(i1+i2)-f3+1];
    
    always@(posedge clk)                     // to give the output data to the register
    begin
    if(!reset_n) begin
    r_output_tdata <= 0;
    r_output_tvalid <= 0;
    end
    else if (r_output_tready) begin
                             if(osign) begin
                              r_output_tdata <= ({check ,(r_mult[mult_width-2-(i1+i2-i3): mult_width-(i1+i2)]),(r_mult[mult_width-1-(i1+i2): mult_width-1-(i1+i2)-f3+1])});
                                // r_output_tdata <= {check,~r_output_tdata_comp[i3+f3-2:0]};
                                                //   else r_output_tdata <= r_output_tdata_comp;
                              end 
                             else r_output_tdata <= {r_mult[mult_width-1-(i1+i2-i3): mult_width-(i1+i2)],r_mult[mult_width-1-(i1+i2): mult_width-1-(i1+i2)-f3+1]};
    r_output_tvalid <= 1;
    end
    else begin
    r_output_tdata <= r_output_tdata;
    r_output_tvalid <= 0;
    end
    end
    
    always@(posedge clk)          
    begin
    if(!reset_n) r_output_tready <= 0;
    else if (output_tready) r_output_tready <= 1;
    else r_output_tready <= r_output_tready;
    end
    
    
    assign output_tdata = r_output_tdata;
    assign output_tvalid = r_output_tvalid;
    
    
endmodule
