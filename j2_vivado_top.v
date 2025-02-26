`include "common.h"

module j2_vivado_top(
    input wire clock,
    input wire active_low_reset,
    
    
    output reg led01,
    output reg led02,
    output reg led03
);
    
    wire [15:0] instruction;
    wire [12:0] instruction_address;
    wire [`WIDTH-1:0] memory_data_in;
    wire [15:0] memory_address;

    wire [`WIDTH-1:0] io_data_in;
    wire memory_write_enable;
    wire io_write_enable;
    wire [`WIDTH-1:0] data_out;
    
    always @(posedge clock) begin
        if(io_write_enable) begin
            case (data_out[8:0])
                8'b0000_0001: led01 <= 1'b1;
                8'b0000_0010: led02 <= 1'b1;
            endcase
        end
        
        led03 <= 1'b1;
    end

    j2 j2_core (
        .clock(clock),
        .active_low_reset(active_low_reset),
        .instruction(instruction),
        .instruction_address(instruction_address),
        .memory_data_in(memory_data_in),
        .memory_write_enable(memory_write_enable),
        .memory_address(memory_address),
        .io_data_in(io_data_in),
        .io_write_enable(io_write_enable),
        .data_out(data_out)
    );
    
    // multiplexer - case block , wann in ram schreiben pder wann 
    
    memory_ram main_ram (
        .clock(clock),
        .read_address(instruction_address),
        .value(instruction)
    );
    
endmodule
