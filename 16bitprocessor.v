module processor(
    input clk,
    input reset,
    output reg [2:0] alu,
    output reg [2:0] dest,
    output reg [2:0] source1,
    output reg [2:0] source2,
    output reg operation,
    output reg [3:0] opcode,
    output reg [7:0] datamemorylocation
);

    reg [2:0] counter_up; // program counter
    reg [15:0] regarray1[7:0]; // define 16-bit 8 instruction
    reg [15:0] ir; //16-bit instruction register

    reg [8:0] sum1;
    reg [7:0] sum; // ALU output
    reg [7:0] regarray[7:0]; // 16-bit 8 register
    reg [7:0] datamemory[255:0]; // 16-bit 255 datamemory
    reg carry; // carry flag
    reg zero; // zero flag

    integer i, j;

    // Initialization
    initial begin
        for (i = 0; i < 8; i = i + 1)
            regarray[i] <= 8'b00000000; // Clear all the garbage values of registers

        for (j = 0; j <= 255; j = j + 1)
            datamemory[j] <= 8'b00000000; // Clear all the garbage values of datamemory

        // Fetch cycle
        regarray1[3'b000] <= 16'b1000000000000111; // Load r0 register with 00000111;
        regarray1[3'b001] <= 16'b1000001000000010; // Load r1 register with 00000010;
        regarray1[3'b010] <= 16'b1000010000001000; // Load r2 register with 00001000;
        regarray1[3'b011] <= 16'b1000011000000001; // Load r3 register with 00000001;
        regarray1[3'b100] <= 16'b0000111000001001; // r7=r0+r1
        regarray1[3'b101] <= 16'b0000110010011100; // r6=r2+r3
        regarray1[3'b110] <= 16'b1010111011111111; // Store r7 to ff location
        regarray1[3'b111] <= 16'b1010110011111110; // Store r6 to fe location
    end

    // Fetch and decode
    always @(posedge clk or posedge reset) begin
        if (reset == 1)
            counter_up <= 3'b0; // If reset, program counter should be at the starting location

        if (reset == 0)
            counter_up <= counter_up + 3'b1; // Program counter incremented by 1

        ir <= regarray1[counter_up];
    end

    // Decode and execute
    assign operation = ir[15]; // ALU
    assign datamemorylocation = ir[7:0]; // Datamemory location or 8-bit value
    assign opcode = ir[15:12]; // Bit 15 to 16 opcode

    assign alu = ir[14:12]; // ALU operation
    assign dest = ir[11:9]; // Destination register
    assign source1 = ir[8:6]; // Register 1
    assign source2 = ir[5:3]; // Register 2

always @(posedge clk) begin
    if (operation == 1'b0) begin // ALU operation
        if (alu == 3'b000) begin // addition
            sum1 = regarray[source1] + regarray[source2];
            sum = sum1[7:0];
            carry = sum1[8];
            zero = (sum == 8'b0);
            regarray[dest] = sum;
        end

        if (alu == 3'b001) begin // subtraction
            sum1 <= regarray[source1] - regarray[source2];
            sum <= sum1[7:0];
            carry <= sum1[8];
            zero <= (sum == 8'b0);
            regarray[dest] <= sum;
        end

        if (alu == 3'b010) begin // Anding
            sum1 <= regarray[source1] & regarray[source2];
            sum <= sum1[7:0];
            carry <= sum1[8];
            zero <= (sum == 8'b0);
            regarray[dest] <= sum;
        end

        if (alu == 3'b011) begin // ORing
            sum1 <= regarray[source1] | regarray[source2];
            sum <= sum1[7:0];
            carry <= sum1[8];
            zero <= (sum == 8'b0);
            regarray[dest] <= sum;
        end

        if (alu == 3'b100) begin // Bitwise Xor
            sum1 <= regarray[source1] ^ regarray[source2];
            sum <= sum1[7:0];
            carry <= sum1[8];
            zero <= (sum == 8'b0);
            regarray[dest] <= sum;
        end

        if (alu == 3'b101) begin // not a
            sum1 <= ~regarray[source1];
            sum <= sum1[7:0];
            carry <= sum1[8];
            zero <= (sum == 8'b0);
            regarray[dest] <= sum;
        end

        if (alu == 3'b110) begin // not b
            sum1 <= ~regarray[source2];
            sum <= sum1[7:0];
            carry <= sum1[8];
            zero <= (sum == 8'b0);
            regarray[dest] <= sum;
        end

        if (alu == 3'b111) begin // A > B
            sum1 <= regarray[source1] > regarray[source2];
            sum <= sum1[7:0];
            carry <= sum1[8];
            zero <= (sum == 8'b0);
            regarray[dest] <= sum;
        end
    end

    if (opcode == 4'b1000) begin
        regarray[dest] <= datamemorylocation; // load register (mvi r1,2)
    end

    if (opcode == 4'b1001) begin
        regarray[dest] <= datamemory[datamemorylocation]; // load register from datamemory (ld r16,x)
    end

    if (opcode == 4'b1010) begin
        datamemory[datamemorylocation] <= regarray[dest]; // store register value to datamemory (sts 8000,r16)
    end
end

endmodule
