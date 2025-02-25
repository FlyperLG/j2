`include "common.h"

module j2(
    input wire clock,
    input wire active_low_reset,

    input wire [15:0] instruction,
    output wire [12:0] instruction_address,

    input wire [`WIDTH-1:0] memory_data_in,
    output wire memory_write_enable,
    output wire [15:0] memory_address,

    input wire [`WIDTH-1:0] io_data_in,
    output wire io_write_enable,

    output wire [`WIDTH-1:0] data_out
);

reg is_reboot = 1;

reg [12:0] program_counter;
wire [12:0] program_counter_next;
assign instruction_address = {program_counter_next};

// Data stack
reg [`DEPTH-1:0] data_stack_pointer_top;
reg [`WIDTH-1:0] data_stack_top;
wire data_stack_write_enable;
wire [`DEPTH-1:0] data_stack_pointer_second;
wire [`WIDTH-1:0] data_stack_second;
stack #(.DEPTH(`DEPTH)) data_stack (
    .clock(clock),
    //.active_low_reset(active_low_reset),
    .read_address(data_stack_pointer_top),
    .read_data(data_stack_second),
    .write_enable(data_stack_write_enable),
    .write_address(data_stack_pointer_second),
    .write_data(data_stack_top)
);

// Return stack
reg [`DEPTH-1:0] return_stack_pointer_top;
wire [`WIDTH-1:0] return_stack_top;
wire return_stack_write_enable;
wire [`DEPTH-1:0] return_stack_pointer_second;
wire [`WIDTH-1:0] return_stack_second;
stack #(.DEPTH(`DEPTH)) return_stack (
    .clock(clock),
    //.active_low_reset(active_low_reset),
    .read_address(return_stack_pointer_top),
    .read_data(return_stack_top),
    .write_enable(return_stack_write_enable),
    .write_address(return_stack_pointer_second),
    .write_data(return_stack_second)
);

wire [`WIDTH-1:0] data_stack_next_top; // Changed from reg to wire
assign memory_address = data_stack_next_top[15:0];
alu alu1 (
    // Input
    .instruction(instruction),

    .data_stack_pointer_top(data_stack_pointer_top),
    .data_stack_top(data_stack_top),
    .data_stack_second(data_stack_second),

    .return_stack_pointer_top(return_stack_pointer_top),
    .return_stack_top(return_stack_top),

    .memory_data_in(memory_data_in),
    .io_data_in(io_data_in),
    .is_reboot(is_reboot),
    .program_counter(program_counter),

    // Output
    .program_counter_next(program_counter_next),
    .data_stack_next_top(data_stack_next_top), // Now connected to a wire
    .data_stack_pointer_second(data_stack_pointer_second),
    .data_stack_write_enable(data_stack_write_enable),
    
    .return_stack_pointer_second(return_stack_pointer_second),
    .return_stack_second(return_stack_second),
    .return_stack_write_enable(return_stack_write_enable),

    .io_write_enable(io_write_enable),
    .memory_write_enable(memory_write_enable),

    .data_out(data_out)
);

always @(negedge active_low_reset or posedge clock) begin
    if(!active_low_reset) begin
        is_reboot <= 1'b1;
        { program_counter, data_stack_pointer_top, data_stack_top, return_stack_pointer_top } <= 0;
    end else begin
        is_reboot <= 0;
        { program_counter, data_stack_pointer_top, data_stack_top, return_stack_pointer_top } <= { program_counter_next, data_stack_pointer_second, data_stack_next_top, return_stack_pointer_second };
    end
end

endmodule