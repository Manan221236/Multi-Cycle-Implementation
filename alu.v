`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.04.2025 23:30:28
// Design Name: 
// Module Name: alu
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


module alu(
    input wire [31:0] a,b,
    input wire [3:0] control,
    input wire [4:0] shamt,
    output reg [31:0] res,
    output wire zero
    );
    wire [31:0] sub_res = a-b;
    wire [31:0] add_res = a+b;
    wire [31:0] and_res = a&b;
    wire [31:0] or_res = a|b;
    wire [31:0] slt_res = ($signed(a) < $signed(b)) ? 32'd1:32'd0;
    wire [31:0] sltu_res = (a<b) ? 32'd1 : 32'd0;
    wire [31:0] srl_res = b>>shamt;
    
    always@(*)begin
        case(control)
            4'b0010: res = add_res;
            4'b0110: res = sub_res;
            4'b0000: res = and_res;
            4'b0001: res = or_res;
            4'b0111: res = slt_res;
            4'b1111: res = sltu_res;
            4'b1001: res = srl_res;
            default:res = 32'b0;
        endcase
    end
    assign zero = (res == 32'b0);
endmodule
