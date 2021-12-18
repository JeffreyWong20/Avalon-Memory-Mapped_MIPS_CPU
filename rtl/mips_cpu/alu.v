module alu(
	input logic[3:0] ALUOperation,
	input logic signed[31:0] a,
	input logic signed[31:0] b,
	input logic unsign,
	input logic fixed_shift,
	input logic branch_equal,
	input logic[4:0] instr10_6,
	output logic[31:0] ALU_result,
	output logic[63:0] ALU_MULTorDIV_result,
	output logic zero
);

/*
	ALU_MULTorDIV_result {} {}
	DIV / => top {} & ALU_result
	DIV % => bottom {}
*/

	logic[32:0] ALU_temp_result, B_unsign, A_unsign, quotient_unsign, remainder_unsign;
	logic[65:0] ALU_temp_MULTorDIV_result;
	logic[31:0] remainder, quotient;
	logic [63:0] A_extend, B_extend;

	
	typedef enum logic[3:0] {
        ADD 						= 4'b0000,
        LOGICAL_AND 				= 4'b0001,
        SUBTRACT 					= 4'b0010,
        SET_GREATER_OR_EQUAL_ZERO	= 4'b0011,
		SET_ON_GREATER_THAN_ZERO	= 4'b0100,
		SET_LESS_OR_EQUAL_ZERO 		= 4'b0101,
        SET_ON_LESS_THAN_ZERO 		= 4'b0110,
		MULTIPLY 					= 4'b0111,
		DIVIDE 						= 4'b1000,
        LOGICAL_OR 					= 4'b1001,
		LOGICAL_XOR 				= 4'b1010,
		SHIFT_LEFT 					= 4'b1011,
		SHIFT_RIGHT 				= 4'b1100,
		SHIFT_RIGHT_SIGNED 			= 4'b1101,
		SET_ON_LESS_THAN			= 4'b1110
	} ALUOperation_t;

	assign A_unsign = {1'b0 + a};
	assign B_unsign = {1'b0 + b};
    assign zero = (ALU_result == 0) ? (branch_equal==1)?0:1 :(branch_equal == 1) ? 1 : 0;
	
	//BEQ: SUBTRACT a - b = alu_out = 0 => [(zero = 1 & PCWriteCond) | JUMP = pc_ctr_jump , PCWrite]
	//BGEZ: SET_GREATER_OR_EQUAL (a >= b) = alu_out (boolean) =0 => [(zero=1 & PCWriteCond) | JUMP = pc_ctr_jump , PCWrite]
	
//have to add all the basic alu instructions which are 15 in total 
	always @(*) begin
		if(unsign == 1) begin 
			case(ALUOperation)
				// LOGICAL_AND: 			ALU_temp_result = A_unsign & B_unsign;  //bitwise 
				// LOGICAL_OR: 				ALU_temp_result = A_unsign | B_unsign;
				// LOGICAL_XOR: 			ALU_temp_result = A_unsign ^ B_unsign;
				// ADD: 					ALU_temp_result = A_unsign + B_unsign;  //we might not need this
				SUBTRACT: 					ALU_temp_result = A_unsign - B_unsign;
				MULTIPLY:		
										begin 									//mandatory
											ALU_temp_MULTorDIV_result = A_unsign * B_unsign; // create[63:0] variable = A * B then divide variable to HI and LO regs
											ALU_MULTorDIV_result = ALU_temp_MULTorDIV_result[63:0];
										end
			 	DIVIDE:					begin									//mandatory
											quotient_unsign = A_unsign / B_unsign; 
											remainder_unsign = A_unsign % B_unsign;
											ALU_MULTorDIV_result = {remainder_unsign[31:0],quotient_unsign[31:0]};
										end
				//SET_GREATER_OR_EQUAL:	ALU_temp_result = (A_unsign >= B_unsign) ? 0 : 1;
				//SET_ON_GREATER_THAN:	ALU_temp_result = (A_unsign > B_unsign) ? 0 : 1;
				//SET_LESS_OR_EQUAL:	ALU_temp_result = (A_unsign <= B_unsign) ? 0 : 1;
				SET_ON_LESS_THAN:		begin
					ALU_temp_result = (A_unsign < B_unsign) ? 1 : 0; // For less then IF a < b result need to be 1 unfortunaly
				end
				// SHIFT_RIGHT:			ALU_temp_result = A_unsign >> B_unsign; 
				// SHIFT_LEFT:			ALU_temp_result = A_unsign << B_unsign;
				// SHIFT_RIGHT_SIGNED:	ALU_temp_result = A_unsign >>> B_unsign;
				//NOR: ALU_temp_result = ~ (a | b); 
				default: ALU_temp_result = 0;
			endcase
			
			ALU_result = ALU_temp_result[31:0];
		end 
		
		else begin
			
			case(ALUOperation)
				LOGICAL_AND: 			ALU_result = a & b;
				LOGICAL_OR: 			ALU_result = a | b;
				LOGICAL_XOR: 			ALU_result = a ^ b;
				ADD: 					ALU_result = a + b;
				SUBTRACT: 				ALU_result = a - b;
				MULTIPLY:				begin
											//A_extend = (a[31] == 1) ? {32'hFFFFFFFF, a} : {32'h0, a};
											//B_extend = (b[31] == 1) ? {32'hFFFFFFFF, b} : {32'h0, b};
											//ALU_MULTorDIV_result = A_extend * B_extend;
											ALU_MULTorDIV_result = a * b;
										end
				DIVIDE:					begin 										
											remainder = a % b;
											quotient = a / b;
											ALU_MULTorDIV_result = {remainder,quotient};
										end				
				SET_GREATER_OR_EQUAL_ZERO:	ALU_result = (a >= 0) ? 0 : 1; //for jump condition also for (a < b)
				SET_ON_GREATER_THAN_ZERO:	ALU_result = (a > 0) ? 0 : 1; //for jump condition
				SET_LESS_OR_EQUAL_ZERO:		ALU_result = (a <= 0) ? 0 : 1; //for jump condition
				SET_ON_LESS_THAN_ZERO:		ALU_result = (a < 0) ? 0 : 1; //jump condition 

				SET_ON_LESS_THAN:			ALU_result = (a < b) ? 1 : 0; //instruction 

				// SHIFTS can be done by a fixed immediate or by a value of a register
				SHIFT_RIGHT:				ALU_result = (fixed_shift == 1) ? b >> instr10_6 : b >> a;
				SHIFT_LEFT:					ALU_result = (fixed_shift == 1) ? b << instr10_6 : b << a;
				SHIFT_RIGHT_SIGNED:			ALU_result = (fixed_shift == 1) ? b >>> instr10_6 : b >>> a;

				default: ALU_result = 0;
			endcase
		end
		// $display("a = %b", a);
		// $display("b = %b", b);
		// $display("shifted_bit = %b", instr10_6);
		// $display("ALUOperation = %b", ALUOperation);
		// $display("ALuresult = %b", ALU_result);
	end
	// always@(*) begin
    // 	$display("ALUSrcA = %b, ALUSrcB= %b",a, b);
    // end
	// always@(*) begin
	// 	$display("SET_ON_LESS_THAN: A<B=%d, A=%h, B=%h",(A_unsign < B_unsign),A_unsign,B_unsign);
	// end

endmodule : alu
