`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.04.2025 01:27:58
// Design Name: 
// Module Name: MCI
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


module MCI(
    input wire clk, reset
    );
    //Wires
    wire [31:0] pc_curr, pc_next;
    wire [31:0] mem_data;
    wire [31:0] ir;
    wire [5:0] opcode = ir[31:26];
    
    //Register File Ports
    wire [4:0] rs = ir[25:21];
    wire [4:0] rt = ir[20:16];
    wire [4:0] rd = ir[15:11];
    wire [31:0] rf_rd1, rf_rd2, rf_wd;
    wire [4:0] rf_wa;
    
    //immediate + shifted
    wire [31:0] sign_imm;
    wire [31:0] imm_shift2;
    
    //ALU Network
    wire [31:0] A, B, alu_in_a, alu_in_b, alu_res;
    wire [3:0] alu_ctrl;
    wire zero_flag;
    
    //Pipeline Registers
    wire [31:0] alu_out;
    wire [31:0] mdr;
    
    //Control Signals from FSM
    wire pcWrite, pcWriteCond, IorD, memRead, memWrite, IRwrite, ALUOutWrite, MDRWrite;
    wire [1:0] pcSource;
    wire aluSrcA;
    wire [1:0] aluSrcB;
    wire [1:0] aluOp;
    wire regWrite, regDst, memtoReg, linkWrite;
    
    //PC
    PC pc(
        .clk(clk),
        .reset(reset),
        .pc_in(pc_next),
        .pc_out(pc_curr)
    );
    wire [31:0] mem_addr = IorD ? alu_out : pc_curr;
    RAM memory(
        .clk(clk),
        .memRead(memRead),
        .memWrite(memWrite),
        .addr(mem_addr),
        .data_in(B),
        .data_out(mem_data)
    );
    //Intermediate Registers
    //IR
    reg_en #(32) IR(
        .clk(clk),
        .reset(reset),
        .en(IRwrite),
        .d(mem_data),
        .q(ir)
    );
    //MDR
    reg_en #(32) MDR(
        .clk(clk),
        .reset(reset),
        .en(MDRWrite),
        .d(mem_data),
        .q(mdr)
    );
    //A and B
    reg_en #(32) A_reg(
        .clk(clk),
        .reset(reset),
        .en(1'b1),
        .d(rf_rd1),
        .q(A)
    );
    reg_en #(32) B_reg(
        .clk(clk),
        .reset(reset),
        .en(1'b1),
        .d(rf_rd2),
        .q(B)
    );
    //ALU Out
    reg_en #(32) ALUOut_reg(
        .clk(clk),
        .reset(reset),
        .en(ALUOutWrite),
        .d(alu_res),
        .q(alu_out)
    );
    
    //write address select
    assign rf_wa = linkWrite ? 5'd31: //jal
                   (regDst ? rd : rt);  //0:rt 1:rd
    //write data select
    assign rf_wd = linkWrite ? pc_curr + 4: //jal stores return addr
                   (memtoReg ? mdr : alu_out);
                   
    RegisterFile RF(
        .clk(clk),
        .regWrite(regWrite | linkWrite),
        .readReg1(rs),
        .readReg2(rt),
        .writeReg(rf_wa),
        .writeData(rf_wd),
        .readData1(rf_rd1),
        .readData2(rf_rd2)
    );
    //Immediate Units
    SignExtend SE(
        .in(ir[15:0]),
        .out(sign_imm)
    );
    ShiftLeft2 SL2(
        .in(sign_imm),
        .out(imm_shift2)
    );
    //ALU source multiplexers
    assign alu_in_a = (aluSrcA) ? A : pc_curr;
    assign alu_in_b = (aluSrcB == 2'b00) ? B :  //0 : B-register
                      (aluSrcB == 2'b01) ? 32'd4 :  //1: constant 4
                      (aluSrcB == 2'b10) ? sign_imm :   //2: sign-extended imm
                                            imm_shift2; //3: imm<<2
    //ALU and Control
    alu_control ALU_CTRL(
        .funct(ir[5:0]),
        .aluOp(aluOp),
        .aluControl(alu_ctrl)
    );
    alu ALU(
        .a(alu_in_a),
        .b(alu_in_b),
        .control(alu_ctrl),
        .shamt(ir[10:6]),
        .res(alu_res),
        .zero(zero_flag)
    );
    //PC next selection
    wire [31:0] jump_addr = {pc_curr[31:28], ir[25:0], 2'b00};
    reg [31:0] pc_mux_out;
    always@(*) begin
        case(pcSource)
            2'b00: pc_mux_out = alu_res;    //from ALU(PC+4)
            2'b01: pc_mux_out = alu_out;    //branch target
            default: pc_mux_out = jump_addr; //jump/jal
        endcase
    end
    
    wire pc_en = pcWrite | (pcWriteCond & ((opcode==6'b000100) ? zero_flag : //beq
                                           (opcode==6'b000101) ? ~zero_flag :
                                                               1'b0));
    assign pc_next = pc_en ? pc_mux_out : pc_curr; //hold if not enabled
    //Control FSM
    control_fsm fsm(
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .zero(zero_flag),
        .pcWrite(pcWrite),
        .pcWriteCond(pcWriteCond),
        .IorD(IorD),
        .memRead(memRead),
        .memWrite(memWrite),
        .IRwrite(IRwrite),
        .pcSource(pcSource),
        .aluSrcA(aluSrcA),
        .aluSrcB(aluSrcB),
        .aluOp(aluOp),
        .regWrite(regWrite),
        .regDst(regDst),
        .memtoReg(memtoReg),
        .linkWrite(linkWrite),
        .ALUOutWrite(ALUOutWrite),
        .MDRWrite(MDRWrite)
    );
          
endmodule
