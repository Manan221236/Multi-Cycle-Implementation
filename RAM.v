`timescale 1ns/1ps
module RAM(
    input wire clk, memRead, memWrite,
    input wire [31:0] addr, data_in,
    output reg [31:0] data_out
);
    parameter MEM_SIZE = 2**30; 
    reg [31:0] mem [0:MEM_SIZE-1]; 
    //initial begin
        //$readmemh("C:/Users/manan/CA_Project/CA_Project.sim/sim_1/behav/data.hex",mem);
    //end
    //MEMORY WRITE WHEN memWrite=1
    always@(posedge clk)begin
        if(memWrite)begin
            if((addr<<2)<MEM_SIZE)begin
                mem[addr[31:2]] <= data_in;//Since every address is different by 4 we omit the last bits which are 00. This is done for word alignment.
            end
        end
    end
    //MEMORY READ WHEN memRead=1
    always@(*)begin
        if(memRead)begin
            if((addr<<2)<MEM_SIZE)
                data_out = mem[addr[31:2]];//Since every address is different by 4 we omit the last bits which are 00. This is done for word alignment.
            else
                data_out = 32'b0;
            end else begin
            data_out = 32'b0;
        end
    end
            
endmodule