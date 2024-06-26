// CPU testbench

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

  task automatic test_rv32i_base_int;
    begin
      // Initialize instruction memory
      main.instr_mem.mem[0] = 32'h00500093;  // addi x1, x0, 5
      main.instr_mem.mem[1] = 32'h00a00113;  // addi x2, x0, 10
      main.instr_mem.mem[2] = 32'h002081b3;  // add x3, x1, x2
      main.instr_mem.mem[3] = 32'h40208233;  // sub x4, x2, x1
      main.instr_mem.mem[4] = 32'h0020c2b3;  // xor x5, x1, x2
      main.instr_mem.mem[5] = 32'h00216333;  // or x6, x2, x2
      main.instr_mem.mem[6] = 32'h00119393;  // slli x7, x3, 1
      main.instr_mem.mem[7] = 32'h0021d433;  // srli x8, x3, 2

      #20;  // Wait

      // Check register file
      test_case_1_passed = (main.reg_file.regs[1] == 32'h5) &&  // x1 == 5
      (main.reg_file.regs[2] == 32'hA) &&  // x2 == 10
      (main.reg_file.regs[3] == 32'hF) &&  // x3 == 15
      (main.reg_file.regs[4] == 32'h5) &&  // x4 == 5
      (main.reg_file.regs[5] == 32'hF) &&  // x5 == 15
      (main.reg_file.regs[6] == 32'hA) &&  // x6 == 10
      (main.reg_file.regs[7] == 32'h1E) &&  // x7 == 30
      (main.reg_file.regs[8] == 32'h3);  // x8 == 3

      // Display results
      if (test_case_1_passed) $display("Test case 1 passed");
      else $error("Test case 1 failed");

      $display("x1 -- Expected: %h, Result: %h", 32'h5, main.reg_file.regs[1]);
      $display("x2 -- Expected: %h, Result: %h", 32'hA, main.reg_file.regs[2]);
      $display("x3 -- Expected: %h, Result: %h", 32'hF, main.reg_file.regs[3]);
      $display("x4 -- Expected: %h, Result: %h", 32'h5, main.reg_file.regs[4]);
      $display("x5 -- Expected: %h, Result: %h", 32'hF, main.reg_file.regs[5]);
      $display("x6 -- Expected: %h, Result: %h", 32'hA, main.reg_file.regs[6]);
      $display("x7 -- Expected: %h, Result: %h", 32'h1E, main.reg_file.regs[7]);
      $display("x8 -- Expected: %h, Result: %h", 32'h3, main.reg_file.regs[8]);
    end
  endtask

  // Run simulation
  initial begin
    clk = 0;

    // Logging
    $dumpfile("build/waveform.vcd");
    $dumpvars(0, cpu_tb);

    reset_cpu();
    test_rv32i_base_int();

    // reset_cpu();
    // test_case_2();

    // TODO: Add more test cases

    #100;
    $finish;
  end


endmodule
