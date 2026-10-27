module NextPClogic(
    output reg [63:0] NextPC,
    input  [63:0] CurrentPC,
    input  [63:0] SignExtImm64,
    input         Branch,
    input         ALUZero,
    input         Uncondbranch
);
always @* begin
    if ((Branch & ALUZero) | Uncondbranch)
        NextPC = CurrentPC + SignExtImm64;
    else
        NextPC = CurrentPC + 64'd4;
end

endmodule
