module cpu_tb;
  reg clk, reset;

  cpu main (
      .clk  (clk),
      .reset(reset)
  );

  always #1 clk = ~clk;  // Set clock tick

  // Sim and timing control
  initial begin
    clk   = 0;
    reset = 1;  // Init reset to 1

    #5 reset = 0;  // Deassert reset after 5 time units
    #10 $finish;  // Finish sim after 10 time units
  end

  // Logging
  initial begin
    $dumpfile("build/waveform.vcd");
    $dumpvars(0, cpu_tb);
  end


endmodule
