module cpu_tb;
  reg clk;
  reg reset;

  cpu main (
      .clk  (clk),
      .reset(reset)
  );

  always #1 clk = ~clk;  // Set clock tick

  // Sim and timing control
  initial begin
    clk   = 0;
    reset = 1;  // Init reset to 1

    #20 reset = 0;  // Deassert reset after 20 time units
    #100 $finish;  // Finish sim after 100 time units
  end

  // Logging
  initial begin
    $dumpfile("build/waveform.vcd");
    $dumpvars(0, testbench);
  end


endmodule
