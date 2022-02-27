// FIFO Design for Router 1x3 
module FIFO (
    input resetn,clk,write_enb,soft_reset,read_enb,lfd_state,input [7:0]data_in,output empty,full, output reg [7:0]data_out
);

reg [8:0]mem[0:15];
integer i;
reg [3:0]w_point,r_point;
reg temp_full,temp_empty;
integer counter;
always @(posedge clk) begin
    if(~resetn || soft_reset) begin
        for (i = 0;i<16;i++ ) begin
            mem[i] <= 9'b0;
        end
        w_point <= 4'b0;
        r_point <= 4'b0;
        full <= 1'b0;
        empty <= 1'b1;
    end
    else begin
        if(write_enb && ~full) begin
            mem[w_point] <= {lfd_state,data_in};
            w_point <= w_point + 1'b1;
            r_point <= w_point;
            if(mem[w_point] == 1'b1) counter <= mem[w_point][7:2] + 6'b1;
        end
        if(read_enb && ~empty && (counter != 6'b0))
        begin
           data_out <= mem[r_point];
           r_point <= r_point - 4'b1;
        end
    end

end

assign empty = (r_point == 4'b0)?1'b1:1'b0;
assign full = (w_point == 4'b1111)?1'b1:1'b0;



endmodule