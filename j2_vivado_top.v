`include "common.h"

module j2_top(
    input wire clock,
    input wire active_low_reset,
    
    // Uart in and out
    input  wire RXD,
    output wire TXD,
    
    // Led outputs
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
    output reg led15,
    output reg led16
);
    localparam MHZ = 40;
    wire fclk;

    wire [15:0] instruction;
    wire [12:0] instruction_address;
    wire [`WIDTH-1:0] memory_data_in;
    wire [15:0] memory_address;

    wire [`WIDTH-1:0] io_data_in;
    wire memory_write_enable;
    wire io_write_enable;
    wire [`WIDTH-1:0] data_out;
    
    //sim_clock sim_clk (
    //    .clock(clock)
    //);
    
    always @(posedge clock) begin
        if(io_write_enable) begin
            case (data_out[8:0])
                8'b0000_0001: led01 <= 1'b1;
                8'b0000_0010: led02 <= 1'b1;
                8'b0000_0011: led03 <= 1'b1;
                8'b0000_0100: led04 <= 1'b1;
                8'b0000_0101: led05 <= 1'b1;
                8'b0000_0110: led06 <= 1'b1;
                8'b0000_0111: led07 <= 1'b1;
                8'b0000_1000: led08 <= 1'b1;
                8'b0000_1001: led09 <= 1'b1;
                8'b0000_1010: led10 <= 1'b1;
                8'b0000_1011: led11 <= 1'b1;
                8'b0000_1100: led12 <= 1'b1;
                8'b0000_1101: led13 <= 1'b1;
                8'b0000_1110: led14 <= 1'b1;
                8'b0000_1111: led15 <= 1'b1;
                8'b0001_0000: led16 <= 1'b1;
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
    
    wire uart0_valid, uart0_busy;
    wire [7:0] uart0_data;
    wire uart0_rd, uart0_wr;
    reg [31:0] baud = 32'd115200;
    wire UART0_RX;
    buart #(.CLKFREQ(MHZ * 1000000)) _uart0 (
       .clk(fclk),
       .resetq(1'b1),
       .baud(baud),
       .rx(RXD),
       .tx(TXD),
       .rd(uart0_rd),
       .wr(uart0_wr),
       .valid(uart0_valid),
       .busy(uart0_busy),
       .tx_data(data_out[7:0]),
       .rx_data(uart0_data)
    );
    
    reg io_wr_;
    reg [15:0] mem_addr_;
    reg [31:0] dout_;
    always @(posedge fclk)
        {io_wr_, mem_addr_, dout_} <= {io_write_enable, memory_address, data_out};
    
    assign uart0_wr = io_wr_ & (mem_addr_ == 16'h0000);
    assign uart0_rd = io_wr_ & (mem_addr_ == 16'h0002);

    
    // multiplexer - case block , wann in ram schreiben pder wann 
    
    memory_ram main_ram (
        .clock(clock),
        .instruction_address(instruction_address),
        .instruction(instruction),
        
        .memory_address(memory_address),
        .memory_data_in(data_out),
        .memory_data_out(memory_data_in),
        .memory_write_enable(memory_write_enable)
    );
    
endmodule
