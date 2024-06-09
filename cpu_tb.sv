module cpu_tb;
  reg clk, reset;
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
      main.instr_mem.mem[0] = 32'h00100093;  // addi x1, x0, 1
      main.instr_mem.mem[1] = 32'h00200113;  // addi x2, x0, 2
      main.instr_mem.mem[2] = 32'h002081b3;  // add x3, x1, x2

      #20;  // Wait

      // Check register file
      test_case_1_passed = (main.reg_file.regs[1] == 32'h00000001) &&
      (main.reg_file.regs[2] == 32'h00000002) &&
      (main.reg_file.regs[3] == 32'h00000003);

      // Display results
      if (test_case_1_passed) begin
        $display("Test case 1 passed");
      end else begin
        $error("Test case 1 failed");
        $display("x1 -- Expected: %h, Result: %h", 32'h00000001, main.reg_file.regs[1]);
        $display("x2 -- Expected: %h, Result: %h", 32'h00000002, main.reg_file.regs[2]);
        $display("x3 -- Expected: %h, Result: %h", 32'h00000003, main.reg_file.regs[3]);
      end
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
