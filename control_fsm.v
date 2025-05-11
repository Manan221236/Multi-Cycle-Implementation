`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.04.2025 00:29:28
// Design Name: 
// Module Name: control_fsm
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


module control_fsm(
    input wire clk, reset, zero,
    input wire [5:0] opcode,
    output reg pcWrite, pcWriteCond,
    output reg IorD, memWrite, memRead, IRwrite,
    output reg [1:0] pcSource,
    output reg aluSrcA,
    output reg [1:0] aluSrcB, aluOp,
    output reg regWrite,
    output reg regDst,
    output reg memtoReg,
    output reg linkWrite,
    output reg ALUOutWrite, MDRWrite
    );
    //state encoding
    parameter    IF =4'd0,
        ID = 4'd1,
        MEMA = 4'd2,
        MEMRD = 4'd3,
        MEMWB = 4'd4,
        MEMWR = 4'd5,
        EXR = 4'd6,
        WB_R = 4'd7,
        BRCH = 4'd8,
        JMP = 4'd9,
        JALW = 4'd10,
        EXI = 4'd11, //ALU IMMEDIATE
        WB_I = 4'd12;
    reg [3:0] state, next;
    //Sequential
    always@(posedge clk or posedge reset) begin
        if(reset)
            state <= IF;
        else
            state <= next;
    end
    
    //Combinational
    always@(*) begin
        {pcWrite, pcWriteCond, IorD, memRead, memWrite, IRwrite, pcSource, aluSrcA, aluSrcB, aluOp, regWrite, regDst, memtoReg, linkWrite, ALUOutWrite, MDRWrite} = 0;
        next = state;
        case(state)
        IF: begin
            memRead = 1;
            IRwrite = 1;
            aluSrcA = 0;
            aluSrcB = 2'b01;//+4
            aluOp = 2'b00;//add
            pcSource = 2'b00;
            pcWrite = 1;
            next = ID;
        end
        ID: begin 
            aluSrcA = 0;//PC
            aluSrcB = 2'b11;//imm<<2
            aluOp = 2'b00;
            case(opcode)
                6'b100011,//lw
                6'b101011,//sw
                6'b100101: next = MEMA;//lhu
                6'b000000: next = EXR;//RType
                6'b001011: next = EXI;//sltiu
                6'b000100,
                6'b000101: next = BRCH;//beq/bne
                6'b000010: next = JMP;//j
                6'b000011: next = JALW;//jal
                default: next = IF;
             endcase
         end
         MEMA: begin
            aluSrcA = 1;
            aluSrcB = 2'b10;//imm
            aluOp = 2'b00;//add
            ALUOutWrite = 1;
            next = (opcode==6'b101011) ? MEMWR : MEMRD;
         end
         MEMRD: begin
            memRead = 1;
            IorD = 1;
            MDRWrite = 1;
            next = MEMWB;
         end
         MEMWB: begin
            regWrite = 1;
            regDst = 0;
            memtoReg = 1;
            next = IF;
         end
         MEMWR: begin
            memWrite = 1;
            IorD = 1;
            next = IF;
         end
         EXR: begin
            aluSrcA = 1;
            aluSrcB = 2'b00;
            aluOp = 2'b10;
            ALUOutWrite = 1;
            next = WB_R;
         end
         WB_R: begin
            regWrite = 1;
            regDst = 1;
            memtoReg = 0;
            next = IF;
         end
         EXI: begin 
            aluSrcA = 1;
            aluSrcB = 2'b10;
            aluOp = 2'b11;
            ALUOutWrite = 1;
            next = WB_I;
         end
         WB_I: begin
            regWrite = 1;
            regDst = 0;
            memtoReg = 0;
            next = IF;
         end
         BRCH: begin
            aluSrcA = 1;
            aluSrcB = 2'b00;
            aluOp = 2'b01;
            pcSource = 2'b01;
            pcWriteCond = 1;
            next = IF;
         end
         JMP: begin
            pcWrite = 1;
            pcSource = 2'b10;
            next = IF;
         end
         JALW: begin
            regWrite = 1;
            linkWrite = 1;
            pcWrite = 1;
            pcSource = 2'b10;
            next = IF;
         end
         default: next = IF;
         endcase
    end
endmodule
