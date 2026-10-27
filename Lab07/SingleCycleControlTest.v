`timescale 1ns / 1ps

module SingleCycleControlTest;
   reg [10:0] opcode;
   wire Reg2Loc, ALUSrc, MemtoReg, RegWrite;
   wire MemRead, MemWrite, Branch, Uncondbranch;
   wire [3:0] ALUOp;
   wire [1:0] SignOp;
   reg [13:0] expected;
   integer failures;
   integer i;

   SC_Control dut(
      .Reg2Loc(Reg2Loc),
      .ALUSrc(ALUSrc),
      .MemtoReg(MemtoReg),
      .RegWrite(RegWrite),
      .MemRead(MemRead),
      .MemWrite(MemWrite),
      .Branch(Branch),
      .Uncondbranch(Uncondbranch),
      .ALUOp(ALUOp),
      .SignOp(SignOp),
      .opcode(opcode)
   );

   function is_supported;
      input [10:0] candidate;
      begin
         casez (candidate)
             11'b11111000010, 11'b11111000000, 11'b10001011000,
             11'b11001011000, 11'b10001010000, 11'b10101010000,
             11'b1001000100?, 11'b1101000100?, 11'b110100101??,
             11'b10110100???, 11'b000101?????:
               is_supported = 1'b1;
            default: is_supported = 1'b0;
         endcase
      end
   endfunction

   task check_opcode;
      input [10:0] test_opcode;
      input [13:0] expected_controls;
      begin
         opcode = test_opcode;
         expected = expected_controls;
         #1;
         if ({Reg2Loc, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite,
              Branch, Uncondbranch, ALUOp, SignOp} !== expected) begin
            $display("ERROR opcode=%b controls=%b expected=%b",
                     opcode,
                     {Reg2Loc, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite,
                      Branch, Uncondbranch, ALUOp, SignOp},
                     expected);
            failures = failures + 1;
         end
      end
   endtask

   initial begin
      $dumpfile("singlecyclecontrol.vcd");
      $dumpvars(0, SingleCycleControlTest);
      failures = 0;

      check_opcode(11'b11111000010, 14'b01111000001001);
      check_opcode(11'b11111000000, 14'b11000100001001);
      check_opcode(11'b10001011000, 14'b00010000001000);
      check_opcode(11'b11001011000, 14'b00010000011000);
      check_opcode(11'b10001010000, 14'b00010000000000);
      check_opcode(11'b10101010000, 14'b00010000000100);

       for (i = 0; i < 2; i = i + 1)
          check_opcode(11'b10010001000 | i, 14'b01010000001000);

       for (i = 0; i < 2; i = i + 1)
          check_opcode(11'b11010001000 | i, 14'b01010000011000);

       for (i = 0; i < 4; i = i + 1)
          check_opcode(11'b11010010100 | i, 14'b01010000011100);

      for (i = 0; i < 8; i = i + 1)
         check_opcode(11'b10110100000 | i, 14'b10000010011110);

      for (i = 0; i < 32; i = i + 1)
         check_opcode(11'b00010100000 | i, 14'b00000001000011);

      // Randomly exercise ten opcodes that do not match any supported pattern.
      i = 0;
      while (i < 10) begin
         opcode = $random;
         if (!is_supported(opcode)) begin
            check_opcode(opcode, 14'b0);
            i = i + 1;
         end
      end

      if (failures == 0)
         $display("All control-unit tests passed");
      else
         $display("Control-unit tests failed: %0d", failures);
      $finish;
   end
endmodule
