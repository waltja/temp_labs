`timescale 1ns/1ps

module mux2to1_8_tb;

reg [7:0] in0, in1;
reg sel;
wire [7:0] out;
integer i, j, s;

mux2to1_8 dut(in0, in1, sel, out);

initial begin
    $dumpfile("mux.vcd");
    $dumpvars(0, mux2to1_8_tb);

    for (s = 0; s < 2; s = s + 1)
        for (i = 0; i < 256; i = i + 1)
            for (j = 0; j < 256; j = j + 1) begin
                sel = s; in0 = i; in1 = j;
                #5;
                $display("sel=%b in0=%h in1=%h out=%h", sel, in0, in1, out);

                if (out != (sel ? in1 : in0))
                    $display("ERROR!");
            end

    $finish;
end

endmodule