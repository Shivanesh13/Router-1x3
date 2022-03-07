
`include "Parameters_def.v"

module router_fsm (
    input clk,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,
    input low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,
    input [1:0]data_in,
    output detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state,busy
);
    reg [2:0]State,Next_State;
    always @(posedge clk, negedge resetn) begin
        if(~resetn) begin
            State <= `DECODE_ADDRESS;
        end
        else begin
            State <= Next_State;
        end
    end 

    always @(*) begin
        case(State)
        `DECODE_ADDRESS: begin
            if((pkt_valid && (data_in[1:0] == 2'b00) && fifo_empty_0) || 
                (pkt_valid && (data_in[1:0] == 2'b01) && fifo_empty_1)||
                (pkt_valid && (data_in[1:0] == 2'b10) && fifo_empty_2))
                begin
                    Next_State <= `LOAD_FIRST_DATA;
            end
            else if((pkt_valid && (data_in[1:0] == 2'b00) && ~fifo_empty_0) || 
                (pkt_valid && (data_in[1:0] == 2'b01) && ~fifo_empty_1)||
                (pkt_valid && (data_in[1:0] == 2'b10) && ~fifo_empty_2))
                begin
                    Next_State <= `WAIT_TILL_EMPTY;
            end
            else Next_State <= `DECODE_ADDRESS;
        end
        `LOAD_FIRST_DATA: begin
            Next_State <= `LOAD_DATA;
        end
        `WAIT_TILL_EMPTY: begin
            if((fifo_empty_0)||(fifo_empty_1)||(fifo_empty_2)) 
            begin
                Next_State <= `LOAD_FIRST_DATA;
            end
            if((~fifo_empty_0)||(~fifo_empty_1)||(~fifo_empty_2)) begin
                Next_State <= `WAIT_TILL_EMPTY;
            end
        end
        `LOAD_DATA: begin
            if((~fifo_full) && (~pkt_valid)) begin
                Next_State <= `LOAD_PARITY;
            end
            if(fifo_full) begin
                Next_State <= `FIFO_FULL_STATE;
            end
        end
        `LOAD_PARITY: begin
            Next_State <= `CHECK_PARITY_ERROR;
        end
        `FIFO_FULL_STATE: begin
            if(fifo_full) begin
                Next_State <= `FIFO_FULL_STATE;
            end    
            else if (~fifo_full) begin
                Next_State <= `LOAD_AFTER_FULL;
            end
        end 
        `LOAD_AFTER_FULL: begin
            if((~parity_done) && (!low_pkt_valid))begin
                Next_State <= `LOAD_DATA;
            end
            if ((~parity_done) && (low_pkt_valid)) begin
                Next_State <= `LOAD_PARITY;
            end
            if(parity_done) Next_State <=`DECODE_ADDRESS;
        end
        `CHECK_PARITY_ERROR: begin
            if(~fifo_full) Next_State <= `DECODE_ADDRESS;
            if(fifo_full) Next_State <= `FIFO_FULL_STATE;
        end
        default: Next_State <= `DECODE_ADDRESS;
        endcase
    end


    assign detect_add = (State == `DECODE_ADDRESS)?1'b1:1'b0;
    assign lfd_state = (State == `LOAD_FIRST_DATA)?1'b1:1'b0;
    assign busy = ((State == `CHECK_PARITY_ERROR) || (State == `WAIT_TILL_EMPTY) || (State == `LOAD_AFTER_FULL) || (State == `FIFO_FULL_STATE) || (State == `LOAD_FIRST_DATA) || (State != `LOAD_DATA) || (State == `LOAD_PARITY))?1'b1:1'b0;
    assign ld_state = (State == `LOAD_DATA)?1'b1:1'b0;
    assign write_enb_reg = ((State != `WAIT_TILL_EMPTY) || (State == `LOAD_AFTER_FULL) || (State == `LOAD_DATA) || (State == `LOAD_PARITY) || (State == `FIFO_FULL_STATE))?1'b1:1'b0;
    assign full_state = (State == `FIFO_FULL_STATE)?1'b1:1'b0;
    assign laf_state = (State == `LOAD_AFTER_FULL)?1'b1:1'b0;
    assign rst_int_reg = (State == `CHECK_PARITY_ERROR)?1'b1:1'b0;

endmodule