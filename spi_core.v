module spi_core(input clk, input rst, input cs, input rd, input wr, input [DWIDTH-1:0] din,
    output [DWIDTH-1:0] dout, input miso, output mosi, output sclk, output done);
    
    parameter DWIDTH = 8;
    reg [DWIDTH-1:0] din;
    reg [DWIDTH-1:0] dout;
    reg done;
    
    reg [DWIDTH-1:0] tmp_dat;
    reg xfer_in_progress;
    reg prev_xfer_prog;

    // CPOL = 0, CPHA = 1
    always @(posedge clk) begin
        if(xfer_in_progress) begin
            sclk <= ~sclk;
        end
        sclk <= 0;
    end
    
    always @(posedge clk) begin
        if(wr & ~rd & cs & ~xfer_in_progress) begin
            tmp_dat <= din;
            xfer_in_progress <= 1;
            done <= 0;
        end
        
        if (prev_xfer_prog & ~xfer_in_progress) begin
            done <= 1;
        end
    end
    
    always @(posedge clk) begin
        prev_xfer_prog <= xfer_in_progress;
    end
    
    
    
    
    //always @(posedge 
    
    
endmodule
