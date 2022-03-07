module router_register_tb (
);
    reg clk,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state;
    reg [7:0]data_in;
    wire parity_done,err;
    wire [7:0]dout;
    wire low_pkt_valid;
    parameter T = 5;
    router_register DUT(clk,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,data_in,parity_done,err,dout,low_pkt_valid);

    initial begin
        clk = 0;
        forever begin
            #(T) clk = ~clk;
        end
    end

    initial begin
        write;
        delay;
        delay;
        delay;
        $finish;
    end

    task write;
    begin
        reset;
        @(negedge clk);
        full_state = 1'b0;
        pkt_valid = 1'b1;
        fifo_full = 1'b0;
        ld_state = 1'b1;
        data_in = 8'b00001100;
        @(negedge clk) data_in = 8'b11111111;
        @(negedge clk) data_in = 8'b11111111;
        @(negedge clk) data_in = 8'b11111111;
        @(negedge clk)pkt_valid = 1'b0;
        data_in = 8'b11111011;
    end
    endtask

    task reset;
    begin
        @(negedge clk) resetn = 1'b0;
        @(negedge clk) resetn = 1'b1;
    end
    endtask

    task delay;
    begin
        #(2*T);
    end
    endtask

endmodule