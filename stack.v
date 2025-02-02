`include "common.h"
module stack #(parameter DEPTH = 4)
(
    input wire clock,
    input wire active_low_reset,
    input wire [DEPTH-1:0] read_address,
    output wire [`WIDTH-1:0] read_data,
    input wire write_enable,
    input wire [DEPTH-1:0] write_address,
    input wire [`WIDTH-1:0] write_data
);

// Memory array to store the stack data
reg [`WIDTH-1:0] memory_storage[0:(2**DEPTH)-1];

// Write operation:
always @(posedge clock)
    if (write_enable)
        memory_storage[write_address] <= write_data;

// Read operation
assign read_data = memory_storage[read_address];
endmodule