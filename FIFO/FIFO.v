// FIFO Design for Router 1x3 
// lft state -> Shows the diff between header and the packet
// Made by: G.Shivanesh

module FIFO (
    input resetn,clk,write_enb,soft_reset,read_enb,lfd_state,input [7:0]data_in,output empty,full, output reg [7:0]data_out
);

reg [8:0]mem[0:15];
integer i=0;
reg [3:0]w_point,r_point;   // Points the read ad write address
reg [5:0]counter=0; // read counter 
always @(posedge clk) begin
    if(~resetn || soft_reset) begin // Reset code 
        for (i = 0;i<16;i=i+1 ) begin
            mem[i] <= 9'b0;
        end
        w_point <= 4'b0;       // Read and write pointer to Zero 
        r_point <= 4'b0;
        counter <= 0;
        data_out <= 8'b0;
    end
    else begin
        if(write_enb && ~full) begin    // if write enable and if not full are high then we:
            mem[w_point] <= {lfd_state,data_in};    // Write at the particular address 
            w_point <= w_point + 1'b1;  // Write pointer is increased
        end
        if(read_enb && ~empty)
        begin
            if(mem[r_point][8] == 1'b1)
            begin 
                counter <= mem[r_point][7:2] + 6'b1;
                r_point <= r_point + 1;
                data_out <= mem[r_point][7:0];
            end
        else if(counter != 0)
        begin
           data_out <= mem[r_point][7:0];
           r_point <= r_point + 4'b1;
           counter <= counter - 1; // Counter should decrement till it reaches 0
        end
        end

    end

end

assign empty = (w_point == 4'b0)?1'b1:1'b0;
assign full = (w_point == 4'b1111)?1'b1:1'b0;



endmodule