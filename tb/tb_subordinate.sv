`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_subordinate ();

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
        @(negedge clk);
        @(negedge clk);
    end
    endtask

    logic hsel;
    logic [7:0] haddr;
    logic [2:0] hsize;
    logic [2:0] hburst;
    logic [1:0] htrans;
    logic hwrite;
    logic [63:0] hwdata;
    logic [63:0] hrdata;
    logic hresp;
    logic hready;

    logic [63:0] weight_data;
    logic [63:0] input_data;
    logic [63:0] bias;
    logic start_inference;
    logic load_weight;
    logic [2:0] activation_mode;
    logic write_weight;
    logic write_input;
    logic [63:0] output_data;
    logic occupancy_err_i, occupancy_err_o, occupancy_err_w;
    logic device_busy_err;
    logic data_ready;
    logic design_busy;
    logic output_read;



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

   // subordinate
    subordinate #() SUB(
        .clk(clk),
        .n_rst(n_rst),
        .output_data(output_data),
        .occupancy_err_i(occupancy_err_i),
        .occupancy_err_o(occupancy_err_o),
        .occupancy_err_w(occupancy_err_w),
        .device_busy_err(device_busy_err),
        .data_ready(data_ready),
        .design_busy(design_busy),
        .hsel(hsel),
        .haddr(haddr),
        .htrans(htrans),
        .hsize(hsize),
        .hwrite(hwrite),
        .hwdata(hwdata),
        .hburst(hburst),
        .weight_data(weight_data),
        .input_data(input_data),
        .bias(bias),
        .start_inference(start_inference),
        .load_weight(load_weight),
        .activation_mode(activation_mode),
        .write_weight(write_weight),
        .write_input(write_input),
        .hresp(hresp),
        .hready(hready),
        .hrdata(hrdata),
        .output_read(output_read)
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
        output_data = '0;
        occupancy_err_i = 0;
        occupancy_err_o = 0;
        occupancy_err_w = 0;
        device_busy_err = 0;
        data_ready = 0;
        design_busy = 0;
        reset_model();
        reset_dut();
        

        /****** EXAMPLE CODE ******/
        // Always put data LSB-aligned. The model will automagically move bytes to their proper position.
        enqueue_write(8'h10, 2'b11, 64'h000F_1100_00BB_00BB);
        execute_transactions(1);

        enqueue_read(8'h10, 2'b11, 64'h000F_1100_00BB_00BB);
        execute_transactions(1);
        enqueue_write(8'h10, 2'b11, 64'h00FF_2200_00CC_00CC);
        enqueue_read(8'h10, 2'b11, 64'h00FF_2200_00CC_00CC);
        execute_transactions(2);


        output_data = 64'h0000_0000_0000_BBCC;

        enqueue_write(8'h10, 2'b11, 64'h0000_0000_CC00_CCCC);
        execute_transactions(1);
        enqueue_read(8'h18, 2'b11, 64'h0000_0000_0000_BBCC);
        enqueue_read(8'h14, 2'b01, 64'h0000_0000_0000_0000);
        execute_transactions(2);
        fork
            begin
                @(posedge clk);
                design_busy = 1;
                @(posedge clk);
                @(posedge clk);
                @(posedge clk);
                design_busy = 0;
            end
        join

        enqueue_read(8'h10, 2'b11, 64'h0000_0000_CC00_CCCC);
        execute_transactions(1);
        enqueue_write(8'h10, 2'b00, 64'h0000_0000_0000_00DD);
        enqueue_read(8'h10, 2'b01, 64'h0000_0000_CC00_CCDD);
        execute_transactions(2);
        fork
            begin
                @(posedge clk);
                design_busy = 1;
                @(posedge clk);
                @(posedge clk);
                @(posedge clk);
                design_busy = 0;
            end
        join

        enqueue_write(8'h10, 2'b00, 64'h0000_0000_0000_00EE);
        enqueue_write(8'h18, 2'b00, 64'h0000_0000_0000_0002);
        execute_transactions(2);
        enqueue_read(8'h11, 2'b00, 64'h0000_0000_0000_00EE);
        execute_transactions(1);

        

        enqueue_write(8'h01, 2'b00, 64'h0000_0000_0000_DD00);
        execute_transactions(1);
        enqueue_write(8'h09, 2'b00, 64'h0000_0000_0000_DD00);
        execute_transactions(1);
        enqueue_write(8'h22, 2'b00, 64'h0000_0000_0000_0001);
        execute_transactions(1);
        enqueue_write(8'h22, 2'b00, 64'h0000_0000_0000_0010);
        execute_transactions(1);

        //18
        occupancy_err_i = 1;
        enqueue_write(8'h08, 2'b00, 64'h0000_0000_0000_0010);
        enqueue_read(8'h20, 2'b00, 64'h0000_0000_0000_0001);
        execute_transactions(2);
        enqueue_write(8'h00, 2'b00, 64'h0000_0000_0000_0010);
        enqueue_read(8'h20, 2'b00, 64'h0000_0000_0000_0000);
        execute_transactions(2);
        enqueue_read(8'h18, 2'b00, 64'h0000_0000_0000_0010);
        enqueue_read(8'h20, 2'b00, 64'h0000_0000_0000_0000);
        execute_transactions(2);
        occupancy_err_o = 1;
        enqueue_write(8'h08, 2'b00, 64'h0000_0000_0000_0010);
        enqueue_read(8'h20, 2'b00, 64'h0000_0000_0000_0001);
        execute_transactions(2);
        enqueue_write(8'h00, 2'b00, 64'h0000_0000_0000_0010);
        enqueue_read(8'h20, 2'b00, 64'h0000_0000_0000_0000);
        execute_transactions(2);
        enqueue_read(8'h18, 2'b00, 64'h0000_0000_0000_0010);
        enqueue_read(8'h20, 2'b00, 64'h0000_0000_0000_0001);
        execute_transactions(2);
        occupancy_err_w = 1;
        enqueue_write(8'h08, 2'b00, 64'h0000_0000_0000_0010);
        enqueue_read(8'h20, 2'b00, 64'h0000_0000_0000_0001);
        execute_transactions(2);
        enqueue_write(8'h00, 2'b00, 64'h0000_0000_0000_0010);
        enqueue_read(8'h20, 2'b00, 64'h0000_0000_0000_0001);
        execute_transactions(2);
        enqueue_read(8'h18, 2'b00, 64'h0000_0000_0000_0010);
        enqueue_read(8'h20, 2'b00, 64'h0000_0000_0000_0001);
        execute_transactions(2);
        occupancy_err_i = 0;
        occupancy_err_o = 0;
        occupancy_err_w = 0;

        //start inference
        enqueue_write(8'h22, 2'b00, 64'h0000_0000_0000_0001);
        enqueue_read(8'h22, 2'b00, 64'h0000_0000_0000_0001);
        execute_transactions(2);
        enqueue_read(8'h20, 2'b00, 64'h0000_0000_0000_0000);
        execute_transactions(1);
        enqueue_write(8'h22, 2'b00, 64'h0000_0000_0000_0002);
        enqueue_read(8'h22, 2'b00, 64'h0000_0000_0000_0002);
        execute_transactions(2);
        design_busy = 1;
        enqueue_read(8'h23, 2'b00, 64'h0000_0000_0000_0002);
        execute_transactions(1);
        design_busy = 0;
        data_ready = 1;
        enqueue_read(8'h23, 2'b00, 64'h0000_0000_0000_0001);
        execute_transactions(1);
        data_ready = 0;
        enqueue_read(8'h23, 2'b00, 64'h0000_0000_0000_0000);
        execute_transactions(1);
        enqueue_write(8'h24, 2'b00, 64'h0000_0000_0000_0003);
        enqueue_read(8'h24, 2'b00, 64'h0000_0000_0000_0003);
        execute_transactions(2);
        enqueue_read(8'h24, 2'b00, 64'h0000_0000_0000_0003);
        enqueue_read(8'h24, 2'b00, 64'h0000_0000_0000_0003);
        execute_transactions(2);





        // fork
        //     begin
        //         @(posedge clk);
        //         design_busy = 1;
        //         @(posedge clk);
        //         @(posedge clk);
        //         @(posedge clk);
        //         design_busy = 0;
        //     end
        // join
        // enqueue_read(8'h13, 2'b00, 64'h0000_0000_0000_0004);
        // enqueue_read(8'h14, 2'b00, 64'h0000_0000_0000_0005);
        // execute_transactions(2);
        // enqueue_read(8'h15, 2'b00, 64'h0000_0000_0000_0006);
        // enqueue_read(8'h16, 2'b00, 64'h0000_0000_0000_00BB);
        // execute_transactions(2);
        // enqueue_read(8'h01, 2'b00, 64'h0000_0000_0000_00BB);
        // enqueue_read(8'h17, 2'b00, 64'h0000_0000_0000_00BB);
        // execute_transactions(2);
        // enqueue_read(8'h18, 2'b00, 64'h0000_0000_0000_00BB);
        // enqueue_read(8'h19, 2'b00, 64'h0000_0000_0000_00BB);
        // execute_transactions(2);
        // Example Burst Setup - Dynamic Array Required

        // data = new [8];
        // data = {63'h8888_8888, 63'h7777_7777,63'h6666_6666,63'h5555_5555,63'h4444_4444,63'h3333_3333,63'h2222_2222,63'h1111_1111};
        // enqueue_burst_read(4'hC, 1'b1, BURST_WRAP8, data);
        // execute_transactions(10); // Burst counts as 8 transactions for 8 beats

        finish_transactions();
        /****** EXAMPLE CODE ******/

        $finish;
    end
endmodule
/* verilator coverage_on */

