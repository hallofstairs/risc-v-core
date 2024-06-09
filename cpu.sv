// 32-bit, single-cycle RISC-V CPU

parameter int InitPC = 32'h0;

module cpu (
    input wire clk,
    input wire reset
);
  reg  [31:0] pc;
  wire [ 4:0] alu_op;
  wire alu_src, reg_write;
  wire [31:0] instruction, read_data_1, read_data_2, alu_operand, alu_out;

  initial begin
    pc = InitPC;
  end

  always_ff @(posedge clk) begin
    if (reset) pc <= 0;
    else pc <= pc + 4;

    // $display(
    //     "PC: %h, Instruction: %h, ALU OP: %h, R1: %h, R2: %h, RegWrite: %h, rd: %h, alu_r: %h, x1: %h",
    //     pc, instruction[6:0], alu_op, read_data_1, alu_operand, reg_write, instruction[11:7],
    //     alu_out, reg_file.regs[1]);
  end


  instruction_memory instr_mem (
      .read_address(pc),
      .instruction (instruction)
  );

  register_file reg_file (
      .clk      (clk),
      .rd       (instruction[11:7]),
      .rs1      (instruction[19:15]),
      .rs2      (instruction[24:20]),
      .rs1_out  (read_data_1),
      .rs2_out  (read_data_2),
      .rd_data  (alu_out),
      .reg_write(reg_write)
  );

  controller control (
      .opcode(instruction[6:0]),
      .funct3(instruction[14:12]),
      .funct7(instruction[31:25]),
      .alu_op(alu_op),
      .alu_src(alu_src),
      .reg_write(reg_write)
  );

  mux alu_source (
      .a  (read_data_2),
      .b  (instruction[31:20]),
      .sel(alu_src),
      .out(alu_operand)
  );

  alu arith (
      .a  (read_data_1),
      .b  (alu_operand),
      .op (alu_op),
      .out(alu_out)
  );

endmodule


module instruction_memory (
    input  wire [31:0] read_address,
    output wire [31:0] instruction
);
  reg [31:0] mem[32];

  // Right-shift address by two to get word address
  assign instruction = mem[read_address>>2];

endmodule

module register_file (
    input  wire        clk,
    input  wire        reg_write,
    input  wire [ 4:0] rd,
    input  wire [ 4:0] rs1,
    input  wire [ 4:0] rs2,
    input  wire [31:0] rd_data,
    output wire [31:0] rs1_out,
    output wire [31:0] rs2_out
);
  reg [31:0] regs[32];

  initial begin
    regs[0] = 32'b0;  // x0 is always zero
  end

  always_ff @(posedge clk) begin
    if (reg_write) regs[rd] <= rd_data;
  end

  assign rs1_out = regs[rs1];
  assign rs2_out = regs[rs2];

endmodule

module controller (
    input  wire [6:0] opcode,
    input  wire [6:0] funct7,
    input  wire [2:0] funct3,
    output reg  [4:0] alu_op,
    output reg        alu_src,
    output reg        reg_write
);

  always_comb begin
    case (opcode)
      // R-type
      7'b0110011: begin
        alu_src   = 0;
        reg_write = 1;

        case (funct3)
          3'h0: begin
            if (funct7 == 7'h00) alu_op = 4'b0010;  // add
            else alu_op = 4'b0011;  // sub
          end

          default: alu_op = 0;
        endcase

      end

      // I-type
      7'b0010011: begin
        alu_src   = 1;
        reg_write = 1;

        case (funct3)
          3'h0: alu_op = 4'b0010;  // addi
          default: alu_op = 0;
        endcase
      end

      default: begin
        alu_src = 1;
        alu_op = 0;
        reg_write = 0;
      end
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
      4'b0011: out = b - a;  // sub
      default: out = 32'b0;
    endcase

    if (out == 32'b0) zero = 1;
    else zero = 0;

  end

endmodule

module mux (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire sel,
    output wire [31:0] out
);
  assign out = sel ? b : a;
endmodule
