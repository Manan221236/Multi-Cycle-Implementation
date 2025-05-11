`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.04.2025 21:43:31
// Design Name: 
// Module Name: alu_control
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


module alu_control(
    input wire [5:0] funct,
    input wire [1:0] aluOp,
    output reg [3:0] aluControl
    );
    localparam ALU_ADD = 4'b0010;
    localparam ALU_SUB = 4'b0110;
    localparam ALU_AND = 4'b0000;
    localparam ALU_OR = 4'b0001;
    localparam ALU_SLT = 4'b0111;
    localparam ALU_SLTU = 4'b1111;
    localparam ALU_SRL = 4'b1001;
    
    always@(*)begin
        case(aluOp)
            2'b00: aluControl = ALU_ADD; //lw,sw
            2'b01: aluControl = ALU_SUB; //beq,bne
            2'b10: begin
                //R-Type
                case(funct)
                    6'b100000: aluControl = ALU_ADD;
                    6'b100010: aluControl = ALU_SUB;
                    6'b100100: aluControl = ALU_AND;
                    6'b100101: aluControl = ALU_OR;
                    6'b101010: aluControl = ALU_SLT;
                    6'b000010: aluControl = ALU_SRL;
                    default: aluControl = ALU_ADD;
                endcase
            end
            2'b11: aluControl = ALU_SLTU; //sltiu
            default: aluControl = ALU_ADD;
        endcase
    end
endmodule
