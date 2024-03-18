`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2024 02:49:25 PM
// Design Name: 
// Module Name: mod4_add_signed
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


module mod4_add_signed (
input clk,
input reset_n,

input [15:0]input_tdata_a,    //  q 2.14 format
input input_tvalid_a,
output input_tready_a,

input [15:0]input_tdata_b,      // q 2.14 format
input input_tvalid_b,
output  input_tready_b,

output [15:0] output_tdata,   //  q2.14 format
output output_tvalid,
input output_tready,
input sign,

output overflow
    );
    
    reg [15:0] a,b;
    reg [16:0] sum = 0;
    reg r_output_tready;
    reg r_output_tvalid;
    reg r_overflow;
    reg r_sign;
    
    always@(posedge clk)
    begin
    if(!reset_n)
    begin
    a <= 0;
    end
    else begin
               if(input_tvalid_a && input_tready_a)
               begin
               a <= input_tdata_a;
               end
               else begin
               a <= a;
               end
    end
    end


always@(posedge clk)
    begin
    if(!reset_n)
    begin
    b <= 0;
    end
    else begin
               if(input_tvalid_b && input_tready_b)
               begin
               b <= input_tdata_b;
               end
               else begin
               b <= b;
               end
    end
    end
    
    
always@(posedge clk)
begin
if (!reset_n) begin 
r_output_tready <= 0;
r_sign <= 0;
end
else begin
 r_output_tready <= output_tready;
 r_sign <= sign;
end
end


always@(posedge clk)
begin
if(!reset_n) begin 
sum <= 0;
r_output_tvalid <= 0;
end
else begin
                if(r_output_tready) begin
                sum <= a+b;
                r_output_tvalid <= 1;
                end
                else begin
                sum <= sum;
                r_output_tvalid <= 0;
                end               
end
end    
 
 always@(posedge clk)                                            // overflow logic
 begin
 if(!reset_n) r_overflow <= 0;
 else if(r_sign && !a[15] && !b[15] && sum[15]) r_overflow <= 1;         
 else if (r_sign && a[15] && b[15] && !sum[15]) r_overflow <= 1;
 else if (!r_sign && sum[16]) r_overflow <= 1;
 else r_overflow <= 0;
 end
 
assign overflow = r_overflow;
assign output_tdata = sum[15:0];
assign output_tvalid = r_output_tvalid;
assign input_tready_a = (r_output_tvalid) ? 1 : 0;
assign input_tready_b = (r_output_tvalid) ? 1 : 0;

endmodule
