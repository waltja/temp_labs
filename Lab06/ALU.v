`define AND   4'b0000  // These defines are not required but may be helpful.
`define OR    4'b0001
`define ADD   4'b0010
`define SUB   4'b0110
`define PassB 4'b0111

module ALU(
    output reg [63:0] BusW,
    input      [63:0] BusA,
    input      [63:0] BusB,
    input      [3:0]  ALUCtrl,
    output            Zero
);

always @* begin
    case (ALUCtrl)
        4'b0000: BusW = BusA & BusB;
        4'b0001: BusW = BusA | BusB;
        4'b0010: BusW = BusA + BusB;
        4'b0110: BusW = BusA - BusB;
        4'b0111: BusW = BusB;
        default: BusW = 64'b0;
    endcase
end

assign Zero = (BusW == 64'b0);

endmodule
