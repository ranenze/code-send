 
 
module axi_stream_insert_header_tb;

parameter DATA_WIDTH = 32;
parameter KEEP_WIDTH = DATA_WIDTH / 8;

reg clk;
reg rst;
reg [DATA_WIDTH-1:0] data_insert;
reg valid_insert;
wire ready_insert;
reg [DATA_WIDTH-1:0] data_in;
reg last_in;
reg [KEEP_WIDTH-1:0] keep_in;
reg valid_in;
wire [DATA_WIDTH-1:0] data_out;
wire last_out;
wire [KEEP_WIDTH-1:0] keep_out;
wire valid_out;
reg ready_out;

axi_stream_insert_header dut (
    .clk(clk),
    .rst(rst),
    .data_insert(data_insert),
    .valid_insert(valid_insert),
    .ready_insert(ready_insert),
    .data_in(data_in),
    .last_in(last_in),
    .keep_in(keep_in),
    .valid_in(valid_in),
    .data_out(data_out),
    .last_out(last_out),
    .keep_out(keep_out),
    .valid_out(valid_out),
    .ready_out(ready_out)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    rst = 1;
    data_insert = 0;
    valid_insert = 0;
    data_in = 0;
    last_in = 0;
    keep_in = 0;
    valid_in = 0;
    ready_out = 0;
    #10 rst = 0;
end

// ????1??????header?????
initial begin
    #20;
    assert(data_out == 0);
    assert(last_out == 0);
    assert(keep_out == 0);
    assert(valid_out == 0);
end

// ????2?????????header????
initial begin
    data_in = 32'h12345678;
    last_in = 0;
    keep_in = {KEEP_WIDTH{1'b1}};
    valid_in = 1;
    ready_out = 1;
    #20;
    assert(data_out == data_in);
    assert(last_out == last_in);
    assert(keep_out == keep_in);
    assert(valid_out == valid_in);
end

// ????3????????header?????
initial begin
    data_insert = 32'h12345678;
    valid_insert = 1;
    ready_insert = 1;
    ready_out = 1;
    #20;
    assert(data_out == data_insert);
    assert(last_out == 0);
    assert(keep_out == {KEEP_WIDTH{1'b1}});
    assert(valid_out == 1);
end

// ????4??????header??????
initial begin
    data_insert = 32'h12345678;
    valid_insert = 1;
    ready_insert = 1;
    data_in = 32'habcdef01;
    last_in = 0;
    keep_in = {KEEP_WIDTH{1'b1}};
    valid_in = 1;
    ready_out = 1;
    #20;
    assert(data_out == data_insert);
    assert(last_out == 0);
    assert(keep_out == {KEEP_WIDTH{1'b1}});
    assert(valid_out == 1);
    #10;
    assert(data_out == data_in);
    assert(last_out == last_in);
    assert(keep_out == keep_in);
    assert(valid_out == valid_in);
end

endmodule
 

 

