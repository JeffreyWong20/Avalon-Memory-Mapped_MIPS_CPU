// top level CPU (will be connected to MEMORY in testbench)
module mips_cpu_bus (
	input logic clk,    
	input logic reset, 
	output logic active,
	output logic[31:0] register_v0,

	// avalon memory mapped bus controller (master)
	output logic[31:0] address,
	output logic write,
	output logic read,
	input logic waitrequest,
	output logic[31:0] writedata,
	output logic[3:0] byteenable,
	input logic[31:0] readdata
);

	//VARIABLES
	
	////state machine
	logic stall;
	assign stall = (read==1 || write ==1)? waitrequest:0;
	logic[2:0] state;
	
	//instruction register
	logic[5:0] instr31_26;
    	logic[4:0] instr25_21;
    	logic[4:0] instr20_16;
    	logic[15:0] instr15_0;
	logic[4:0] instr15_11;
	logic[4:0] instr10_6;
	assign instr15_11 = readdata_to_CPU[15:11];
	assign instr10_6 = readdata_to_CPU[10:6];
	
	//pc
	logic pc_ctl;
	logic[31:0] pc_in, PC;

	//register file
	logic[4:0] readR1, readR2;
	
	//variables for mux
	logic[31:0] MEMmux2to1;
	logic[31:0] Decodemux2to1;
	logic[31:0] ALUAmux2to1;
	logic[4:0] Regmux2to1;
	logic[31:0] RegWritemux2to1;
	logic[31:0] full_instr;
	logic[31:0] HI_LO_ALUOut_to_Reg_mux;
	//logic[31:0] PC_RETURN_ADDR_ALOUT_MUX;

	//ALU Variable
    logic[31:0] ALU_result;
	logic[63:0] ALU_MULTorDIV_result;
	logic[3:0] ALUctrl;
	logic zero;
	//assign register_v0 = ALUOut;  //FOR DEBUGGING CURRENTLY, but actually reg v0 is reg of index 2 in reg file							
	logic[31:0] HI, LO;

	//reg A & B & ALUout
	logic[31:0] regA, regB, ALUOut;
	
	//control logic for MUXes
	logic[5:0] func_code;
	logic RegDst, RegWrite, ALUSrcA;
	logic[1:0] ALUSrcB, PCSource;
	logic[1:0] HI_LO_ALUOut;
	logic[3:0] ALUctl;
	logic PCWrite, PCWriteCond, JUMP; //combines in gates and added into PC block for conditional jumps
	logic IorD, MemtoReg, IRWrite, unsign, fixed_shift, branch_equal, ReturnToReg;


	//ALUmux4to1
	logic[31:0] ALUB;
	logic[31:0] readdata1;
	logic[31:0] readdata2;
	
	
	logic[31:0] writedata_from_CPU, readdata_to_CPU;
	//assign writedata_from_CPU = regB;
	
	//BLOCKS

	CPU_statemachine stm(.reset(reset), .clk(clk), .stall(stall), .state(state));
