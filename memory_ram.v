`include "common.h"

module memory_ram(
    input wire clock,
    
    input wire [12:0] instruction_address,
    output reg [15:0] instruction,
    
    input wire [15:0] memory_address,
    input wire memory_write_enable,
    input wire [`WIDTH-1:0] memory_data_in,
    output reg [`WIDTH-1:0] memory_data_out
);
    
    reg [15:0] memory [0:32-1];
    initial begin
        // led01
        memory[0] = 16'b1000000000000001;
        memory[1] = 16'b0110000001000000;
        // led02
        memory[2] = 16'b1000000000000010;
        memory[3] = 16'b0110000001000000;
        // led03
        memory[4] = 16'b1000000000000011;
        memory[5] = 16'b0110000001000000;
        // led04
        memory[6] = 16'b1000000000000100;
        memory[7] = 16'b0110000001000000;
        // led05
        memory[8] = 16'b1000000000000101;
        memory[9] = 16'b0110000001000000;
        // led06
        memory[10] = 16'b1000000000000110;
        memory[11] = 16'b0110000001000000;
        // led07
        memory[12] = 16'b1000000000000111;
        memory[13] = 16'b0110000001000000;
        // led08
        memory[14] = 16'b1000000000001000;
        memory[15] = 16'b0110000001000000;
        // led09
        memory[16] = 16'b1000000000001001;
        memory[17] = 16'b0110000001000000;
        // led10
        memory[18] = 16'b1000000000001010;
        memory[19] = 16'b0110000001000000;
        // led11
        memory[20] = 16'b1000000000001011;
        memory[21] = 16'b0110000001000000;
        // led12
        memory[22] = 16'b1000000000001100;
        memory[23] = 16'b0110000001000000;
        // led13
        memory[24] = 16'b1000000000001101;
        memory[25] = 16'b0110000001000000;
        // led14
        memory[26] = 16'b1000000000001110;
        memory[27] = 16'b0110000001000000;
        // led15
        memory[28] = 16'b1000000000001111;
        memory[29] = 16'b0110000001000000;
        // led16
        memory[30] = 16'b1000000000010000;
        memory[31] = 16'b0110000001000000;
        
        memory[32] = 16'b0000000000000000;
    end

    always @(posedge clock) begin
        instruction <= memory[instruction_address];
    end
    
    always @(posedge clock) begin
        memory_data_out <= memory[memory_address];
        if(memory_write_enable) begin
            memory_data_out <= memory_data_in;
            memory[memory_address] <= memory_data_in;
        end
    end
    
endmodule
