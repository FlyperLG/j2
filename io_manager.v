`include "common.h"

module io_manager(
    input wire clock,
    input wire active_low_reset,
    input wire io_write_enable,
    input wire [15:0] memory_address,
    input wire [`WIDTH-1:0] data,
    
    // Led outputs
    output reg led00,
    output reg led01,
    output reg led02,
    output reg led03,
    output reg led04,
    output reg led05,
    output reg led06,
    output reg led07,
    output reg led08,
    output reg led09,
    output reg led10,
    output reg led11,
    output reg led12,
    output reg led13,
    output reg led14,
    output reg led15
);
    
    
    always @(negedge active_low_reset or posedge clock) begin
        if(!active_low_reset) begin
            led00 <= 1'b0;
            led01 <= 1'b0;
            led02 <= 1'b0;
            led03 <= 1'b0;
            led04 <= 1'b0;
            led05 <= 1'b0;
            led06 <= 1'b0;
            led07 <= 1'b0;
            led08 <= 1'b0;
            led09 <= 1'b0;
            led10 <= 1'b0;
            led11 <= 1'b0;
            led12 <= 1'b0;
            led13 <= 1'b0;
            led14 <= 1'b0;
            led15 <= 1'b0;
        end else begin
            if(io_write_enable) begin
                case (memory_address[8:0])
                    8'b0000_0001: led00 <= data[0];
                    8'b0000_0010: led01 <= data[0];
                    8'b0000_0011: led02 <= data[0];
                    8'b0000_0100: led03 <= data[0];
                    8'b0000_0101: led04 <= data[0];
                    8'b0000_0110: led05 <= data[0];
                    8'b0000_0111: led06 <= data[0];
                    8'b0000_1000: led07 <= data[0];
                    8'b0000_1001: led08 <= data[0];
                    8'b0000_1010: led09 <= data[0];
                    8'b0000_1011: led10 <= data[0];
                    8'b0000_1100: led11 <= data[0];
                    8'b0000_1101: led12 <= data[0];
                    8'b0000_1110: led13 <= data[0];
                    8'b0000_1111: led14 <= data[0];
                    8'b0001_0000: led15 <= data[0];
                endcase
            end
        end
    end
endmodule
