module spi_tb(input clk, input rst, input cs, input rd, input wr,
  input [7:0] din, output [7:0] dout, output miso, output mosi,
  output sclk, output done, output [7:0] prev_input, output [7:0] prev_output);

  defparam dut.DWIDTH = 8;


  wire [7:0] din;
  wire [7:0] dout;
  wire miso;
  wire mosi;
  wire sclk;
  wire done;
  

  reg [7:0] prev_input;
  reg [7:0] prev_output;
  wire [7:0] shreg_data;
  
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
    .data(shreg_data),
  );
  
  always @(posedge clk) begin
    if (~rd & wr & cs) begin
        prev_input <= din;
        prev_output <= shreg_data;
    end
  end
  
  // Assume well-behaved upstream
  assume property (!((rd == 1) && (wr == 1)));
  assume property (!((cs == 1) && (wr == 1) && (done == 0)));
  
  initial assume (wr == 1);
  initial assume (cs == 1);
  initial assume (done == 0);
  
  always @* begin
    if (done) begin
      assert(prev_input == shreg_data);
      assert(prev_output == dout);
    end
  end

endmodule


module spi_shreg(input sclk, input cs, input mosi, output reg miso,
  output [DWIDTH - 1:0] data);
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
