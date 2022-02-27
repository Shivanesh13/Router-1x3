// FIFO Design for Router 1x3 
// lft state -> Shows the diff between header and the packet

module FIFO (
    input resetn,clk,write_enb,soft_reset,read_enb,lfd_state,input [7:0]data_in,output empty,full, output reg [7:0]data_out
);

reg [8:0]mem[0:15];
integer i;
reg [3:0]w_point,r_point;   // Points the read ad write address
integer counter; // read counter 
always @(posedge clk) begin
    if(~resetn || soft_reset) begin // Reset code 
        for (i = 0;i<16;i++ ) begin
            mem[i] <= 9'b0;
        end
        w_point <= 4'b0;       // Read and write pointer to Zero 
        r_point <= 4'b0;
    end
    else begin
        if(write_enb && ~full) begin    // if write enable and if not full are high then we:
            mem[w_point] <= {lfd_state,data_in};    // Write at the particular address 
            w_point <= w_point + 1'b1;  // Write pointer is increased
            if(mem[w_point] == 1'b1) counter <= mem[w_point][7:2] + 6'b1;
        end
        else if(read_enb && ~empty && (counter != 6'b0))
        begin
           data_out <= mem[r_point];
           r_point <= r_point + 4'b1;
           counter <= counter - 1; // Counter should decrement till it reaches 0
        end
        else if(counter == 6'b0) begin
            counter <= 6'b0;
            r_point <= 4'b0;
            w_poiter <= 4'b0;   
        end
    end

end

assign empty = (r_point == 4'b0)?1'b1:1'b0;
assign full = (w_point == 4'b1111)?1'b1:1'b0;



endmodule