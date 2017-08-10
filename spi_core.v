module spi_core(input clk, input rst, input cs, input rd, input wr, input [DWIDTH-1:0] din,
    output [DWIDTH-1:0] dout, input miso, output mosi, output sclk);
    
    parameter DWIDTH = 8;
    reg [DWIDTH-1:0] din;
    reg [DWIDTH-1:0] dout;
    
    reg [DWIDTH-1:0] tmp_dat;
    reg xfer_in_progress;

    // CPOL = 0, CPHA = 1
    always @(posedge clk) begin
        if(xfer_in_progress) begin
            sclk <= ~sclk;
        end
        sclk <= 0;
    end
    
    always @(posedge clk) begin
        if(wr & ~rd & cs) begin
            tmp_dat <= din;
            xfer_in_progress <= 1;
        end
    end
    
    
endmodule
