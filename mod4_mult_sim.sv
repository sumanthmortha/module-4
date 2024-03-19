`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2024 02:19:49 PM
// Design Name: 
// Module Name: mod4_mult_sim
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


module mod4_mult_sim( );

  // Parameters
  localparam  i1 = 2;
  localparam  f1 = 14;
  localparam  i2 = 2;
  localparam  f2 = 14;
  localparam  i3 = 2;
  localparam  f3 = 14;
  localparam  sign1 = 1;
  localparam  sign2 = 1;
  localparam  osign = (sign1 || sign2);

  //Ports
  reg  clk;
  reg  reset_n;
  reg [i1+f1-1:0] input_tdata_a;
  reg  input_tvalid_a;
  wire  input_tready_a;
  reg [i2+f2-1:0] input_tdata_b;
  reg  input_tvalid_b;
  wire  input_tready_b;
  wire [i3+f3-1:0] output_tdata;
  wire  output_tvalid;
  reg  output_tready;
  wire  overflow;

  mod4_mult # (
    .i1(i1),
    .f1(f1),
    .i2(i2),
    .f2(f2),
    .i3(i3),
    .f3(f3),
    .sign1(sign1),
    .sign2(sign2),
    .osign(osign)
  )
  mod4_mult_inst (
    .clk(clk),
    .reset_n(reset_n),
    .input_tdata_a(input_tdata_a),
    .input_tvalid_a(input_tvalid_a),
    .input_tready_a(input_tready_a),
    .input_tdata_b(input_tdata_b),
    .input_tvalid_b(input_tvalid_b),
    .input_tready_b(input_tready_b),
    .output_tdata(output_tdata),
    .output_tvalid(output_tvalid),
    .output_tready(output_tready),
    .overflow(overflow)
  );

always #5  clk = ! clk ;

real ref_a, ref_b, ref_mult, error_add, error_add_abs ;


function automatic real rand_float (input real min, max);
    integer unsigned rand_num;
    rand_num = $urandom();
    rand_float = min + (max-min) * (real'(rand_num)/32'hffffffff);
endfunction

function real fp_range_min (input integer i, f);
    fp_range_min = -1 * (2.0**(i-1));
endfunction

function real fp_range_max (input integer i, f);
    fp_range_max = 2.0**(i-1) - 2.0**(-f);
endfunction

function real fp_urange_max (input integer i, f);
    fp_urange_max =  2**i - 2.0**(-f);
endfunction


task automatic reset_task;
reset_n = 0;
repeat(3)@(posedge clk);
reset_n = 1;
endtask

task automatic inputs;
 for (integer i = 0; i < 10; i++) begin
        if(sign1) begin
            ref_a = rand_float(fp_range_min(i1, f1), fp_range_max(i1, f1));
        end else begin
            ref_a = rand_float(0, fp_urange_max(i1, f1));
        end   

        if(sign2) begin
            ref_b = rand_float(fp_range_min(i2, f2), fp_range_max(i2, f2));
        end else begin
            ref_b = rand_float(0, fp_urange_max(i2, f2));
        end   
        
        ref_mult = ref_a * ref_b;     
        
        input_tvalid_a = 1;
        input_tvalid_b = 1;
        input_tdata_a = $rtoi(ref_a * (2 ** f1));
        input_tdata_b = $rtoi(ref_b * (2 ** f2));
        
        repeat(3)@(posedge clk);
        read;
        repeat(2)@(posedge clk);
        if(osign) begin
            error_add = ref_mult - real'($signed(output_tdata)/2.0**14);
        end else begin
            error_add = ref_mult - real'(output_tdata/2.0**14);
        end

        if(error_add < 0) begin
            error_add_abs = -error_add;
        end else begin
            error_add_abs = error_add;
        end    
        
        if(error_add_abs > 1e-4) begin
            $display("%f %f %f %f %f %f", ref_a, ref_b, ref_mult, input_tdata_a, input_tdata_b, output_tdata);
            $display("add out mismatch. error = %f", error_add_abs);
        end
end
endtask
    
    
task automatic read;
output_tready = 1;
repeat(5)@(posedge clk);
output_tready =0;
endtask
    
    
initial begin
clk = 0;
input_tdata_a = 0;
input_tdata_b = 0;
input_tvalid_a = 0;
input_tvalid_b = 0;
output_tready = 0;

reset_task;
inputs; 

$display("INFO: test successful");
$finish;
end

endmodule

