`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.04.2025 21:53:48
// Design Name: 
// Module Name: se_sl
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


module SignExtend(
    input wire [15:0] in,
    output wire [31:0] out
    );
    assign out = {{16{in[15]}}, in};
endmodule
module ShiftLeft2(
    input wire [31:0] in,
    output wire [31:0] out
);
    assign out = {in[29:0], 2'b00};
endmodule