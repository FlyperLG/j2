`include "common.h"

module alu (
    input wire [15:0] instruction

    input wire [`DEPTH-1:0] data_stack_read_position;
    input wire [`WIDTH-1:0] data_stack_current_top;
    input wire [`WIDTH-1:0] data_stack_current_next_top;

    input wire [`DEPTH-1:0] return_stack_read_position;
    input wire [`WIDTH-1:0] return_stack_current_top;

    input wire [`WIDTH-1:0] memory_data_in;
    input wire [`WIDTH-1:0] io_data_in;
    input wire reboot;


    output reg [12:0] program_counter_next_value;
    // Solved: input is an register does this one need to be an register as well?
    output reg [`WIDTH-1:0] data_stack_next_value;
    output reg [`WIDTH-1:0] data_stack_next_write_position;
    output reg data_stack_next_write;

    output reg [`WIDTH-1:0] return_stack_next_write_position;
    output reg return_stack_next_write;

    output wire function_io_write;
    output wire ;
);

    always @(instruction) begin
        casez ({instruction[15:8]})
            8'b1??_?????: data_stack_next_value = { {(`WIDTH - 15){1'b0}}, instruction[14:0] };     // literal
            8'b000_?????: data_stack_next_value = data_stack_current_next_top;                      // jump
            8'b010_?????: data_stack_next_value = data_stack_current_next_top;                      // call
            8'b001_?????: data_stack_next_value = data_stack_current_top;                           // conditional jump
            8'b011_?0000: data_stack_next_value = data_stack_current_next_top;                      // ALU operations...
            8'b011_?0001: data_stack_next_value = data_stack_current_top;
            8'b011_?0010: data_stack_next_value = data_stack_current_next_top + data_stack_current_top;
            8'b011_?0011: data_stack_next_value = data_stack_current_next_top & data_stack_current_top;
            8'b011_?0100: data_stack_next_value = data_stack_current_next_top | data_stack_current_top;
            8'b011_?0101: data_stack_next_value = data_stack_current_next_top ^ data_stack_current_top;
            8'b011_?0110: data_stack_next_value = ~data_stack_current_next_top;
            8'b011_?0111: data_stack_next_value = {`WIDTH{(data_stack_current_top == data_stack_current_next_top)}};
            8'b011_?1000: data_stack_next_value = {`WIDTH{($signed(data_stack_current_top) < $signed(data_stack_current_next_top))}};
            8'b011_?1001: data_stack_next_value = data_stack_current_top >> data_stack_current_next_top[4:0];
            8'b011_?1010: data_stack_next_value = data_stack_current_top << data_stack_current_next_top[4:0];
            8'b011_?1011: data_stack_next_value = return_stack_current_top;
            8'b011_?1100: data_stack_next_value = memory_data_in;
            8'b011_?1101: data_stack_next_value = io_data_in;
            8'b011_?1110: data_stack_next_value = {{(`WIDTH - 8){1'b0}}, return_stack_read_position, data_stack_read_position};
            8'b011_?1111: data_stack_next_value = {`WIDTH{(data_stack_current_top < data_stack_current_next_top)}};
            default: data_stack_next_value = {`WIDTH{1'bx}};
        endcase
    end

    wire function_data_stack_write = (instruction[6:4] == 1);
    wire function_return_stack_write = (instruction[6:4] == 2);
    function_io_write = (instruction[6:4] == 4);
    function_memory_write = (instruction[6:4] == 3);

    always @({instruction}) begin

        wire [2:0] data_stack_position_incrementer;
        casez (instruction[15:13])
            3'b1??: {data_stack_next_write, data_stack_position_incrementer} = {1'b1, 4'0001};
            3'b001: {data_stack_next_write, data_stack_position_incrementer} = {1'b0, 4'b1111};
            3'b011: {data_stack_next_write, data_stack_position_incrementer} = {function_data_stack_write, {instruction[1], instruction[1], instruction[1:0]}};
            default: {data_stack_next_write, data_stack_position_incrementer} = {1'b0, 4'b0000};
        endcase
        assign data_stack_next_write_position = data_stack_read_position + data_stack_position_incrementer;

        wire [2:0] return_stack_position_incrementer;
        casez (instruction[15:13])
            3'b010: {return_stack_next_write, return_stack_position_incrementer} = {1'b1, 4'0001};
            3'b011: {return_stack_next_write, return_stack_position_incrementer} = {function_return_stack_write, {instruction[3], instruction[3], instruction[3:2]}};
            default: {return_stack_next_write, return_stack_position_incrementer} = {1'b0, 4'b0000};
        endcase
        assign return_stack_next_write_position = return_stack_read_position + return_stack_position_incrementer;
        
        
        wire [12:0] program_counter_incremented = program_counter + 1;
        casez ({reboot, instruction[15:13], instruction[7], |data_stack_current_next_top})
            6'b1_???_?_?: program_counter_next_value = 0;
            6'b0_000_?_?: program_counter_next_value = instruction[12:0];
            6'b0_010_?_?: program_counter_next_value = instruction[12:0];
            6'b0_001_?_?: program_counter_next_value = instruction[12:0];
            6'b0_011_1_?: program_counter_next_value = return_stack_current_top[13:1];
            default: program_counter_next_value = program_counter_incremented;
        endcase
    end

endmodule