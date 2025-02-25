`include "common.h"

module memory_ram(
    input wire clock,
    input wire [12:0] read_address,

    output reg [15:0] value
    );
    
    reg [15:0] memory [0:32-1];
    initial begin
        memory[0] = 16'b1000000000000001;
        memory[1] = 16'b0110000001000000;
        memory[2] = 16'b1000000000000010;
        memory[3] = 16'b0110000001000000;
        memory[4] = 16'b0000000000000000;
    end

    always @(posedge clock) begin
        value = memory[read_address];
    end
    
endmodule