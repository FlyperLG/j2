module sim_clock(
        output reg clock
    );
    
    parameter clock_period=10;

always
    #(clock_period/2) clock=~clock;
initial begin
    clock=0;
    #1000 $finish; // You can put the delay as per your requirement.
end
    
endmodule