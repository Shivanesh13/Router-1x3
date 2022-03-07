module router_fsm_tb (
    
);
    reg clk,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full;
    reg low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2;
    reg [1:0]data_in;
    wire detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state,busy;
    parameter T=5;
    reg [3*8:0]str_state;
    
    router_fsm DUT(clk,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,data_in,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state,busy);


    initial begin
        clk = 0;
        forever begin
            #(T) clk = ~clk;
        end
    end

    initial begin
        initialize;
        reset;
        delay;
        OP_1;
        delay;
        $display("----------------------------------");
        initialize;
        reset;
        delay;
        OP_2;
        delay;
        $display("----------------------------------");
        initialize;
        reset;
        delay;
        OP_3;
        delay;
        $display("----------------------------------");
        initialize;
        reset;
        delay;
        OP_4;
        delay;
        $finish;
    end

    always @(*) begin
        case(DUT.State) 
            3'b000: str_state = "DA";
            3'b001: str_state = "LFD";
            3'b010: str_state = "WTE";
            3'b011: str_state = "LD";
            3'b100: str_state = "LP";
            3'b101: str_state = "FFS";
            3'b110: str_state = "CPE";
            3'b111: str_state = "LAF";
        endcase
    end

    always @(str_state) begin
        $display("Present State: %s", str_state);
    end

    // DA-LFD-LD-LP-CPE-DA
    task OP_1;
    integer i;
    begin
        @(negedge clk);
        pkt_valid = 1'b1;
        data_in = 2'b00;
        fifo_empty_0 = 1'b1;
        @(negedge clk);
        pkt_valid = 1'b0;
        fifo_full = 1'b0;
        for(i=0;i<5;i=i+1) @(negedge clk);
    end
    endtask

    task clk_delay;
    input N;
    begin
        repeat(N) delay;
    end
    endtask

    // DA-LFD-LD-FFS-LAF-LD-LP-CPE-DA
    task OP_3;
    integer i;
    begin
        @(negedge clk);
        pkt_valid = 1'b1;
        data_in = 2'b00;
        fifo_empty_0 = 1'b1;
        @(negedge clk);
        fifo_full = 1'b1;
        @(negedge clk);
        fifo_full = 1'b0;
        @(negedge clk);
        parity_done = 1'b0;
        low_pkt_valid = 1'b0;
        @(negedge clk);
        fifo_full = 1'b0;
        pkt_valid = 1'b0;
        @(negedge clk);
        @(negedge clk);
        pkt_valid = 1'b0;
        for(i=0;i<5;i=i+1) @(negedge clk);
    end
    endtask

    task OP_4;
    integer i;
    begin
        @(negedge clk);
        pkt_valid = 1'b1;
        data_in = 2'b00;
        fifo_empty_0 = 1'b1;
        @(negedge clk);
        @(negedge clk);
        pkt_valid = 1'b0;
        fifo_full = 1'b0;
        @(negedge clk);
        @(negedge clk);
        fifo_full = 1'b1;
        @(negedge clk);
        fifo_full = 1'b0;
        @(negedge clk);
        parity_done = 1'b1;
        for(i=0;i<5;i=i+1) @(negedge clk);
    end
    endtask


    // DA-LFD-LD-FFS-LAF-LP-CPE-DA
    task OP_2;
    integer i;
    begin
        @(negedge clk);
        pkt_valid = 1'b1;
        data_in = 2'b00;
        fifo_empty_0 = 1'b1;
        @(negedge clk);
        fifo_full = 1'b1;
        @(negedge clk);
        fifo_full = 1'b0;
        @(negedge clk);
        parity_done = 1'b0;
        low_pkt_valid = 1'b1;
        @(negedge clk);
        @(negedge clk);
        fifo_full = 1'b0;
        @(negedge clk);
        pkt_valid = 1'b0;
        for(i=0;i<5;i=i+1) @(negedge clk);
    end
    endtask



    // RESET
    task reset;
    begin
        @(negedge clk)resetn = 0;
        @(negedge clk)resetn = 1;
    end
    endtask


    // Initialize
    task initialize; 
    begin
        resetn = 1;
        {pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2} = 10'b0;
    end
    endtask

    // Delay
    task delay;
    begin
        #(2*T);
    end
    endtask
endmodule