`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/21/2023 12:35:54 PM
// Design Name: 
// Module Name: sort_fixed_tb
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


module sort_fixed_tb();

    reg clock, rst;
    reg [31:0] a;
    wire [31:0] outP;
    wire outvalid;

    always #50 clock = ~clock;

    sort_fixed DUT (a, clock, rst, outP, outvalid);

    initial begin
    clock = 1; rst = 1;
    #100 rst = 0;
     a = 32'b0_10000001_00000000000000000000000;
    #100 a = 32'b0_10000001_01000000000000000000000;
    #100 a = 32'b0_10000000_10000000000000000000000;
    #100 a = 32'b1_10000010_01000000000000000000000;
    #100 a = 32'b0_10000000_01010000000000000000000;
    #100 a = 32'b0_10000001_11000000000000000000000;
    #100 a = 32'b1_10000001_00000000000000000000000;
    #100 a = 32'b0_10000000_00000000000000000000000;
    end

endmodule
