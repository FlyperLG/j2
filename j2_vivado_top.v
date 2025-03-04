`include "common.h"

module j2_top(
    input wire clock,
    input wire active_low_reset,
    
    // Uart in and out
    input  wire RXD,
    output wire TXD,
    
    // Led outputs
    output wire led00,
    output wire led01,
    output wire led02,
    output wire led03,
    output wire led04,
    output wire led05,
    output wire led06,
    output wire led07,
    output wire led08,
    output wire led09,
    output wire led10,
    output wire led11,
    output wire led12,
    output wire led13,
    output wire led14,
    output wire led15
);
    localparam MHZ = 100;

    wire [15:0] instruction;
    wire [12:0] instruction_address;
    wire [`WIDTH-1:0] memory_data_in;
    wire [15:0] memory_address;

    wire memory_write_enable;
    wire io_write_enable;
    wire [`WIDTH-1:0] data_out;
    
    //sim_clock sim_clk (
    //    .clock(clock)
    //);
    
    io_manager io (
        .clock(clock),
        .active_low_reset(active_low_reset),
        .io_write_enable(io_write_enable),
        .memory_address(memory_address),
        .data(data_out),
        
        .led00(led00),
        .led01(led01),
        .led02(led02),
        .led03(led03),
        .led04(led04),
        .led05(led05),
        .led06(led06),
        .led07(led07),
        .led08(led08),
        .led09(led09),
        .led10(led10),
        .led11(led11),
        .led12(led12),
        .led13(led13),
        .led14(led14),
        .led15(led15)
    );

    j2 j2_core (
        .clock(clock),
        .active_low_reset(active_low_reset),
        
        .instruction(instruction),
        .instruction_address(instruction_address),
        
        .memory_data_in(memory_data_in),
        .memory_write_enable(memory_write_enable),
        .memory_address(memory_address),
        .io_data_in({17'd0, uart0_data, 4'd0, 1'd0, 1'd0, 1'd0}),
        .io_write_enable(io_write_enable),
        .data_out(data_out)
    );
    
    wire uart0_valid, uart0_busy;
    wire [7:0] uart0_data;
    wire uart0_rd, uart0_wr;
    reg [31:0] baud = 32'd9600;
    buart #(.CLKFREQ(MHZ * 1000000)) _uart0 (
       .clk(clock),
       .resetq(active_low_reset),
       .baud(baud),
       .rx(RXD),
       .tx(TXD),
       .rd(uart0_rd),
       .wr(uart0_wr),
       .valid(uart0_valid),
       .busy(uart0_busy),
       .tx_data(dout_[7:0]),
       .rx_data(uart0_data)
    );
    
    reg io_wr_;
    reg [15:0] mem_addr_;
    reg [7:0] dout_;
    always @(posedge clock) begin
        io_wr_ <= io_write_enable;
        mem_addr_ <= memory_address;
        dout_ <= data_out;
    end
    
    assign uart0_wr = io_wr_ & (mem_addr_ == 16'h00F0);
    assign uart0_rd = io_wr_ & (mem_addr_ == 16'h00F1);

    
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
