`timescale 1ns/1ps
module tb_multicycle;
   //---------------------------------------------------------------
   //  100 MHz clock + one-shot reset
   //---------------------------------------------------------------
   reg clk   = 0;
   reg reset = 1;
   always #5 clk = ~clk;      // 10 ns period
   initial #20 reset = 0;     // reset high for two cycles

   //---------------------------------------------------------------
   //  DUT
   //---------------------------------------------------------------
   MCI dut ( .clk(clk), .reset(reset) );

   //---------------------------------------------------------------
   //  Instruction Decode for printing
   //---------------------------------------------------------------
   reg [8*8:1] instr_str;
   always @(*) begin
      // Default
      instr_str = "UNK     ";
      case (dut.ir[31:26])
        6'h00:  // R-type
          case (dut.ir[5:0])
            6'h20: instr_str = "ADD     ";
            6'h22: instr_str = "SUB     ";
            6'h24: instr_str = "AND     ";
            6'h25: instr_str = "OR      ";
            6'h2A: instr_str = "SLT     ";
            6'h02: instr_str = "SRL     ";
            default: instr_str = "R-UNK   ";
          endcase
        6'h23: instr_str = "LW      ";
        6'h2B: instr_str = "SW      ";
        6'h04: instr_str = "BEQ     ";
        6'h05: instr_str = "BNE     ";
        6'h02: instr_str = "J       ";
        6'h03: instr_str = "JAL     ";
        6'h0B: instr_str = "SLTIU   ";
        6'h25: instr_str = "LHU     ";
      endcase
   end

   //---------------------------------------------------------------
   //  Unified memory preload
   //---------------------------------------------------------------
   initial begin
      $readmemh("C:/Users/manan/CA_Project/CA_Project.sim/sim_1/behav/inst_and_data.hex",
                dut.memory.mem);
   end

   //---------------------------------------------------------------
   //  *** Initialise registers once reset releases ***
   //---------------------------------------------------------------
   initial begin
      @(negedge reset);
      force dut.RF.regfile[9]  = 32'd7;          // $t1 = 7
      force dut.RF.regfile[10] = 32'd3;          // $t2 = 3
      force dut.RF.regfile[28] = 32'h0000_0100;  // $gp = 0x100
      #20;
      release dut.RF.regfile[9];
      release dut.RF.regfile[10];
      release dut.RF.regfile[28];
   end

   //---------------------------------------------------------------
   //  Waveform dump
   //---------------------------------------------------------------
   initial begin
      $dumpfile("multicycle.vcd");
      $dumpvars(0, tb_multicycle);
   end

   //---------------------------------------------------------------
   //  Cycle-by-cycle trace including mnemonic
   //---------------------------------------------------------------
   always @(posedge clk) begin
      $display("T=%0t  PC=%08h  IR=%08h (%s) |",
               $time, dut.pc_curr, dut.ir, instr_str);
      $display("  $t0=%08h $t1=%08h $t2=%08h $t3=%08h",
               dut.RF.regfile[8], dut.RF.regfile[9],
               dut.RF.regfile[10], dut.RF.regfile[11]);
      $display("  MEM[0x108]=%08h",
               dut.memory.mem[66]);
      $display("-----------------------------------------");
   end

   //---------------------------------------------------------------
   //  Stop after 1 µs
   //---------------------------------------------------------------
   initial #1000000 $finish;
endmodule
