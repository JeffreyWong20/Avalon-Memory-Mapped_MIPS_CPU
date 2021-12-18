module PCmux3to1 (
    input logic[31:0] ALU_result,
    input logic[31:0] ALUOut,
    input logic[1:0] PCSource,
    input logic[31:0] PC_in,
    input logic[4:0] instr25_21,
    input logic[4:0] instr20_16,
    input logic[15:0] instr15_0,
    output logic[31:0] PC_out
);
    logic[31:0] Jump_address;

    always @(*) begin
        Jump_address = {PC_in[31:28], instr25_21, instr20_16, instr15_0, 2'b0};
        case(PCSource)
            0: PC_out = ALU_result;
            1: PC_out = ALUOut;
            2: PC_out = Jump_address;
        endcase
    end
    
endmodule