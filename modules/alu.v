module alu(
    input wire[31:0]src_a, src_b,
    input wire[2:0]alucontrol,

    output reg[31:0]result,
    output wire zero
);

wire [31:0] sum, condb; 
    

assign condb = alucontrol[0] ? ~src_b : src_b;
assign sum   = src_a + condb + alucontrol[0];

always @(*) begin 
    case (alucontrol) 
    3'b000: result = sum;           // add
    3'b001: result = sum;           // sub
    3'b010: result = src_a & src_b; // and
    3'b011: result = src_a | src_b; // or
    3'b100: result = src_a ^ src_b; // xor
    default: result = 32'bx;
    endcase
end 

assign zero = (result == 32'b0);

endmodule