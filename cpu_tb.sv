module cpu_tb;
  logic clk, reset;
  bit test_case_1_passed;

  cpu main (
      .clk  (clk),
      .reset(reset)
  );

  always #1 clk = ~clk;  // Set clock tick

  task automatic reset_cpu;
    begin
      reset = 1;
      #2 reset = 0;
    end
  endtask

  task automatic test_case_1;
    begin
      // Initialize instruction memory
      main.instr_mem.mem[0] = 32'h00500093;  // addi x1, x0, 5
      main.instr_mem.mem[1] = 32'h00a00113;  // addi x2, x0, 10
      main.instr_mem.mem[2] = 32'h002081b3;  // add x3, x1, x2
      main.instr_mem.mem[3] = 32'h40208233;  // sub x4, x2, x1

      #20;  // Wait

      // Check register file
      test_case_1_passed = (main.reg_file.regs[1] == 32'h5) &&  // x1 == 5
      (main.reg_file.regs[2] == 32'hA) &&  // x2 == 10
      (main.reg_file.regs[3] == 32'hF) &&  // x3 == 15
      (main.reg_file.regs[4] == 32'h5);  // x4 == 5

      // Display results
      if (test_case_1_passed) $display("Test case 1 passed");
      else $error("Test case 1 failed");

      $display("x1 -- Expected: %h, Result: %h", 32'h5, main.reg_file.regs[1]);
      $display("x2 -- Expected: %h, Result: %h", 32'hA, main.reg_file.regs[2]);
      $display("x3 -- Expected: %h, Result: %h", 32'hF, main.reg_file.regs[3]);
      $display("x4 -- Expected: %h, Result: %h", 32'h5, main.reg_file.regs[4]);
    end
  endtask

  // Run simulation
  initial begin
    clk = 0;

    // Logging
    $dumpfile("build/waveform.vcd");
    $dumpvars(0, cpu_tb);

    reset_cpu();
    test_case_1();

    // reset_cpu();
    // test_case_2();

    // TODO: Add more test cases

    #100;
    $finish;
  end


endmodule
