module spi_core(input clk, input rst, input cs, input rd, input wr, input [DWIDTH-1:0] din,
    output [DWIDTH-1:0] dout, input miso, output mosi, output sclk, output done);
    
    parameter DWIDTH = 8;
    reg [DWIDTH-1:0] dout;
    reg done;
    
    reg [DWIDTH-1:0] tmp_dat;
    reg [2:0] sclk_div;
    reg xfer_in_progress;
    reg prev_xfer_prog;
    reg prev_sclk;
    reg tmp_in;
    
    wire sclk_negedge, sclk_posedge;
    
    assign mosi = tmp_dat[DWIDTH - 1];
    assign sclk_negedge = (prev_sclk & ~sclk);
    assign sclk_posedge = (~prev_sclk & sclk);
    
    initial prev_xfer_prog = 0;
    
    // CPOL = 0, CPHA = 1
    always @(posedge clk) begin
        if(xfer_in_progress) begin
            if(sclk_div == 0) begin
                sclk <= ~sclk;
                sclk_div <= 4;
            end else begin
                sclk_div <= sclk_div - 1;
            end
        end

        sclk_div <= 4;
        sclk <= 0;
        prev_sclk <= sclk;
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
        
        if (sclk_posedge) begin
            tmp_in <= miso;
        end
        
        if (sclk_negedge) begin
            tmp_dat <= { tmp_dat[DWIDTH - 2:0], tmp_in };
        end
    end
    
    
    
    always @(posedge clk) begin
        prev_xfer_prog <= xfer_in_progress;
    end

endmodule
