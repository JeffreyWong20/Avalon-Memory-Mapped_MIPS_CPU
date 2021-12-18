module CPU_statemachine (
    input logic reset,
    input logic clk,
    input logic stall,
    output logic[2:0] state
);
    
    typedef enum logic[2:0]{
        FETCH_INSTR     = 3'b000,
        DECODE          = 3'b001,
        EXECUTE         = 3'b010,
        MEMORY_ACCESS   = 3'b011,
        WRITE_BACK      = 3'b100
    } state_t;
    
    always @(posedge clk) begin
        if(reset) begin 
            state <= FETCH_INSTR;
        end
        else if(stall) begin 
            state <= state;
        end
        else begin
            //what about jumps? we need to adapt the state machine for those !!!!
            if(state==FETCH_INSTR) state <= DECODE;
            else if(state==DECODE) state <= EXECUTE;
            else if(state==EXECUTE) state <= MEMORY_ACCESS;
            else if(state==MEMORY_ACCESS) state <= WRITE_BACK;
            else if(state==WRITE_BACK) state <= FETCH_INSTR;
        end
        //$display("stm - state: ",state);
    end
    
endmodule