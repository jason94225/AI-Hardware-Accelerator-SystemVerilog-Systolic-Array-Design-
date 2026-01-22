`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_final_top ();

    localparam CLK_PERIOD = 10ns;
    localparam TIMEOUT = 1000;

    localparam BURST_SINGLE = 3'd0;
    localparam BURST_INCR   = 3'd1;
    localparam BURST_WRAP4  = 3'd2;
    localparam BURST_INCR4  = 3'd3;
    localparam BURST_WRAP8  = 3'd4;
    localparam BURST_INCR8  = 3'd5;
    localparam BURST_WRAP16 = 3'd6;
    localparam BURST_INCR16 = 3'd7;

    //from CPU
    logic hsel;
    logic [7:0] haddr;
    logic [1:0] htrans;
    logic [2:0] hsize;
    logic hwrite;
    logic [63:0] hwdata;
    logic [2:0] hburst;

    //to CPU
    logic hresp, hready;
    logic [63:0] hrdata;

    initial begin
        $dumpfile("waveform.fst");
        $dumpvars;
    end

    logic clk, n_rst;

    // clockgen
    always begin
        clk = 0;
        #(CLK_PERIOD / 2.0);
        clk = 1;
        #(CLK_PERIOD / 2.0);
    end

    task reset_dut;
    begin
        n_rst = 0;
        @(posedge clk);
        @(posedge clk);
        @(negedge clk);
        n_rst = 1;
        @(posedge clk);
        @(posedge clk);
    end
    endtask

    task clk_gen;
    integer i;
    input logic [10:0] num;
    begin
        for(i = 0; i<num; i ++) begin
            @(negedge clk);
        end
    end
    endtask

    ahb_model_updated #(
        .ADDR_WIDTH(8),
        .DATA_WIDTH(8)
    ) BFM ( .clk(clk),
        // AHB-Subordinate Side
        .hsel(hsel),
        .haddr(haddr),
        .hsize(hsize),
        .htrans(htrans),
        .hburst(hburst),
        .hwrite(hwrite),
        .hwdata(hwdata),
        .hrdata(hrdata),
        .hresp(hresp),
        .hready(hready)
    );

    // Supporting Tasks
    task reset_model;
        BFM.reset_model();
    endtask

    // Read from a register without checking the value
    task enqueue_poll ( input logic [7:0] addr, input logic [1:0] size );
    logic [63:0] data [];
        begin
            data = new [1];
            data[0] = {64'hXXXXXXXX};
            //              Fields: hsel,  R/W, addr, data, exp err,         size, burst, chk prdata or not
            BFM.enqueue_transaction(1'b1, 1'b0, addr, data,    1'b0, {1'b0, size},  3'b0,            1'b0);
        end
    endtask

    // Read from a register until a requested value is observed
    task poll_until ( input logic [7:0] addr, input logic [1:0] size, input logic [63:0] data);
        int iters;
        begin
            for (iters = 0; iters < TIMEOUT; iters++) begin
                enqueue_poll(addr, size);
                execute_transactions(1);
                if(BFM.get_last_read() == data) break;
            end
            if(iters >= TIMEOUT) begin
                $error("Bus polling timeout hit.");
            end
        end
    endtask

    // Read Transaction, verifying a specific value is read
    task enqueue_read ( input logic [7:0] addr, input logic [1:0] size, input logic [63:0] exp_read );
        logic [63:0] data [];
        begin
            data = new [1];
            data[0] = exp_read;
            BFM.enqueue_transaction(1'b1, 1'b0, addr, data, 1'b0, {1'b0, size}, 3'b0, 1'b1);
        end
    endtask

    // Write Transaction
    task enqueue_write ( input logic [7:0] addr, input logic [1:0] size, input logic [63:0] wdata );
        logic [63:0] data [];
        begin
            data = new [1];
            data[0] = wdata;
            BFM.enqueue_transaction(1'b1, 1'b1, addr, data, 1'b0, {2'b0, size}, 3'b0, 1'b0);
        end
    endtask

    // Write Transaction Intended for a different subordinate from yours
    task enqueue_fakewrite ( input logic [7:0] addr, input logic [1:0] size, input logic [63:0] wdata );
        logic [63:0] data [];
        begin
            data = new [1];
            data[0] = wdata;
            BFM.enqueue_transaction(1'b0, 1'b1, addr, data, 1'b0, {1'b0, size}, 3'b0, 1'b0);
        end
    endtask

    // Create a burst read of size based on the burst type.
    // If INCR, burst size dependent on dynamic array size
    task enqueue_burst_read ( input logic [7:0] base_addr, input logic [1:0] size, input logic [2:0] burst, input logic [63:0] data [] );
        BFM.enqueue_transaction(1'b1, 1'b0, base_addr, data, 1'b0, {1'b0, size}, burst, 1'b1);
    endtask

    // Create a burst write of size based on the burst type.
    task enqueue_burst_write ( input logic [7:0] base_addr, input logic [1:0] size, input logic [2:0] burst, input logic [63:0] data [] );
        BFM.enqueue_transaction(1'b1, 1'b1, base_addr, data, 1'b0, {1'b0, size}, burst, 1'b1);
    endtask

    // Run n transactions, where a k-beat burst counts as k transactions.
    task execute_transactions (input int num_transactions);
        BFM.run_transactions(num_transactions);
    endtask

    // Finish the current transaction
    task finish_transactions();
        BFM.wait_done();
    endtask

    final_top #() DUT (.*);

    initial begin
        n_rst = 1;
        reset_model();
        reset_dut;
        @(negedge clk);

        //hresp test
        enqueue_read(8'h01, 2'b00, 64'h1414_1414_1414_1414);
        execute_transactions(1);

        //write weight from SoC core into sram
        enqueue_write(8'h00, 2'b11, 64'h0202_0202_0202_0202);
        execute_transactions(1);
        clk_gen(15);
        enqueue_write(8'h00, 2'b11, 64'h0101_0101_0101_0101);
        execute_transactions(1);
        clk_gen(15);
        enqueue_write(8'h00, 2'b11, 64'h0303_0303_0303_0303);
        execute_transactions(1);
        clk_gen(15);
        enqueue_write(8'h00, 2'b11, 64'h0303_0303_0303_0303);
        execute_transactions(1);
        clk_gen(15);
        enqueue_write(8'h00, 2'b11, 64'h0101_0101_0101_0101);
        execute_transactions(1);
        clk_gen(15);
        enqueue_write(8'h00, 2'b11, 64'h0202_0202_0202_0202);
        execute_transactions(1);
        clk_gen(15);
        enqueue_write(8'h00, 2'b11, 64'h0202_0202_0202_0202);
        execute_transactions(1);
        clk_gen(15);
        enqueue_write(8'h00, 2'b11, 64'h0101_0101_0101_0101);
        execute_transactions(1);
        clk_gen(15);
        //read weight from sram to systolic array
        enqueue_write(8'h22, 2'b00, 64'h0000_0000_0000_0002);
        execute_transactions(1);
        clk_gen(125);

        //write input from SoC core into sram
        enqueue_write(8'h08, 2'b11, 64'h0101_0101_0101_0101);
        execute_transactions(1);
        clk_gen(15);
        enqueue_write(8'h08, 2'b11, 64'h0202_0202_0202_0202);
        execute_transactions(1);
        clk_gen(15);
        enqueue_write(8'h08, 2'b11, 64'h0303_0303_0303_0303);
        execute_transactions(1);
        clk_gen(15);
        enqueue_write(8'h08, 2'b11, 64'h0404_0404_0404_0404);
        execute_transactions(1);
        clk_gen(15);
        enqueue_write(8'h08, 2'b11, 64'h0101_0101_0101_0101);
        execute_transactions(1);
        clk_gen(15);
        enqueue_write(8'h08, 2'b11, 64'h0101_0101_0101_0101);
        execute_transactions(1);
        clk_gen(15);
        enqueue_write(8'h08, 2'b11, 64'h0101_0101_0101_0101);
        execute_transactions(1);
        clk_gen(15);
        enqueue_write(8'h08, 2'b11, 64'h0202_0202_0202_0202);
        execute_transactions(1);
        clk_gen(15);

        //read input from sram to systolic array + write output from activations into sram
        //activation mode test
        enqueue_write(8'h24, 2'b00, 64'h0000_0000_0000_0002);
        execute_transactions(1);
        //bias test (+5)
        enqueue_write(8'h10, 2'b11, 64'h0505_0505_0505_0505);
        execute_transactions(1);
        enqueue_write(8'h22, 2'b00, 64'h0000_0000_0000_0001);
        execute_transactions(1);

        clk_gen(300);
        

        //read output from sram to SoC core
        enqueue_read(8'h18, 2'b11, 64'h1414_1414_1414_1414);
        enqueue_read(8'h18, 2'b11, 64'h1414_1414_1414_1414);
        enqueue_read(8'h18, 2'b11, 64'h1414_1414_1414_1414);
        enqueue_read(8'h18, 2'b11, 64'h1414_1414_1414_1414);
        enqueue_read(8'h18, 2'b11, 64'h1414_1414_1414_1414);
        enqueue_read(8'h18, 2'b11, 64'h1414_1414_1414_1414);
        enqueue_read(8'h18, 2'b11, 64'h1414_1414_1414_1414);
        enqueue_read(8'h18, 2'b11, 64'h1414_1414_1414_1414);
        execute_transactions(8);

        


        finish_transactions();
        $finish;
    end
endmodule

/* verilator coverage_on */

