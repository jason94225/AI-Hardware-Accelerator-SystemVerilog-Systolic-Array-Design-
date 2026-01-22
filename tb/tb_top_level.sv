`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_top_level ();

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
    
    // to array
    logic [63:0] bias;
    logic [2:0] activation_mode;
    logic        array_start; 
    logic        load;
    logic [63:0] inputs;

    // systolic array 
    logic        array_busy;

    // activation
    logic [63:0] activations;
    logic        activations_valid;

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

    top_level #() DUT (.*);
    // bus model connections
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

    logic [63:0] data [];



    initial begin
        n_rst = 1;
        //systolic array
        array_busy = 0;
        // activations
        activations = '0;
        activations_valid = 0;
        reset_model();
        reset_dut();
        @(negedge clk);

        //occupancy error
        // enqueue_read(8'h18, 2'b11, 64'h0000_ffff_0000_eeee);
        // enqueue_read(8'h20, 2'b01, 64'h0000_0000_0000_0001);
        // execute_transactions(2);

        // //write weight
        // enqueue_write(8'h00, 2'b11, 64'h000F_1100_00BB_00BB);
        // execute_transactions(1);
        // clk_gen(15);

        // //load weight
        // enqueue_write(8'h22, 2'b00, 64'h0000_0000_0000_0002);
        // execute_transactions(1);
        // clk_gen(125);

        // // write input

        // //start inference

        //output write
        // fork
        //     begin
        //         poll_until ( 8'h23, 2'b00, 64'h0000_0000_0100_0000);
        //     end
        //     begin
                // activations = 64'h0000_ffff_0000_eeee; //1
                // activations_valid = 1;
                // @(negedge clk);
                // activations_valid = 0;
                // clk_gen(15);
                // activations = 64'h0000_ffff_0000_aaaa; //2
                // activations_valid = 1;
                // @(negedge clk);
                // activations_valid = 0;
                // clk_gen(15);
                // activations = 64'h0000_ffff_0000_bbbb; //3
                // activations_valid = 1;
                // @(negedge clk);
                // activations_valid = 0;
                // clk_gen(15);
                // activations = 64'h0000_ffff_0000_cccc; //4
                // activations_valid = 1;
                // @(negedge clk);
                // activations_valid = 0;
                // clk_gen(15);
                // activations = 64'h0000_ffff_0000_dddd; //5
                // activations_valid = 1;
                // @(negedge clk);
                // activations_valid = 0;
                // clk_gen(15);
                // activations = 64'h0000_ffff_0000_eeee; //6
                // activations_valid = 1;
                // @(negedge clk);
                // activations_valid = 0;
                // clk_gen(15);
                // activations = 64'h0000_ffff_0000_ffff; //7
                // activations_valid = 1;
                // @(negedge clk);
                // activations_valid = 0;
                // clk_gen(15);
                // activations = 64'h0000_ffff_0000_9999; //8
                // activations_valid = 1;
                // @(negedge clk);
                // activations_valid = 0;
                // clk_gen(45);
        //     end
        // join

    
        //read output
        //enqueue_read(8'h00, 2'b00, 64'h0000_0000_0000_0001);
        // enqueue_read(8'h18, 2'b11, 64'h0000_ffff_0000_eeee);
        // enqueue_read(8'h20, 2'b01, 64'h0000_0000_0000_0001);
        // enqueue_read(8'h18, 2'b11, 64'h0000_ffff_0000_aaaa);
        // enqueue_read(8'h18, 2'b11, 64'h0000_ffff_0000_bbbb);

        // enqueue_read(8'h18, 2'b11, 64'h0000_ffff_0000_cccc);
        // enqueue_read(8'h18, 2'b11, 64'h0000_ffff_0000_dddd);

        // enqueue_read(8'h18, 2'b11, 64'h0000_ffff_0000_eeee);
        // enqueue_read(8'h18, 2'b11, 64'h0000_ffff_0000_ffff);
        // enqueue_read(8'h18, 2'b11, 64'h0000_ffff_0000_9999);
        // enqueue_read(8'h22, 2'b00, 64'h0000_0000_0000_0000);
        // execute_transactions(10);
        // clk_gen(1);

        //busy error
        activations_valid = 1;
        @(negedge clk);
        activations_valid = 0;
        clk_gen(5);
        enqueue_write(8'h00, 2'b11, 64'h000F_1100_00BB_00BB);
        enqueue_read(8'h20, 2'b01, 64'h0000_0000_0000_0100);
        execute_transactions(2);
        clk_gen(30);
        finish_transactions();
        $finish;
    end
endmodule

/* verilator coverage_on */

