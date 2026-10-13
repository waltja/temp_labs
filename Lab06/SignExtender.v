`define Itype   2'b00  // These defines are not required but may be helpful.
`define Dtype   2'b01
`define CBtype  2'b10
`define Btype   2'b11

module SignExtender(
    output reg [63:0] SignExOut,
    input      [25:0] Instruction,
    input      [1:0]  SignOp
);

always @* begin
    SignExOut = 64'b0;

    case (SignOp)
        `Itype: SignExOut = {52'b0, Instruction[21:10]};
        `Dtype: SignExOut = {{55{Instruction[20]}}, Instruction[20:12]};
        `CBtype: SignExOut = {{43{Instruction[23]}}, Instruction[23:5], 2'b00};
        `Btype: SignExOut = {{36{Instruction[25]}}, Instruction[25:0], 2'b00};
        default: SignExOut = 64'b0;
    endcase
end

endmodule
