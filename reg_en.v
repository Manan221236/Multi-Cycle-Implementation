`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.04.2025 00:24:59
// Design Name: 
// Module Name: reg_en
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


module reg_en #(
    parameter WIDTH = 32
    )(
        input wire clk, reset, en,
        input wire [WIDTH-1:0] d,
        output reg [WIDTH-1:0] q
    );
        always@(posedge clk or posedge reset) begin
            if(reset) q <= {WIDTH{1'b0}};
            else if (en) q <= d;
        end
endmodule
