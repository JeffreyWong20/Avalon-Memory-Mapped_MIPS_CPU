module registers(
    input logic clk,
    input logic reset,
    input logic RegWrite,
    input logic[4:0] readR1,
    input logic[4:0] readR2,
    input logic[4:0] writeR,
    input logic[31:0] writedata,
    output logic[31:0] readdata1,
    output logic[31:0] readdata2,
    //new
    //input logic[3:0] byteenable,
    input logic[31:0] instr,
    input logic[2:0] state,
    output logic[31:0] register_v0
);

    logic[5:0] opcode, regimm_rt, func_code;
    assign opcode = instr[31:26];
    assign func_code = instr[5:0];
    assign regimm_rt = instr[20:16];

    reg[31:0] register[31:0];
    assign readdata1 = register[readR1];
    assign readdata2 = register[readR2];
    assign register_v0 = register[2];
    
    logic [31:0] writedata_merged;
    typedef enum logic[5:0]{
        JAL = 6'b000011
    } opcode_list;

    typedef enum logic[5:0]{
        JALR = 6'b001001
    } func_code_list;

    typedef enum logic[4:0]{
        BGEZAL = 5'b10001,
        BLTZAL = 5'b10000
    } rt_list;
    
    typedef enum logic[2:0]{
        FETCH_INSTR 			= 3'b000,
        DECODE 					= 3'b001,
        EXECUTE 				= 3'b010,
        MEMORY_ACCESS 			= 3'b011,
        WRITE_BACK 				= 3'b100
    } state_t;

    always_ff @(posedge clk) begin
        integer i;

        if(reset) begin
            for(i=0; i<32; i=i+1) begin
                register[i] <= 0;
            end
        end

        else if(RegWrite) begin
            //
            if((opcode == JAL) | (opcode==1 & regimm_rt == BGEZAL) | (opcode==1 & regimm_rt == BLTZAL)) begin
                register[31] <= writedata;
            end
            // else if(opcode == 0 && func_code == JALR) begin
            //     // if(writeR == 0) begin 
            //     //     register[31] <= writedata;
            //     // end 
            //     // else begin
            //     register[writeR] <= writedata;
            //     // end
            // end
            //
            //else if(byteenable == 4'b0001)
            else begin
                register[writeR] <= writedata;
            end
        end

        
        
    end
/*
    always @(*) begin
        $display("writedata register: %d, writeR =%d, RegWrite = %d", writedata, writeR, RegWrite);
    end
*/
endmodule