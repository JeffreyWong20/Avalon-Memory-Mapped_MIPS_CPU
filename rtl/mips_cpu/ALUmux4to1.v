module ALUmux4to1 (
    input logic[31:0] register_b,
    input logic[15:0] immediate,
    input logic[5:0] opcode,
    input logic[1:0] ALUSrcB,
    output logic[31:0] ALUB
 );
    logic[31:0] sign_extended;
    logic[31:0] shift_2;

    typedef enum logic[5:0]{
        LUI     = 6'b001111,

        ANDI 	= 6'b001100,
		ORI 	= 6'b001101,
		XORI 	= 6'b001110
    }Zero_extend_opcode;

    always @(*) begin
    //sign extend
        if (opcode == ANDI || opcode == ORI || opcode == XORI) begin
            sign_extended = 32'b0000 + immediate;
        end
        else if(opcode == LUI) begin
            sign_extended = {immediate, 16'b0};
        end
        else begin
            if (immediate [15] == 1) begin
                sign_extended = 32'hFFFF0000 + immediate;
            end
            else begin
                sign_extended = 32'h00000000 + immediate;
            end
        end
        

    //shift by 2 
        shift_2 = sign_extended << 2;

    //mux
        case(ALUSrcB)
            0: ALUB = register_b;
            1: ALUB = 32'h00000004;
            2: ALUB = sign_extended;
            3: ALUB = shift_2; 
        endcase 
    end

endmodule