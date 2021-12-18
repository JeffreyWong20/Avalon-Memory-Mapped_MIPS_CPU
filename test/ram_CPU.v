module ram_CPU (
    input logic clk,
    input logic[31:0] address,
    input logic[3:0] byteenable,
    input logic write,
    input logic read,
    input logic[31:0] writedata,
    output logic waitrequest,
    output logic[31:0] readdata
);

    parameter RAM_DATA_FILE = "./test/DATA_MEMORY_FILE.txt";
    parameter RAM_INIT_FILE = "./test/INITIALISED_FILE.txt";

// size 2^16
    reg [31:0] memory [65535:0];
    reg [31:0] data [65535:0];

    initial begin
        integer i;
        /* Initialise to zero by default */
        for (i=0; i<100; i++) begin
            memory[i]=0;
        end
        
        for (i=0; i<100; i++) begin
            data[i]=0;
        end

        //Load contents from file if specified
        if (RAM_INIT_FILE != "") begin
            $display("RAM : INIT : Loading RAM contents from %s", RAM_INIT_FILE);
            $display("RAM : DATA : Loading DATA contents from %s", RAM_DATA_FILE);
            $readmemh(RAM_DATA_FILE, data);
            $readmemh(RAM_INIT_FILE, memory);
        end
        
    end
    

    always @(*) begin
    	$display("ram: read = %b, wordaddress = %h, readdata = %h", read, word_address, readdata);
        $display("ram: write = %b, wordaddress = %h, writedata = %h", write, word_address, writedata);
    end
    

    logic[31:0] word_address;
    assign word_address = (address >= 32'hbfc00000) ? (address-32'hbfc00000)/4 : address/4;

    logic[31:0] writedata_temp, readdata_temp_shift, readdata_temp;
    logic[7:0] readdata_3, readdata_2, readdata_1, readdata_0;

    assign readdata_temp = (address >= 32'hbfc00000) ? memory[word_address] : data[word_address];

    assign readdata_3 = (byteenable[3] == 1) ? readdata_temp[7:0] : 8'h00;
    assign readdata_2 = (byteenable[2] == 1) ? readdata_temp[15:8] : 8'h00;
    assign readdata_1 = (byteenable[1] == 1) ? readdata_temp[23:16] : 8'h00;
    assign readdata_0 = (byteenable[0] == 1) ? readdata_temp[31:24] : 8'h00;

    
    logic[7:0] writedata_3, writedata_2, writedata_1, writedata_0;


    assign writedata_3 = (byteenable[3]) ? writedata[31:24] : readdata_temp[7:0];
    assign writedata_2 = (byteenable[2]) ? writedata[23:16] : readdata_temp[15:8];
    assign writedata_1 = (byteenable[1]) ? writedata[15:8] : readdata_temp[23:16];
    assign writedata_0 = (byteenable[0]) ? writedata[7:0] : readdata_temp[31:24];




    /* synchronous read path. */
    
    always_ff @(posedge clk) begin
        //$display("RAM : INFO : read=%h, addr = %h, mem=%h", read, address, memory[address]);
        waitrequest <= $urandom_range(0, 1);
        //waitrequest <= 0;
        if (waitrequest) begin 
            readdata <= 32'hxxxxxxxx;
        end
        else if (write) begin

            data[word_address] <= {writedata_0, writedata_1, writedata_2, writedata_3};
        end
        else if(read) begin
            //$display("Im reading, address = %h", address);
            readdata <= {readdata_3, readdata_2, readdata_1, readdata_0};
        end
    end
 
endmodule
