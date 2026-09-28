module RegisterFile(
    output wire [63:0] BusA,
    output wire [63:0] BusB,
    input  wire [63:0] BusW,
    input  wire [4:0]  RA,
    input  wire [4:0]  RB,
    input  wire [4:0]  RW,
    input  wire        RegWr,
    input  wire        Clk
);

    reg [63:0] registers [0:30];
    reg [63:0] readA;
    reg [63:0] readB;

    always @(posedge Clk) begin
        if (RegWr && (RW != 5'd31))
            registers[RW] <= BusW;
    end

    always @(*) begin
        if (RA == 5'd31)
            readA = 64'd0;
        else
            readA = registers[RA];

        if (RB == 5'd31)
            readB = 64'd0;
        else
            readB = registers[RB];
    end

    assign #3 BusA = readA;
    assign #3 BusB = readB;

endmodule