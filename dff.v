module dff (
    input  wire clk,
    input  wire rst,
    input  wire d,
    output reg  q
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            q <= 1'b0;
        else
            q <= d;
    end
endmodule


`timescale 1ns / 1ps

module dff_tb;

    // Testbench signals
    reg clk;
    reg rst;
    reg d;
    wire q;

    // Instantiate the D Flip-Flop
    dff uut (
        .clk(clk),
        .rst(rst),
        .d(d),
        .q(q)
    );

    // Clock generation (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // Initialize inputs
        rst = 1; d = 0;
        #12;         // asynchronous reset
        rst = 0;     // deassert reset

        d = 1; #10;
        d = 0; #10;
        d = 1; #10;
        d = 1; #10;
        d = 0; #10;
        rst = 1; #10; // apply reset again
        rst = 0; #10;
        d = 1; #10;

        $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time=%0t | clk=%b rst=%b d=%b q=%b", $time, clk, rst, d, q);
    end

endmodule
