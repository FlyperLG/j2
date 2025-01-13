`include "common.h"

module alu (
    input wire [15:0] instruction

    input wire [`WIDTH-1:0] data_stack_current_top;
    input wire [`WIDTH-1:0] data_stack_current_next_top;

    input wire [`WIDTH-1:0] return_stack_current_top;


    input wire [`WIDTH-1:0] memory_data_in;
    input wire [`WIDTH-1:0] io_data_in;

    // input is an register does this one need to be an register as well?
    output wire [`WIDTH-1:0] data_stack_next_value
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
            8'b011_?1110: data_stack_next_value = {{(`WIDTH - 8){1'b0}}, rsp, dsp};
            8'b011_?1111: data_stack_next_value = {`WIDTH{(data_stack_current_top < data_stack_current_next_top)}};
            default: data_stack_next_value = {`WIDTH{1'bx}};
        endcase
    end

endmodule