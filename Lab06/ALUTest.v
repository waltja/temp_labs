`timescale 1ns/1ps

module ALUTest;
    reg [63:0] BusA, BusB;
    reg [3:0] ALUCtrl;
    wire [63:0] BusW;
    wire Zero;
    reg [63:0] expected;
    reg expected_zero;
    integer op_index, sample, errors;
    reg [3:0] operation;

    ALU dut (
        .BusW(BusW),
        .BusA(BusA),
        .BusB(BusB),
        .ALUCtrl(ALUCtrl),
        .Zero(Zero)
    );

    function [63:0] reference_alu;
        input [63:0] a, b;
        input [3:0] control;
        begin
            case (control)
                4'b0000: reference_alu = a & b;
                4'b0001: reference_alu = a | b;
                4'b0010: reference_alu = a + b;
                4'b0110: reference_alu = a - b;
                4'b0111: reference_alu = b;
                default: reference_alu = 64'b0;
            endcase
        end
    endfunction

    task check_result;
        input [63:0] a, b;
        input [3:0] control;
        begin
            BusA = a;
            BusB = b;
            ALUCtrl = control;
            expected = reference_alu(a, b, control);
            expected_zero = (expected == 64'b0);
            #1;
            if ((BusW !== expected) || (Zero !== expected_zero)) begin
                $display("ERROR ALUCtrl=%b A=%h B=%h expected=%h/%b got=%h/%b",
                         control, a, b, expected, expected_zero, BusW, Zero);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("ALUTest.vcd");
        $dumpvars(0, ALUTest);
        errors = 0;
        BusA = 0;
        BusB = 0;
        ALUCtrl = 0;

        for (op_index = 0; op_index < 5; op_index = op_index + 1) begin
            case (op_index)
                0: operation = 4'b0000;
                1: operation = 4'b0001;
                2: operation = 4'b0010;
                3: operation = 4'b0110;
                4: operation = 4'b0111;
            endcase

            // Cover every pairing of all-zero and all-one operands per operation.
            check_result(64'b0, 64'b0, operation);
            check_result(64'b0, 64'hFFFFFFFFFFFFFFFF, operation);
            check_result(64'hFFFFFFFFFFFFFFFF, 64'b0, operation);
            check_result(64'hFFFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF, operation);

            for (sample = 0; sample < 100; sample = sample + 1)
                check_result({$random, $random}, {$random, $random}, operation);
        end

        // Explicitly check zero and nonzero results for each ALU function.
        check_result(64'b0, 64'b0, 4'b0000);
        check_result(64'h1, 64'h1, 4'b0000);
        check_result(64'b0, 64'b0, 4'b0001);
        check_result(64'h1, 64'b0, 4'b0001);
        check_result(64'b0, 64'b0, 4'b0010);
        check_result(64'h1, 64'b0, 4'b0010);
        check_result(64'h5, 64'h5, 4'b0110);
        check_result(64'h6, 64'h5, 4'b0110);
        check_result(64'h1, 64'b0, 4'b0111);
        check_result(64'h1, 64'h1, 4'b0111);

        // Check signed overflow and unsigned carry wraparound on ADD.
        check_result(64'h7FFFFFFFFFFFFFFF, 64'h1, 4'b0010);
        check_result(64'hFFFFFFFFFFFFFFFF, 64'h1, 4'b0010);

        if (errors == 0)
            $display("PASS: ALU tests completed with no errors");
        else
            $display("FAIL: ALU found %0d errors", errors);
        $finish;
    end
endmodule
