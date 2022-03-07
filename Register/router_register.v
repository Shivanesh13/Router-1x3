module router_register (
    input clk,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,input [7:0]data_in,output reg parity_done,err,output reg [7:0]dout,output low_pkt_valid
);

    reg [7:0]hold_header,fifo_full_state,internal_parity,packet_parity;
    assign low_pkt_valid = (~pkt_valid && ld_state);
    
    always @(posedge clk) begin
        if(~resetn) begin
            dout <= 8'b0;
            err <= 1'b0;
            parity_done <= 1'b0;
            internal_parity <= 8'b0;
            packet_parity <= 8'b0;
            hold_header <= 8'b0;
            fifo_full_state <= 8'b0;
            internal_parity <= 8'b0;
            packet_parity <= 8'b0; 
        end
        else begin
            if(pkt_valid) begin
                if(fifo_full && ld_state) begin
                    fifo_full_state <= data_in;
                end
                if(detect_add) begin
                    hold_header <= data_in;
                    parity_done <= 1'b0;
                end
                if(ld_state && ~fifo_full) begin
                    dout <= data_in;
                end
                if(~full_state && ~fifo_full) begin
                    internal_parity <= internal_parity ^ data_in;
                end
            end
            
            if(~pkt_valid && ~fifo_full && ld_state) 
            begin
                parity_done <= 1'b1;
                packet_parity <= data_in;
            end

            if(parity_done == 1'b1) begin
                if((packet_parity == internal_parity)) err <= 1'b0;
                else err <= 1'b1;
            end
            
            if(lfd_state) 
            begin
                dout <= hold_header;
            end
            
            if(laf_state) 
            begin
                dout <= fifo_full_state;
            end

            if(rst_int_reg) 
            begin
                internal_parity <= 8'b0;
                packet_parity <= 8'b0;
            end
        end

    end
endmodule