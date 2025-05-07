module synchronous_fifo #(
  parameter DEPTH = 8,               // Number of elements the FIFO can store
  parameter DATA_WIDTH = 8           // Width of each data element
)(
  input clk,                         // Clock signal
  input rst_n,                       // Active-low reset
  input w_en,                        // Write enable
  input r_en,                        // Read enable
  input [DATA_WIDTH-1:0] data_in,    // Input data to be written
  output reg [DATA_WIDTH-1:0] data_out, // Output data read from FIFO
  output full,                       // High when FIFO is full
  output empty                       // High when FIFO is empty
);

  localparam ADDR_WIDTH = $clog2(DEPTH); // Number of bits to address FIFO //4 bits

  // FIFO memory storage
  reg [DATA_WIDTH-1:0] fifo [0:DEPTH-1];
  reg [ADDR_WIDTH-1:0] w_ptr, r_ptr;     // Write and read pointers //3 bits 
  reg [ADDR_WIDTH:0] count;              // Counter for number of elements in FIFO ( here 4bits)

  // Write operation
  always @(posedge clk) begin
    if (!rst_n) begin
      w_ptr <= 0;
    end else if (w_en && !full) begin
      fifo[w_ptr] <= data_in;           // Write input data to FIFO
      w_ptr <= w_ptr + 1;               // Increment write pointer
    end
  end

  // Read operation
  always @(posedge clk) begin
    if (!rst_n) begin
      r_ptr <= 0;
      data_out <= 0;
    end else if (r_en && !empty) begin
      data_out <= fifo[r_ptr];          // Output data from FIFO
      r_ptr <= r_ptr + 1;               // Increment read pointer
    end
  end

  // Count logic to keep track of FIFO occupancy
  always @(posedge clk) begin
    if (!rst_n) begin
      count <= 0;
    end else begin
      case ({w_en && !full, r_en && !empty})
        2'b10: count <= count + 1;      // Write only
        2'b01: count <= count - 1;      // Read only
        default: count <= count;        // No operation or simultaneous
      endcase
    end
  end

  assign full  = (count == DEPTH);      // FIFO is full when count == DEPTH
  assign empty = (count == 0);          // FIFO is empty when count == 0

endmodule

`timescale 1ns/1ps

module tb_synchronous_fifo;

  // Parameters
  parameter DEPTH = 8;
  parameter DATA_WIDTH = 8;

  // DUT signals
  reg clk, rst_n;
  reg w_en, r_en;
  reg [DATA_WIDTH-1:0] data_in;
  wire [DATA_WIDTH-1:0] data_out;
  wire full, empty;

  // Instantiate the DUT
  synchronous_fifo #(DEPTH, DATA_WIDTH) dut (
    .clk(clk),
    .rst_n(rst_n),
    .w_en(w_en),
    .r_en(r_en),
    .data_in(data_in),
    .data_out(data_out),
    .full(full),
    .empty(empty)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk; // 100MHz clock

  // Test sequence
  initial begin
    $display("Starting FIFO Test...");
    $monitor("Time=%0t | w_en=%b r_en=%b data_in=%h data_out=%h full=%b empty=%b", 
             $time, w_en, r_en, data_in, data_out, full, empty);

    // Initialize signals
    rst_n = 0; w_en = 0; r_en = 0; data_in = 8'h00;
    #20;

    // Release reset
    rst_n = 1;
    #10;

    // Write data into FIFO
    $display("Writing to FIFO...");
    repeat (DEPTH) begin
      @(negedge clk);
      w_en = 1;
      data_in = $random % 256;
    end
    @(negedge clk);
    w_en = 0;

    // Wait a little
    #20;

    // Read data from FIFO
    $display("Reading from FIFO...");
    repeat (DEPTH) begin
      @(negedge clk);
      r_en = 1;
    end
    @(negedge clk);
    r_en = 0;

    // Wait and finish
    #20;
    $display("FIFO Test Completed.");
    $finish;
  end

endmodule

