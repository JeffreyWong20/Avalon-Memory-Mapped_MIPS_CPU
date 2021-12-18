module pc(
    input logic clk,
    input logic reset,
    input logic pcctl,
    input logic stall,
    input logic[31:0] pc_prev,
    input logic PCWriteCond,
    input logic[2:0] state,
    output logic[31:0] pc_new,
    output logic active
);

    typedef enum logic[2:0]{
        FETCH_INSTR 			= 3'b000,
        DECODE 					= 3'b001,
        EXECUTE 				= 3'b010,
        MEMORY_ACCESS 			= 3'b011,
        WRITE_BACK 				= 3'b100
    } state_t;

    logic[31:0] pc_branch_address_reg, branch_reg;
    always_ff @(posedge clk) begin 
        if(reset) begin
            active <= 1;
            pc_new <= 32'hbfc00000; //change this to reset value
            pc_branch_address_reg <= 32'h00000000;
        end
        else begin  
            if(stall) begin
                pc_new <= pc_new;
            end 
            else begin
                if(PCWriteCond) begin
                    pc_branch_address_reg <= pc_prev;
                    branch_reg <= 1; 
                end
                if(branch_reg==1 && state == MEMORY_ACCESS) begin
                        pc_new <= pc_branch_address_reg;
                        branch_reg <= 0;    
                end
                if(pcctl) begin  
                    pc_new <= pc_prev;      
                end
                if (pc_new == 0) begin
                    active <= 0;
                end
            end
        end
    end

endmodule