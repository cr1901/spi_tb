module spi_tb(input clk, input rst);
  defparam dut.DWIDTH = 8;

  wire cs;
  wire rd;
  wire wr;
  wire [7:0] din;
  wire [7:0] dout;
  wire miso;
  wire mosi;
  wire sclk;

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
    .sclk(sclk)
  );
  
  assume property (!(rd == 1) && (wr == 1));

endmodule
