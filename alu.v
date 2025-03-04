`include "common.h"

module alu (
    input wire [15:0] instruction,

    input wire [`DEPTH-1:0] data_stack_pointer_top,
    input wire [`WIDTH-1:0] data_stack_top,
    input wire [`WIDTH-1:0] data_stack_second,

    input wire [`DEPTH-1:0] return_stack_pointer_top,
    input wire [`WIDTH-1:0] return_stack_top,

    input wire [`WIDTH-1:0] memory_data_in,
    input wire [`WIDTH-1:0] io_data_in,
    input wire is_reboot,
    input wire [12:0] program_counter,


    output reg [12:0] program_counter_next,
    output reg [`WIDTH-1:0] data_stack_next_top,
    output reg [`DEPTH-1:0] data_stack_pointer_second,
    output reg data_stack_write_enable,

    output reg [`DEPTH-1:0] return_stack_pointer_second,
    output wire [`WIDTH-1:0] return_stack_second,
    output reg return_stack_write_enable,

    output wire io_write_enable,
    output wire memory_write_enable,

    output wire [`WIDTH-1:0] data_out
);

    always @* begin
        casez ({instruction[15:8]})
            8'b1??_?????: data_stack_next_top = { {(`WIDTH - 15){1'b0}}, instruction[14:0] };     // literal
            8'b000_?????: data_stack_next_top = data_stack_top;                         // jump
            8'b010_?????: data_stack_next_top = data_stack_top;                         // call
            8'b001_?????: data_stack_next_top = data_stack_second;                      // conditional jump
            8'b011_?0000: data_stack_next_top = data_stack_top;                         // ALU operations...
            8'b011_?0001: data_stack_next_top = data_stack_second; 
            8'b011_?0010: data_stack_next_top = data_stack_top + data_stack_second;
            8'b011_?0011: data_stack_next_top = data_stack_top & data_stack_second;
            8'b011_?0100: data_stack_next_top = data_stack_top | data_stack_second;
            8'b011_?0101: data_stack_next_top = data_stack_top ^ data_stack_second;
            8'b011_?0110: data_stack_next_top = ~data_stack_top;
            8'b011_?0111: data_stack_next_top = {`WIDTH{(data_stack_second == data_stack_top)}};
            8'b011_?1000: data_stack_next_top = {`WIDTH{($signed(data_stack_second) < $signed(data_stack_top))}};
            8'b011_?1001: data_stack_next_top = data_stack_second >> data_stack_top[4:0];
            8'b011_?1010: data_stack_next_top = data_stack_second << data_stack_top[4:0];
            8'b011_?1011: data_stack_next_top = return_stack_top;
            8'b011_?1100: data_stack_next_top = memory_data_in;
            8'b011_?1101: data_stack_next_top = io_data_in;
            8'b011_?1110: data_stack_next_top = {{(`WIDTH - 8){1'b0}}, return_stack_pointer_top, data_stack_pointer_top};
            8'b011_?1111: data_stack_next_top = {`WIDTH{(data_stack_second < data_stack_top)}};
            default: data_stack_next_top = {`WIDTH{1'bx}};
        endcase
    end

    // Memory / IO Write (vibe) check
    wire instruction_is_alu = (instruction[15:13] == 3'b011);

    wire function_data_stack_write = (instruction[6:4] == 1);
    wire function_return_stack_write = (instruction[6:4] == 2);
    wire function_io_write = (instruction[6:4] == 4);
    wire function_memory_write = (instruction[6:4] == 3);

    assign io_write_enable = !is_reboot & instruction_is_alu & function_io_write;
    assign memory_write_enable = !is_reboot & instruction_is_alu & function_memory_write;

    assign data_out = data_stack_second;
    
    // rx und tx auslesen
    
    // Probably all need `DEPTH-1 instead of 2 (streit: fixed a possible of by one)
    reg [`DEPTH - 1:0] data_stack_position_incrementer;
    reg [`DEPTH - 1:0] return_stack_position_incrementer;
    reg [12:0] program_counter_incremented;

    assign return_stack_second = (instruction[13] == 1'b0) ? {{(`WIDTH - 14){1'b0}}, program_counter_incremented} : data_stack_top;

    // ({instruction} Why does it continue after each run?
    always @* begin
        program_counter_incremented = program_counter + 1;
        casez (instruction[15:13])
            3'b1??: {data_stack_write_enable, data_stack_position_incrementer} = {1'b1, {{(`DEPTH - 1){1'b0}}, 1'b1 }};
            3'b001: {data_stack_write_enable, data_stack_position_incrementer} = {1'b0, {{(`DEPTH){1'b1}}}};
            3'b011: {data_stack_write_enable, data_stack_position_incrementer} = {function_data_stack_write, { {(`DEPTH - 2){instruction[1]}}, instruction[1:0] }};
            default: {data_stack_write_enable, data_stack_position_incrementer} = {1'b0, {{(`DEPTH){1'b0}}}};
        endcase
        data_stack_pointer_second <= data_stack_pointer_top + data_stack_position_incrementer;

        casez (instruction[15:13])
            3'b010: {return_stack_write_enable, return_stack_position_incrementer} = {1'b1, {{(`DEPTH - 1){1'b0}}, 1'b1 }};
            3'b011: {return_stack_write_enable, return_stack_position_incrementer} = {function_return_stack_write, { {(`DEPTH - 2){instruction[3]}}, instruction[3:2] }};
            default: {return_stack_write_enable, return_stack_position_incrementer} = {1'b0, {{(`DEPTH){1'b0}}}};
        endcase
        return_stack_pointer_second <= return_stack_pointer_top + return_stack_position_incrementer;
        
        casez ({is_reboot, instruction[15:13], instruction[7], |data_stack_top})
            6'b1_???_?_?: program_counter_next = 0;
            6'b0_000_?_?: program_counter_next = instruction[12:0];
            6'b0_010_?_?: program_counter_next = instruction[12:0];
            6'b0_001_?_0: program_counter_next = instruction[12:0];
            6'b0_011_1_?: program_counter_next = return_stack_top[13:1];
            default: program_counter_next = program_counter_incremented;
        endcase
    end

endmodule