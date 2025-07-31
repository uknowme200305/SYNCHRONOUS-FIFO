module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16,
    parameter PTR_SIZE = 4
)(
    input wire clk,
    input wire reset,
    input wire write_en,
    input wire read_en,
    input wire [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output wire empty,
    output wire full
);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [PTR_SIZE-1:0] wr_ptr, rd_ptr;
    reg [PTR_SIZE:0] count;

    assign empty = (count == 0);
    assign full  = (count == DEPTH);

    // Write logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wr_ptr <= 0;
        end else if (write_en && !full) begin
            mem[wr_ptr] <= data_in;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // Read logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rd_ptr <= 0;
            data_out <= 0;
        end else if (read_en && !empty) begin
            data_out <= mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
        end
    end

    // Count logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
        end else begin
            case ({write_en && !full, read_en && !empty})
                2'b10: count <= count + 1;
                2'b01: count <= count - 1;
                default: count <= count;
            endcase
        end
    end

endmodule
