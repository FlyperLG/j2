`include "common.h"

module j1(
    input wire clock,
    input wire active_low_reset,

    output wire io_write_enable,
    output wire [15:0] memory_address,
    output wire memory_write_enable,
    output wire [`WIDTH-1:0] data_out,

    input wire [`WIDTH-1:0] memory_data_in,
    input wire [`WIDTH-1:0] io_data_in,

    output wire [12:0] instruction_address,
    input wire [15:0] instruction
);
reg is_reboot = 1;

reg [12:0] program_counter, program_counter_next;
wire [12:0] program_counter_incremented = program_counter + 1;
assign instruction_address = {program_counter_next};

// Data & return stacks
reg [`DEPTH-1:0] data_stack_pointer;
wire [`WIDTH-1:0] data_stack_current_top;
reg data_stack_write_enable;
reg [`DEPTH-1:0] data_stack_pointer_next;
reg [`WIDTH-1:0] data_stack_current_top_next
stack #(.DEPTH(`DEPTH)) data_stack (
    .clock(clock),
    .active_low_reset(active_low_reset),
    .read_address(data_stack_pointer),
    .read_data(data_stack_current_top),
    .write_enable(data_stack_write_enable),
    .write_address(data_stack_pointer_next),
    .write_data(data_stack_current_top_next)
);

reg [`DEPTH-1:0] return_stack_pointer;
wire [`WIDTH-1:0] return_stack_current_top;
reg return_stack_write_enable;
reg [`DEPTH-1:0] return_stack_pointer_next;
wire [`WIDTH-1:0] return_stack_current_top_next;
stack #(.DEPTH(`DEPTH)) return_stack (
    .clock(clock)
    .active_low_reset(active_low_reset),
    .read_address(return_stack_pointer),
    .read_data(return_stack_current_top),
    .write_enable(return_stack_write_enable),
    .write_address(return_stack_pointer_next),
    .write_data(return_stack_current_top_next)
);


assign memory_address = data_stack_top_next[15:0];
reg [`WIDTH-1:0] data_stack_top_next;
alu alu1 (
    .instruction(instruction)
    .data_stack_current_top(data_stack_next_value)
    .data_stack_current_next_top(data_stack_top)
    .return_stack_current_top(return_stack_top_value)
    .memory_data_in(memory_data_in)
    .io_data_in(io_data_in)
    // ask if this works fine since the data_stack_top_next is assignt to memory_address
    .data_stack_next_value(data_stack_top_next)
);

// Instruction Decoding & ALU operations
//always @* begin
//   8'b1??_?????: data_stack_top_next = {{(`WIDTH - 15){1'b0}}, instruction[14:0]}; // Literal
//   8'b000_?????: data_stack_top_next = data_stack_top; // Jump
//    8'b010_?????: data_stack_top_next = data_stack_top; // Call
//    8'b001_?????: data_stack_top_next = data_stack_next_value; // Conditional Jump
//end

endmodule