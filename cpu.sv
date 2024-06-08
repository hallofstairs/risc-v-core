// Implementation of a 32-bit, single-cycle RISC-V CPU

module cpu (
    input wire clk,
    input wire reset
);
  reg  [31:0] pc;
  wire [ 4:0] alu_op;
  wire [31:0] instruction, read_data_1, read_data_2, op_result;

  initial begin
    $display("CPU initialized.");
    pc = 0;
  end

  always_ff @(posedge clk) begin
    if (reset) pc <= 0;
    else pc <= pc + 4;

    $display("PC: %h, Instruction: %h, ALU OP: %h, R1: %h, R2: %h", pc, instruction, alu_op,
             read_data_1, read_data_2);
  end


  // Gather instruction from instruction memory
  instruction_memory instructions (
      .read_address(pc),
      .instruction (instruction)
  );

  // Connect to registers -- read rs1, rs2; eventually write
  register_file reg_file (
      .rd     (instruction[11:7]),
      .rs1    (instruction[19:15]),
      .rs2    (instruction[24:20]),
      .rs1_out(read_data_1),
      .rs2_out(read_data_2),
      .rd_data(op_result)
  );

  controller control (
      .opcode(instruction[6:0]),
      .alu_op(alu_op)
  );

  alu arith (
      .a  (read_data_1),
      .b  (read_data_2),
      .op (alu_op),
      .out(op_result)
  );

endmodule


module instruction_memory (
    input  wire [31:0] read_address,
    output wire [31:0] instruction
);
  reg [31:0] instructions[32];

  // TODO: use $readmemh or $readmemb to initialize
  initial begin
    instructions[0] = 32'h00000000;  // NOP
    // instructions[1] = 32'h00100093;  // ADDI x1, x0, 1
    // instructions[2] = 32'h00200113;  // ADDI x2, x0, 2
    instructions[1] = 32'h00000033;  // ADD x1, x0, x0
  end

  // Right-shift address by two to get word address
  assign instruction = instructions[read_address>>2];

endmodule

module register_file (
    input  wire        clk,
    input  wire        is_write,
    input  wire [ 4:0] rd,
    input  wire [ 4:0] rs1,
    input  wire [ 4:0] rs2,
    input  wire [31:0] rd_data,
    output wire [31:0] rs1_out,
    output wire [31:0] rs2_out
);
  reg [31:0] registers[32];

  initial begin
    registers[0] = 32'b0;  // x0 is always zero
  end

  always_ff @(posedge clk) begin
    if (is_write) registers[rd] <= rd_data;
  end

  assign rs1_out = registers[rs1];
  assign rs2_out = registers[rs2];

endmodule

module controller (
    input  wire [6:0] opcode,
    input  wire [6:0] funct7,
    input  wire [2:0] funct3,
    output reg  [4:0] alu_op
);

  always_comb begin
    case (opcode)
      // R-type
      7'b0110011: begin
        case (funct3)
          3'h0: begin
            if (funct7 == 7'h00) alu_op = 4'b0010;
            else alu_op = 4'b0011;
          end

          default: alu_op = 0;
        endcase
      end

      default: alu_op = 0;
    endcase
  end

endmodule

module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [ 4:0] op,
    output reg  [31:0] out,
    output reg         zero
);
  always_comb begin
    case (op)
      4'b0000: out = a & b;  // AND
      4'b0001: out = a | b;  // OR
      4'b0010: out = a + b;  // add
      4'b0011: out = a - b;  // sub
      default: out = 32'b0;
    endcase

    if (out == 32'b0) zero = 1;
    else zero = 0;

  end

endmodule


