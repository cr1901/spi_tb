module spi_tb(input clk, input rst);
  defparam dut.DWIDTH = 8;

  wire cs = 0;
  wire rd = 0;
  wire wr = 0;
  wire [7:0] din;
  wire [7:0] dout;
  wire miso;
  wire mosi;
  wire sclk;
  wire done;
  

  reg [7:0] prev_input;

  spi_core dut (
    .clk(clk),
    .rst(rst),
    .cs(cs),
    .rd(rd),
    .wr(wr),
    .din(din),
    .dout(dout),
    .miso(miso),
    .mosi(mosi),
    .sclk(sclk),
    .done(done)
  );
  
  spi_shreg #(8) spi_sec(
    .sclk(sclk),
    .cs(1'b0),
    .mosi(mosi),
    .miso(miso),
  );
  
  always @* begin
    if (~rd & wr & cs) begin
        prev_input <= din;
        prev_output <= spi_shreg.data;
    end
  end
  
  assume property (!((rd == 1) && (wr == 1)));
  
  always @* begin
    if (done) begin
      assert(prev_input == spi_shreg.data);
    end
  end

endmodule


module spi_shreg(input sclk, input cs, input mosi, output reg miso);
    parameter DWIDTH = 8;

    reg tmp_bit;
    reg [DWIDTH - 1:0] data;
    
    always @(posedge sclk) begin
        if (~cs) begin
            tmp_bit <= mosi;
        end
    end
    
    always @(negedge sclk) begin
        if (~cs) begin
            miso <= data[DWIDTH - 1];
            data <= { data[6:0], tmp_bit };
        end
    end
endmodule
