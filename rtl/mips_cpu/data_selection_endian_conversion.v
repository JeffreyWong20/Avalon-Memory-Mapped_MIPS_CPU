module data_selection_endian_conversion (
  //Address Input
  input logic IorD,
  input logic [31:0]PC,
  input logic[31:0] ALUOut,

  input stall,
  input clk,
  input logic[2:0] state,

  input logic[5:0] opcode,
  input logic[31:0] writedata_non_processed, //reg B (rt)
  input logic[31:0] readdata_non_processed,

  output logic[31:0] writedata_processed,
  output logic[31:0] readdata_processed,
  output logic[3:0] byteenable,
  output logic[31:0] address
);
  typedef enum logic[5:0] {
  //load/store
    LB	= 6'b100000,
    LH 	= 6'b100001,
    LWL	= 6'b100010,
    LW 	= 6'b100011,
    LBU	= 6'b100100,
    LHU	= 6'b100101,
    LWR = 6'b100110,
    SB  = 6'b101000,
    SH	= 6'b101001,
    SW 	= 6'b101011
  } memory_reference_opcode_list;

  logic[3:0] byteenable_read; 

  assign address = (IorD == 0) ? PC : {ALUOut[31:2],2'b00}; //MEMmux2to1

  always_ff @(posedge clk) begin
    if(stall != 1) byteenable_read <= byteenable;
  end

  always @(*) begin
    if((IorD == 0 && state==0)|| (IorD == 0 && state==1)) begin
      byteenable = 4'b1111;
      readdata_processed[7:0] = readdata_non_processed[31:24];
      readdata_processed[15:8] = readdata_non_processed[23:16];
      readdata_processed[23:16] = readdata_non_processed[15:8];
      readdata_processed[31:24] = readdata_non_processed[7:0];
    end
    else begin
    case(opcode)
    LW: begin
      byteenable = 4'b1111;
      readdata_processed[7:0] = readdata_non_processed[31:24];
      readdata_processed[15:8] = readdata_non_processed[23:16];
      readdata_processed[23:16] = readdata_non_processed[15:8];
      readdata_processed[31:24] = readdata_non_processed[7:0];
    end
    SW: begin  
      byteenable = 4'b1111;
      writedata_processed[7:0] = writedata_non_processed[31:24];
      writedata_processed[15:8] = writedata_non_processed[23:16];
      writedata_processed[23:16] = writedata_non_processed[15:8];
      writedata_processed[31:24] = writedata_non_processed[7:0];
    end
    LB: begin
      if(ALUOut[1:0]==2'b00) byteenable = 4'b0001;
      else if(ALUOut[1:0]==2'b01) byteenable = 4'b0010;
      else if(ALUOut[1:0]==2'b10) byteenable = 4'b0100;
      else if(ALUOut[1:0]==2'b11) byteenable = 4'b1000;

      if(byteenable_read == 4'b0001) readdata_processed[7:0] = readdata_non_processed[7:0];
      else if(byteenable_read == 4'b0010) readdata_processed[7:0] = readdata_non_processed[15:8];
      else if(byteenable_read == 4'b0100) readdata_processed[7:0] = readdata_non_processed[23:16];
      else if(byteenable_read == 4'b1000) readdata_processed = readdata_non_processed[31:24];
      if(readdata_processed[7]==1)begin
        readdata_processed[31:8] = 24'hffffff;
      end
      else begin
        readdata_processed[31:8] = 24'h0;
      end 
    end
    LBU: begin
      if(ALUOut[1:0]==2'b00) byteenable = 4'b0001;
      else if(ALUOut[1:0]==2'b01) byteenable = 4'b0010;
      else if(ALUOut[1:0]==2'b10) byteenable = 4'b0100;
      else if(ALUOut[1:0]==2'b11) byteenable = 4'b1000;

      if(byteenable_read == 4'b0001) readdata_processed[7:0] = readdata_non_processed[7:0];
      else if(byteenable_read == 4'b0010) readdata_processed[7:0] = readdata_non_processed[15:8];
      else if(byteenable_read == 4'b0100) readdata_processed[7:0] = readdata_non_processed[23:16];
      else if(byteenable_read == 4'b1000) readdata_processed = readdata_non_processed[31:24];
      readdata_processed[31:8] = 24'h0;
    end
    SB: begin
      if(ALUOut[1:0]==2'b00) begin
        byteenable = 4'b0001;
        writedata_processed[7:0] = writedata_non_processed[7:0];   
      end
      else if(ALUOut[1:0]==2'b01) begin
        byteenable = 4'b0010;
        writedata_processed[15:8] = writedata_non_processed[7:0];
      end
      else if(ALUOut[1:0]==2'b10) begin
        byteenable = 4'b0100;
        writedata_processed[23:16] = writedata_non_processed[7:0];
      end
      else if(ALUOut[1:0]==2'b11) begin
        if(state==3) byteenable = 4'b1000;
        writedata_processed[31:24] = writedata_non_processed[7:0];
      end   
    end
    LH: begin
      if(ALUOut[1:0]==2'b00) byteenable = 4'b0011;
      else if(ALUOut[1:0]==2'b10) byteenable = 4'b1100;

      if(byteenable_read == 4'b0011) readdata_processed = {readdata_non_processed[7:0],readdata_non_processed[15:8]};
      if(byteenable_read == 4'b1100) readdata_processed = {readdata_non_processed[23:16],readdata_non_processed[31:24]};
      if(readdata_processed[15]==1)begin
        readdata_processed[31:16] = 24'hffff;
      end
      else begin
        readdata_processed[31:16] = 24'h0;
      end 
    end
    LHU: begin
      if(ALUOut[1:0]==2'b00) byteenable = 4'b0011;
      else if(ALUOut[1:0]==2'b10) byteenable = 4'b1100;

      if(byteenable_read == 4'b0011) readdata_processed = {readdata_non_processed[7:0],readdata_non_processed[15:8]};
      if(byteenable_read == 4'b1100) readdata_processed = {readdata_non_processed[23:16],readdata_non_processed[31:24]};
      readdata_processed[31:16] = 24'h0;
    end
    SH: begin
      if(ALUOut[1:0]==0) begin
        if(state==3) byteenable = 4'b0011;
        writedata_processed[7:0] = writedata_non_processed[15:8];
        writedata_processed[15:8] = writedata_non_processed[7:0];
      end
      else if(ALUOut[1:0]==2'b10) begin
        if(state==3) byteenable = 4'b1100;
        writedata_processed[23:16] = writedata_non_processed[15:8];
        writedata_processed[31:24] = writedata_non_processed[7:0];
      end 
    end
    LWL: begin //state deleted?
      if(ALUOut[1:0]==2'b00 && state==3) byteenable = 4'b1111; 
      else if(ALUOut[1:0]==2'b01 && state==3) byteenable = 4'b1110;
      else if(ALUOut[1:0]==2'b10 && state==3) byteenable = 4'b1100;
      else if(ALUOut[1:0]==2'b11 && state==3) byteenable = 4'b1000;
      
      if(byteenable_read == 4'b1111) begin
        readdata_processed[7:0] = readdata_non_processed[31:24]; //invert
        readdata_processed[15:8] = readdata_non_processed[23:16];
        readdata_processed[23:16] = readdata_non_processed[15:8];
        readdata_processed[31:24] = readdata_non_processed[7:0];
      end
      else if(byteenable_read == 4'b1110) begin
        readdata_processed[7:0] = writedata_non_processed[7:0]; 
        readdata_processed[15:8] = readdata_non_processed[31:24];//invert
        readdata_processed[23:16] = readdata_non_processed[23:16];
        readdata_processed[31:24] = readdata_non_processed[15:8];
      end
      else if(byteenable_read == 4'b1100) begin
        readdata_processed[7:0] = writedata_non_processed[7:0];
        readdata_processed[15:8] = writedata_non_processed[15:8];
        readdata_processed[23:16] = readdata_non_processed[31:24]; //invert
        readdata_processed[31:24] = readdata_non_processed[23:16];
      end
      else if(byteenable_read == 4'b1000) begin
        readdata_processed[7:0] = writedata_non_processed[7:0]; 
        readdata_processed[15:8] = writedata_non_processed[15:8]; 
        readdata_processed[23:16] = writedata_non_processed[23:16]; 
        readdata_processed[31:24] = readdata_non_processed[31:24];//invert
      end
    end
    LWR: begin
      if(ALUOut[1:0]==2'b00 && state==3) byteenable = 4'b0001; 
      else if(ALUOut[1:0]==2'b01 && state==3) byteenable = 4'b0011;
      else if(ALUOut[1:0]==2'b10 && state==3) byteenable = 4'b0111;
      else if(ALUOut[1:0]==2'b11 && state==3) byteenable = 4'b1111;

      if(byteenable_read == 4'b0001) begin
        readdata_processed[7:0] = readdata_non_processed[7:0];// 
        readdata_processed[15:8] = writedata_non_processed[15:8]; 
        readdata_processed[23:16] = writedata_non_processed[23:16]; 
        readdata_processed[31:24] = writedata_non_processed[31:24];
      end
      if(byteenable_read == 4'b0011) begin
        readdata_processed[7:0] = readdata_non_processed[15:8];// 
        readdata_processed[15:8] = readdata_non_processed[7:0];//invert
        readdata_processed[23:16] = writedata_non_processed[23:16];
        readdata_processed[31:24] = writedata_non_processed[31:24];
      end
      if(byteenable_read == 4'b0111) begin
        readdata_processed[7:0] = readdata_non_processed[23:16];//
        readdata_processed[15:8] = readdata_non_processed[15:8];//
        readdata_processed[23:16] = readdata_non_processed[7:0];//
        readdata_processed[31:24] = writedata_non_processed[31:24];
      end
      if(byteenable_read == 4'b1111) begin
        readdata_processed[7:0] = readdata_non_processed[31:24]; //invert
        readdata_processed[15:8] = readdata_non_processed[23:16];
        readdata_processed[23:16] = readdata_non_processed[15:8];
        readdata_processed[31:24] = readdata_non_processed[7:0];
      end
    end
    endcase  
    end
  end

endmodule