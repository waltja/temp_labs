`timescale 1ns/1ps

module SignExtenderTest;
    reg [25:0] Instruction;
    reg [1:0] SignOp;
    wire [63:0] SignExOut;
    reg [63:0] expected;
    integer op, sample, errors;

    SignExtender dut (
        .SignExOut(SignExOut),
        .Instruction(Instruction),
        .SignOp(SignOp)
    );

    function [63:0] reference_extend;
        input [25:0] instruction;
        input [1:0] signop;
        begin
            case (signop)
                2'b00: reference_extend = {52'b0, instruction[21:10]};
                2'b01: reference_extend = {{55{instruction[20]}}, instruction[20:12]};
                2'b10: reference_extend = {{43{instruction[23]}}, instruction[23:5], 2'b00};
                2'b11: reference_extend = {{36{instruction[25]}}, instruction[25:0], 2'b00};
                default: reference_extend = 64'b0;
            endcase
        end
    endfunction

    task check_result;
        input [25:0] instruction;
        input [1:0] signop;
        begin
            Instruction = instruction;
            SignOp = signop;
            expected = reference_extend(instruction, signop);
            #1;
            if (SignExOut !== expected) begin
                $display("ERROR SignOp=%b Instruction=%h expected=%h got=%h",
                         signop, instruction, expected, SignExOut);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("SignExtenderTest.vcd");
        $dumpvars(0, SignExtenderTest);
        errors = 0;
        Instruction = 0;
        SignOp = 0;

        for (op = 0; op < 4; op = op + 1) begin
            for (sample = 0; sample < 100; sample = sample + 1)
                check_result({$random, $random}, op[1:0]);
        end

        // Force positive and negative immediate sign bits for signed formats.
        check_result(26'b0, 2'b01);
        check_result(26'b1 << 20, 2'b01);
        check_result(26'b0, 2'b10);
        check_result(26'b1 << 23, 2'b10);
        check_result(26'b0, 2'b11);
        check_result(26'b1 << 25, 2'b11);

        if (errors == 0)
            $display("PASS: SignExtender tests completed with no errors");
        else
            $display("FAIL: SignExtender found %0d errors", errors);
        $finish;
    end
endmodule
