module alu(
    input wire[31:0]src_a, src_b,
    input wire[2:0]alucontrol,

    output reg[31:0]result
);


always @(*) begin
    case (alucontrol)
        3'b000: result = src_a;
        3'b001: result = src_a + src_b;
        3'b100: result = src_a ^ src_b;
        3'b110: result = src_a | src_b;
        3'b111: result = src_a & src_b;
        default: result = 0;
    endcase
end



endmodule