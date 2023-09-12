
module axi_stream_insert_header (
parameter DATA_WD = 32,
parameter DATA_BYTE_WD = DATA_WD / 8,
parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD)
??
  
  input wire clk,
  input wire rst,
  input wire [DATA_WD-1:0] data_in,
  input wire valid_in,
  input wire ready_in,
  input wire [DATA_BYTE_WD -1:0] keep_in,
  input wire last_in,
  input wire [DATA_WD-1:0] data_insert,
  input wire valid_insert,
  input wire ready_insert,
  input wire [DATA_BYTE_WD-1:0] keep_insert,
  input wire [BYTE_CNT_WD:0] byte_insert_cnt,
  output wire [DATA_WD-1:0] data_out,
  output wire valid_out,
  output wire ready_out,
  output wire [DATA_BYTE_WD-1:0] keep_out,
  output wire last_out
);

  // ????????
  localparam IDLE = 2'b00;
  localparam HEADER = 2'b01;
  localparam DATA = 2'b10;

  // ????????
  reg [1:0] state;
  reg [DATA_WD-1:0] data_reg;
  reg [DATA_BYTE_WD-1:0] keep_reg;
  reg last_reg;
  reg [BYTE_CNT_WD:0] byte_cnt;
  reg [DATA_WD-1:0] header_reg;
  reg [DATA_BYTE_WD-1:0] header_keep;
  reg [BYTE_CNT_WD:0] header_byte_cnt;
  reg [BYTE_CNT_WD:0] header_skip_cnt;

  // ??????
  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      state <= IDLE;
      data_reg <= 0;
      keep_reg <= 0;
      last_reg <= 0;
      byte_cnt <= 0;
      header_reg <= 0;
      header_keep <= 0;
      header_byte_cnt <= 0;
      header_skip_cnt <= 0;
    end else begin
      case (state)
        IDLE: begin
          if (valid_in && ready_insert) begin
            state <= HEADER;
            header_reg <= data_insert;
            header_keep <= keep_insert;
            header_byte_cnt <= byte_insert_cnt;
            header_skip_cnt <= 0;
          end else if (valid_in && ready_in) begin
            state <= DATA;
            data_reg <= data_in;
            keep_reg <= keep_in;
            last_reg <= last_in;
            byte_cnt <= 0;
          end else begin
            state <= IDLE;
          end
        end
        HEADER: begin
          if (header_skip_cnt < $countones(header_keep)) begin
            header_skip_cnt <= header_skip_cnt + 1;
          end else if (valid_in && ready_in) begin
            state <= DATA;
            data_reg <= data_in;
            keep_reg <= keep_in;
            last_reg <= last_in;
            byte_cnt <= 0;
          end else begin
            state <= HEADER;
          end
        end
        DATA: begin
          if (byte_cnt < $countones(keep_reg)) begin
            data_out <= data_reg;
            keep_out <= keep_reg;
            valid_out <= 1;
            byte_cnt <= byte_cnt + 1;
            if (byte_cnt == $countones(keep_reg)-1 && last_reg) begin
              last_out <= 1;
            end else begin
              last_out <= 0;
            end
            if (valid_in && ready_in) begin
              data_reg <= data_in;
              keep_reg <= keep_in;
              last_reg <= last_in;
              byte_cnt <= 0;
            end else begin
              data_reg <= {data_reg[DATA_WD-1], data_reg[DATA_WD-1:8]};
              keep_reg <= {keep_reg[DATA_BYTE_WD-1], keep_reg[DATA_BYTE_WD-1:1]};
              last_reg <= 0;
            end
          end else if (header_byte_cnt > 0) begin
            data_out <= header_reg;
            keep_out <= header_keep;
            valid_out <= 1;
            byte_cnt <= byte_cnt + 1;
            header_byte_cnt <= header_byte_cnt - 1;
            if (header_byte_cnt == 1) begin
              last_out <= 1;
            end else begin
              last_out <= 0;
            end
            header_reg <= {header_reg[DATA_WD-1], header_reg[DATA_WD-1:8]};
            header_keep <= {header_keep[DATA_BYTE_WD-1], header_keep[DATA_BYTE_WD-1:1]};
          end else if (valid_in && ready_insert) begin
            state <= HEADER;
            header_reg <= data_insert;
            header_keep <= keep_insert;
            header_byte_cnt <= byte_insert_cnt;
            header_skip_cnt <= 0;
          end else begin
            state <= DATA;
          end
        end
      endcase
    end
  end

  // ??????
  assign ready_out = state == DATA ? ready_in : 1;
  assign valid_out = state == DATA ? valid_in : 0;

endmodule