//control-main: B : PCWrite= 0
	
	//assign JUMP= (PCWriteCond | zero); //no longer used -> is done in PC block
	//for jump instrcution: JUMP asserted // For branch instrcution: PCWriteCond asserted indicate results depends on zero
	pc pc1(.stall(stall),.clk(clk), .reset(reset), .pcctl(PCWrite), .pc_prev(pc_in), .pc_new(PC),
			.PCWriteCond((JUMP | (PCWriteCond & zero))),.state(state), .active(active));
	
	//Control signals
	
	//assign opcode = Decodemux2to1[31:26];
	//assign func_code = Decodemux2to1[5:0];
	assign full_instr = {instr31_26, instr25_21, instr20_16, instr15_0};
	assign Decodemux2to1 = (state == 3'b001) ? readdata_to_CPU : full_instr; 

	control_signal_simplified_MINIMIZE control(
		.opcode(Decodemux2to1[31:26]), .func_code(Decodemux2to1[5:0]), .state(state), .rt_code(Decodemux2to1[20:16]),
		.RegDst(RegDst), .RegWrite(RegWrite), .ALUSrcA(ALUSrcA), 
		.ALUSrcB(ALUSrcB), .ALUctl(ALUctl), .PCSource(PCSource),
		.PCWrite(PCWrite), .PCWriteCond(PCWriteCond), .IorD(IorD), 
		.MemRead(read), .MemWrite(write), .MemtoReg(MemtoReg),
		.IRWrite(IRWrite), .unsign(unsign), .fixed_shift(fixed_shift),
		.JUMP(JUMP), .branch_equal(branch_equal)
	);
	
	//MUXes 	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx this might be wrong  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	data_selection_endian_conversion data_selection_endian_conversion(
		.IorD(IorD),.PC(PC),.ALUOut(HI_LO_ALUOut_to_Reg_mux),
		.opcode(Decodemux2to1[31:26]),.writedata_non_processed(regB),.readdata_non_processed(readdata),
		.writedata_processed(writedata),.readdata_processed(readdata_to_CPU),.byteenable(byteenable),.address(address),
		.state(state),.stall(stall),.clk(clk)
	);
	//assign address = MEMmux2to1;
	assign Regmux2to1 = (RegDst == 0) ? Decodemux2to1[20:16] : Decodemux2to1[15:11];
	//          xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx this might not work
	assign HI_LO_ALUOut_to_Reg_mux = (HI_LO_ALUOut == 0)? ALUOut:(HI_LO_ALUOut == 1)? HI:(HI_LO_ALUOut == 2)? LO:HI_LO_ALUOut_to_Reg_mux;
	assign RegWritemux2to1 = (MemtoReg == 0) ? HI_LO_ALUOut_to_Reg_mux : readdata_to_CPU;
	assign ALUAmux2to1 = (ALUSrcA == 0) ? PC : regA; 

	
	//ALUmux4to1
	ALUmux4to1 ALUmux4to1(
		.register_b(readdata2), .immediate(instr15_0), .ALUSrcB(ALUSrcB), 
		.ALUB(ALUB), .opcode(Decodemux2to1[31:26])
	);
	//IR
	instruction_reg IR(
		.clk(clk), .reset(reset), .IRWrite(IRWrite), .memdata(readdata_to_CPU),
		.instr31_26(instr31_26), .instr25_21(instr25_21), .instr20_16(instr20_16),
		.instr15_0(instr15_0)
	);

	//register files
	assign readR1 = Decodemux2to1[25:21];
	assign readR2 = Decodemux2to1[20:16];
	registers regfile(
		.clk(clk), .reset(reset), .RegWrite(RegWrite), .readR1(readR1), 
		.readR2(readR2), .writeR(Regmux2to1), .writedata(RegWritemux2to1),
		.readdata1(readdata1), .readdata2(readdata2) , .instr(Decodemux2to1), 
		.register_v0(register_v0), .state(state)
		);
	
	//registers A & B & ALUOut
	always_ff @(posedge clk) begin
		if (reset == 1) begin
			regA <= 0;
			regB <= 0;
			ALUOut <= 0;
		end 
		else begin
			regA <= readdata1;
			regB <= readdata2;
			if(~stall) ALUOut <= ALU_result;
		end
	end
	
	//ALU
	alu ALU(
		.ALUOperation(ALUctl), .a(ALUAmux2to1), .b(ALUB), .unsign(unsign),
		.ALU_result(ALU_result), .zero(zero), .ALU_MULTorDIV_result(ALU_MULTorDIV_result),
		.instr10_6(instr10_6), .fixed_shift(fixed_shift), .branch_equal(branch_equal)
	);

	
	always @(*) begin
	 	//$display("ALU_MULTorDIV_result = %h", ALU_MULTorDIV_result);
		$display("pc_in = %h, pc_out = %h, pcctl = %b, state = %b", pc_in, PC, PCWrite,state);
	 	$display("ALUA = %h, ALUB = %h ,ALU_MULTorDIV_result = %h, unsign=%d", ALUAmux2to1, ALUB, ALU_MULTorDIV_result, unsign);
		
		//$display("Write_in_register = %h, RegAddress = %h, RegWrite = %h, state = %b", RegWritemux2to1, Regmux2to1, RegWrite, state);
		//$display("state = %b, full_instr = %h, readR1 = %h, regA = %h, RegWrite = %h", state, full_instr, readR1, regA, RegWrite);
	 	//$display("ALU_result = %h", ALU_result);
		$display("ALUOut = %h, state = %h", ALUOut, state);
	 	//$display("writedata_from_CPU = %h, writedata = %h", writedata_from_CPU, writedata);
	 	//$display("readdata_to_CPU = %h, readdata = %h, address = %h, byteenable = %b, IorD = %d,state=%d", readdata_to_CPU, readdata, address, byteenable,IorD,state);
		$display("readdata_to_CPU = %h, writedata = %h, writemem = %d, address = %h, byteenable = %b, IorD = %d,state=%d", readdata_to_CPU, writedata, write,address, byteenable,IorD,state);
		//For HI LO
		//$display("HI = %h, LO = %h, ALU_HI_LO_MUX = %d", HI, LO, );
		$display("DatatoReg = %h, RegDst = %h, HI_LO_ALUOut = %h, RegWrite = %d, state=%d", RegWritemux2to1, Regmux2to1, HI_LO_ALUOut, RegWrite,state);
		$display("waitrequest = %h, state=%h, stall = %h", waitrequest, state, stall);
		
		//$display("Readdata_to_CPU = %h",)
	end
	
	

	//HI LO registers
	HI_LO_Control HI_LO_ControlInst(
		.clk(clk), .reset(reset), .opcode(Decodemux2to1[31:26]), .func_code(Decodemux2to1[5:0]),
		.regA(regA), .ALU_MULTorDIV_result(ALU_MULTorDIV_result), .HI(HI), .LO(LO), .state(state),
		.HI_LO_ALUOut(HI_LO_ALUOut)
	);

	//PC_LINK_ADDR
	//assign PC_RETURN_ADDR_ALOUT_MUX = (ReturnToReg==1) ? PC+4:HI_LO_ALUOut_to_Reg_mux;
	
	//rightmost mux
	PCmux3to1 pcmux(
		.ALU_result(ALU_result), .ALUOut(ALUOut), .PCSource(PCSource), .PC_in(PC),
		.instr25_21(Decodemux2to1[25:21]), .instr20_16(Decodemux2to1[20:16]), .instr15_0(Decodemux2to1[15:0]),
    	.PC_out(pc_in)
	);
	
	// endian_swap swap( // opcode input might not be used
    // 		.writedata_from_CPU(regB), .readdata_from_RAM(readdata), .opcode(Decodemux2to1[31:26]),
	// 		.byteenable_from_CPU(byteenable), 
	// 		.writedata_to_RAM(writedata), .readdata_to_CPU(readdata_to_CPU)
    // );
    
	
endmodule : mips_cpu_bus
