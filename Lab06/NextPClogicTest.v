`timescale 1ns/1ps

module NextPClogicTest;
    reg [63:0] CurrentPC, SignExtImm64;
    reg Branch, ALUZero, Uncondbranch;
    wire [63:0] NextPC;
    reg [63:0] expected;
    integer branch_value, zero_value, uncond_value, sample, errors;

    NextPClogic dut (
        .NextPC(NextPC),
        .CurrentPC(CurrentPC),
        .SignExtImm64(SignExtImm64),
        .Branch(Branch),
        .ALUZero(ALUZero),
        .Uncondbranch(Uncondbranch)
    );

    task check_result;
        input [63:0] pc, immediate;
        input branch_control, zero_control, uncond_control;
        begin
            CurrentPC = pc;
            SignExtImm64 = immediate;
            Branch = branch_control;
            ALUZero = zero_control;
            Uncondbranch = uncond_control;
            if ((branch_control & zero_control) | uncond_control)
                expected = pc + immediate;
            else
                expected = pc + 64'd4;
            #1;
            if (NextPC !== expected) begin
                $display("ERROR Branch=%b ALUZero=%b Uncondbranch=%b PC=%h Imm=%h expected=%h got=%h",
                         branch_control, zero_control, uncond_control,
                         pc, immediate, expected, NextPC);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("NextPClogicTest.vcd");
        $dumpvars(0, NextPClogicTest);
        errors = 0;
        CurrentPC = 0;
        SignExtImm64 = 0;
        Branch = 0;
        ALUZero = 0;
        Uncondbranch = 0;

        for (branch_value = 0; branch_value < 2; branch_value = branch_value + 1)
            for (zero_value = 0; zero_value < 2; zero_value = zero_value + 1)
                for (uncond_value = 0; uncond_value < 2; uncond_value = uncond_value + 1)
                    for (sample = 0; sample < 10; sample = sample + 1)
                        check_result({$random, $random}, {$random, $random},
                                     branch_value, zero_value, uncond_value);

        // Include address wraparound and a negative branch displacement.
        check_result(64'hFFFFFFFFFFFFFFFC, 64'h4, 1'b0, 1'b0, 1'b0);
        check_result(64'h1000, 64'hFFFFFFFFFFFFFFFC, 1'b1, 1'b1, 1'b0);

        if (errors == 0)
            $display("PASS: NextPClogic tests completed with no errors");
        else
            $display("FAIL: NextPClogic found %0d errors", errors);
        $finish;
    end
endmodule
