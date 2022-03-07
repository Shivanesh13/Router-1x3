// Testbench for FIFO module 
// Made by: G.Shivanesh
// Date: 27/2/22

module FIFO_tb (
);
    // Ports are declared as in Main module 
    reg resetn,clk,write_enb,soft_reset,read_enb,lfd_state;
    reg [7:0]data_in;
    wire empty,full;
    wire [7:0]data_out;
    parameter T = 5; // Used to generate clock signal
    parameter D = 2*T; // Used to generate delay
    integer i=0; //for loop purposes
    reg [5:0]num; // Determines the depth of packet
    reg [1:0]add; // Address
    

    FIFO DUT(resetn,clk,write_enb,soft_reset,read_enb,lfd_state,data_in,empty,full,data_out);

    // Generates Clock Signals 
    initial begin
        clk = 0;
        forever begin
            #(T) clk = ~clk;
        end
    end
    initial begin
        initialize; // Initializes the values
        reset;      // Resets the value
        delay;      // Delays the simulation
        soft_reset_enable;
        delay;
        write;      // Starts the write process
        for ( i=0;i<num+1;i=i+1 ) begin
            lfd_state = 1'b0;   // For packets = 0
            data_in = {$random}%256;
            delay;
        end
        delay;
        stop_write;
        delay;
        read;
        for (i = 0;i<num+5;i=i+1 ) begin
            delay;
        end
        delay;
        for (i = 0;i<num+5;i=i+1 ) begin
            $display("Mem = %b",DUT.mem[i]);
        end
        $finish;
    end


    // task to write the data
    task write;
    begin
        @(negedge clk) write_enb = 1;
        lfd_state = 1'b1; // For header MSB = 1
        num = {$random()}%15;  // Generates Random no for total packet size
        add = {$random()}%3;
        data_in = {num,add}; // Last 2 for add next 6 for the packet size 6
        delay;

    end
    endtask

    // Stop write
    task stop_write;
    begin
        @(negedge clk) write_enb = 1'b0;
    end
    endtask

    task read;
    begin
        @(negedge clk) read_enb = 1'b1;
    end
    endtask

    // task reset
    task reset;
    begin
        @(negedge clk) resetn = 1'b0;
        @(negedge clk) resetn = 1'b1;
    end
    endtask

    task soft_reset_enable;
    begin
        @(negedge clk) soft_reset = 1'b1;
        @(negedge clk) soft_reset = 1'b0;
    end
    endtask

    // task used to initialize the inputs
    task initialize; 
    begin
        resetn = 1;
        write_enb = 0;
        soft_reset = 0;
        read_enb = 0;
        lfd_state = 0;
        data_in = 8'b0;
    end
    endtask

    // Delay
    task delay;
    begin
        #(D);
    end
    endtask
endmodule