module control(
    input [31:0]instr,

    output reg [11:0]imm12,
    output reg rf_we,
    output reg [2:0]alu_op,
    output reg alu_src,
    output reg mem_we,

    output reg branch,
    output reg jump,
    output reg jump_reg
);

wire [6:0]opcode = instr[6:0];
wire [2:0]funct3 = instr[14:12];
wire [1:0]funct2 = instr[26:25];
wire [4:0]funct5 = instr[31:27];

always @(*) begin
    rf_we = 1'b0;
    alu_op = 3'b0;
    imm12 = 12'b0;
    alu_src = 1'b0;
    mem_we = 1'b0;

    branch = 1'b0;
    jump   = 1'b0;
    jump_reg = 1'b0;

    casez ({funct5, funct2, funct3, opcode})
        17'b?????_??_000_0010011: begin // ADDI
            $strobe("(%s) funct5 = %h, funct2 = %h, funct3 = %h, opcode = %h",
                "ADDI", funct5, funct2, funct3, opcode);
            rf_we = 1'b1;
            alu_op = 3'b001;
            imm12 = instr[31:20];
            alu_src = 1'b1;
        end
        17'b?????_??_100_0010011: begin // XORI
            $strobe("(%s) funct5 = %h, funct2 = %h, funct3 = %h, opcode = %h",
                "XORI", funct5, funct2, funct3, opcode);
            rf_we = 1'b1;
            alu_op = 3'b100;
            imm12 = instr[31:20];
            alu_src = 1'b1;
        end
        17'b?????_??_110_0010011: begin // ORI
            $strobe("(%s) funct5 = %h, funct2 = %h, funct3 = %h, opcode = %h",
                "ORI", funct5, funct2, funct3, opcode);
            rf_we = 1'b1;
            alu_op = 3'b110;
            imm12 = instr[31:20];
            alu_src = 1'b1;
        end
        17'b?????_??_111_0010011: begin // ANDI
            $strobe("(%s) funct5 = %h, funct2 = %h, funct3 = %h, opcode = %h",
                "ANDI", funct5, funct2, funct3, opcode);
            rf_we = 1'b1;
            alu_op = 3'b111;
            imm12 = instr[31:20];
            alu_src = 1'b1;
        end
        17'b00000_00_000_0110011: begin // ADD
            $strobe("(%s) funct5 = %h, funct2 = %h, funct3 = %h, opcode = %h",
                "ADD", funct5, funct2, funct3, opcode);
            rf_we = 1'b1;
            alu_op = 3'b001;
            alu_src = 1'b0;
        end
        17'b00000_00_100_0110011: begin // XOR
            $strobe("(%s) funct5 = %h, funct2 = %h, funct3 = %h, opcode = %h",
                "XOR", funct5, funct2, funct3, opcode);
            rf_we = 1'b1;
            alu_op = 3'b100;
            alu_src = 1'b0;
        end
        17'b00000_00_110_0110011: begin // OR
            $strobe("(%s) funct5 = %h, funct2 = %h, funct3 = %h, opcode = %h",
                "OR", funct5, funct2, funct3, opcode);
            rf_we = 1'b1;
            alu_op = 3'b110;
            alu_src = 1'b0;
        end
        17'b00000_00_111_0110011: begin // AND
            $strobe("(%s) funct5 = %h, funct2 = %h, funct3 = %h, opcode = %h",
                "AND", funct5, funct2, funct3, opcode);
            rf_we = 1'b1;
            alu_op = 3'b111;
            alu_src = 1'b0;
        end
        17'b?????_??_010_0100011: begin // SW
            $strobe("(%s) funct5 = %h, funct2 = %h, funct3 = %h, opcode = %h",
                "SW", funct5, funct2, funct3, opcode);
            rf_we = 1'b0;
            alu_op = 3'b001;
            imm12 = {instr[31:25], instr[11:7]};
            alu_src = 1'b1;
            mem_we = 1'b1;
        end
        17'b?????_??_001_1100011: begin // BNE
            $strobe("(%s) funct5 = %h, funct2 = %h, funct3 = %h, opcode = %h",
                "BNE", funct5, funct2, funct3, opcode);
            imm12 = {instr[31], instr[31], instr[7], instr[30:25], instr[11:9]};
            alu_op = 3'b100;
            branch = 1'b1;
        end
        17'b?????_??_000_1100011: begin // BEQ
            $strobe("(%s) funct5 = %h, funct2 = %h, funct3 = %h, opcode = %h",
                "BEQ", funct5, funct2, funct3, opcode);
            imm12 = {instr[31], instr[31], instr[7], instr[30:25], instr[11:9]};
            alu_op = 3'b111;
            branch = 1'b1;
        end
        // JAL (указываем, что значения для funct3 не важны)
        17'b?????_??_???_1101111: begin // JAL
            $strobe("(%s) funct5 = %h, funct2 = %h, funct3 = %h, opcode = %h",
                "JAL", funct5, funct2, funct3, opcode);
            rf_we = 1'b1;
            jump = 1'b1; // Активация сигнала перехода
            // Предполагаем адаптацию 20-битного imm к 12-битному
            // для упрощения `imm12` = {instr[19:12], instr[11:8], instr[7]}; Это нестандартное поведение!
            // Используйте правильную формулу для imm20 в формате JAL, затем адаптируйте ее под 12 бит если ограничиваетесь "маленькими" прыжками
            imm12 = {instr[31],instr[19:12],instr[20],instr[30:21], 1'b0}; // можно обрезать/адаптировать, но здесь просто примерно показан процесс
        end

        // JALR
        17'b?????_??_???_1100111: begin // JALR
            $strobe("(%s) funct5 = %h, funct2 = %h, funct3 = %h, opcode = %h",
                "JALR", funct5, funct2, funct3, opcode);
            rf_we = 1'b1;
            jump_reg = 1'b1; // Активация сигнала перехода с регистром
            // Для JALR imm12 уже подходит, т.к. используется [11:0] инструкции
            imm12 = {instr[31],instr[19:12],instr[20],instr[30:21], 1'b0}; // можно обрезать/адаптировать, но здесь просто примерно показан процесс
        end
        default: begin
            $strobe("(%s) funct5 = %h, funct2 = %h, funct3 = %h, opcode = %h",
                "UNKNOWN INSTRUCTION", funct5, funct2, funct3, opcode);
        end
    endcase
end

endmodule