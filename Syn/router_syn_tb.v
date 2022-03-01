module router_syn_tb (
);
    reg clk,resetn,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2;
    reg [1:0]data_in;
    wire fifo_full,soft_reset_0,soft_reset_1,soft_reset_2,vld_out_0,vld_out_1,vld_out_2;
    wire [2:0]write_enb;
    parameter T = 5;

    router_syn DUT(clk,resetn,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,data_in,fifo_full,soft_reset_0,soft_reset_1,soft_reset_2,write_enb,vld_out_0,vld_out_1,vld_out_2);

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
        $finish;
    end

    task OP_1;
    integer i;
    begin
        @(negedge clk);
        write_enb_reg = 1'b1;
        data_in = 2'b00;
        detect_add = 1'b1;
        @(negedge clk);
        detect_add = 1'b0;
        empty_0 = 0;
        empty_1 = 1;
        empty_2 = 1;
        for (i=0;i<32;i=i+1) begin
            delay;
        end
    end
    endtask

    task initialize;
    begin
        resetn = 1'b0;detect_add = 1'b0;full_0 = 1'b0;full_1 = 1'b0;full_2 = 1'b0;empty_0 = 1'b0;empty_1 = 1'b0;empty_2 = 1'b0;
        write_enb_reg = 1'b0;read_enb_0 = 1'b0;read_enb_1 = 1'b0;read_enb_2 = 1'b0;
    end
    endtask

    task delay;
    begin
        #(2*T);
    end
    endtask

    task reset;
    begin
        @(negedge clk) resetn = 1;
        @(negedge clk) resetn = 0;
    end
    endtask


endmodule