`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.04.2025 15:07:35
// Design Name: 
// Module Name: RegisterFile
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


module RegisterFile(
    input wire clk, regWrite,
    input wire [4:0] readReg1, readReg2, writeReg,
    input wire [31:0] writeData,
    output wire [31:0] readData1, readData2
    );
    reg [31:0] regfile [0:31];
    integer i;
    initial begin
        for(i=0;i<32;i=i+1)begin
            regfile[i] = 32'b0;
        end
    end
    
    assign readData1 = regfile[readReg1];
    assign readData2 = regfile[readReg2];
    
    always@(posedge clk) begin
        if(regWrite && (writeReg != 0)) begin
            regfile[writeReg] <=writeData;
        end
    end
endmodule
