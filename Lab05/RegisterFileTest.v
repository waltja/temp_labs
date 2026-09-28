`timescale 1ns/1ps

module RegisterFile_tb;

    reg  [63:0] BusW;
    reg  [4:0]  RA, RB, RW;
    reg         RegWr, Clk;
    wire [63:0] BusA, BusB;

    reg [63:0] expected [0:30];

    integer i;
    reg [63:0] value;

    RegisterFile dut(
        .BusA(BusA),
        .BusB(BusB),
        .BusW(BusW),
        .RA(RA),
        .RB(RB),
        .RW(RW),
        .RegWr(RegWr),
        .Clk(Clk)
    );

    always #5 Clk = ~Clk;

    initial begin
        $dumpfile("RegisterFile.vcd");
        $dumpvars(0, RegisterFile_tb);

        Clk = 0;
        RegWr = 0;
        RA = 0;
        RB = 0;
        RW = 0;
        BusW = 0;

        // Test registers 0 through 30
        for (i = 0; i < 31; i = i + 1) begin

            // Write enabled
            value = {$random, $random};
            RW = i;
            BusW = value;
            RegWr = 1;

            @(posedge Clk);
            expected[i] = value;

            // Read back
            RegWr = 0;
            RA = i;
            #4;

            if (BusA !== expected[i])
                $display("ERROR reg %0d: expected %h got %h",
                         i, expected[i], BusA);
            else
                $display("PASS reg %0d: %h", i, BusA);

            // Try writing with RegWr disabled
            value = {$random, $random};
            RW = i;
            BusW = value;
            RegWr = 0;

            @(posedge Clk);

            // Read again; old value should remain
            RA = i;
            #4;

            if (BusA !== expected[i])
                $display("ERROR RegWr=0 reg %0d: expected %h got %h",
                         i, expected[i], BusA);
            else
                $display("PASS RegWr=0 reg %0d unchanged: %h",
                         i, BusA);
        end

        // Test register 31 / XZR
        RW = 31;
        BusW = 64'hFFFFFFFFFFFFFFFF;
        RegWr = 1;

        @(posedge Clk);

        RegWr = 0;
        RA = 31;
        RB = 31;
        #4;

        if ((BusA !== 64'd0) || (BusB !== 64'd0))
            $display("ERROR: XZR did not return zero");
        else
            $display("PASS: XZR always returns zero");

        $finish;
    end

endmodule