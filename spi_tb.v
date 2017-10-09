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
  
  reg reg_wr;
  reg reg_rd;
  reg reg_cs;


  reg [7:0] prev_input;
  reg [7:0] prev_output;
  wire [7:0] shreg_data;
  
  spi_core dut (
    .clk(clk),
    .rst(rst),
    .cs(reg_cs),
    .rd(reg_rd),
    .wr(reg_wr),
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
    .data(shreg_data)
  );
  
  // When an xfer starts, save the previous input/output for
  // comparison purposes.
  always @(posedge clk) begin
    if (~reg_rd & reg_wr & reg_cs) begin
        prev_input <= din;
        prev_output <= shreg_data;
    end

    reg_rd <= rd;
    reg_wr <= wr;
    reg_cs <= cs;
  end
  

`ifdef FORMAL
    // Assume well-behaved upstream- whatever's connected to the SPI
    // core has properly-functioning control signals.
    assume property (!((rd == 1) && (wr == 1)));
    assume property (!((cs == 1) && (wr == 1) && (done == 0)));

    initial assume (wr == 1);
    initial assume (cs == 1);
    initial assume (done == 1);
    initial assume (prev_input == shreg_data);
    initial assume (prev_output == dout);

    // Goal: If no xfer is taking place, the SPI primary's reg
    // should equal the secondary's reg _just_ before the xfer started.
    // The secondary's reg should equal the input data bus _just_
    // before the xfer started.
    always @* begin
      if (done) begin
        assert(prev_input == shreg_data);
        assert(prev_output == dout);
        assume(sclk == 0);
      end
    end

    reg last_clk = 0;

    always @($global_clock) begin
        last_clk <= clk;
        assume(last_clk != clk);
    end
`endif

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
            data[DWIDTH - 1:0] <= { data[DWIDTH - 2:0], tmp_bit };
        end
    end
endmodule
