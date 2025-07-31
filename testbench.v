module tb_sync_fifo;

    parameter DATA_WIDTH = 8;
    parameter DEPTH = 16;
    parameter PTR_SIZE = 4;

    reg clk = 0;
    reg reset;
    reg write_en;
    reg read_en;
    reg [DATA_WIDTH-1:0] data_in;
    wire [DATA_WIDTH-1:0] data_out;
    wire empty, full;

    sync_fifo #(DATA_WIDTH, DEPTH, PTR_SIZE) uut (
        .clk(clk),
        .reset(reset),
        .write_en(write_en),
        .read_en(read_en),
        .data_in(data_in),
        .data_out(data_out),
        .empty(empty),
        .full(full)
    );

    always #5 clk = ~clk; 

    initial begin
        $display("Starting FIFO test with full/empty/corner checks");
        reset = 1;
        write_en = 0;
        read_en = 0;
        data_in = 0;
        #20 reset = 0;

        // Write data 
        repeat (DEPTH) begin
            @(negedge clk);
            write_en = 1;
            data_in = $random;
            $display("Time %0t: Writing %0h", $time, data_in);
        end

        @(negedge clk);
        write_en = 1;
        data_in = 8'hAA;
        $display("Time %0t: Attempting write when FIFO is full", $time);

        @(negedge clk);
        write_en = 0;

        // Read data 
        repeat (DEPTH) begin
            @(negedge clk);
            read_en = 1;
            $display("Time %0t: Reading %0h", $time, data_out);
        end

        @(negedge clk);
        read_en = 1;
        $display("Time %0t: Attempting read when FIFO is empty", $time);

        @(negedge clk);
        read_en = 0;

        #20 $finish;
    end
endmodule
