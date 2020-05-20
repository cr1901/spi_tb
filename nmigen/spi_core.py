from nmigen import *
from nmigen.utils import log2_int
from nmigen.hdl.ast import Assume
from nmigen.cli import main

class SPICore(Elaboratable):
    def __init__(self, width):
        self.width = width

        self.cs = Signal()
        self.rd = Signal()
        self.wr = Signal()
        self.din = Signal(self.width)
        self.dout = Signal(self.width)
        self.miso = Signal()
        self.mosi = Signal()
        self.sclk = Signal(reset=0)
        self.done = Signal()

    def elaborate(self, platform):
        m = Module()

        tmp_dat = Signal(self.width)
        edge_cnt = Signal(log2_int(self.width) + 1)
        sclk_div = Signal(3)
        xfer_in_progress = Signal(reset=0)
        prev_xfer_prog = Signal(reset=0)
        prev_sclk = Signal(reset=0)
        tmp_in = Signal()

        sclk_negedge = Signal()
        sclk_posedge = Signal()

        m.d.comb += [
            self.mosi.eq(tmp_dat[-1]),
            sclk_negedge.eq(prev_sclk & ~self.sclk),
            sclk_posedge.eq(~prev_sclk & self.sclk)
        ]

        # with m.If(prev_xfer_prog == 0 & xfer_in_progress == 0):
        with m.If((prev_xfer_prog == 0) & (xfer_in_progress == 0)):
            m.d.comb += self.done.eq(1)
        with m.Else():
            m.d.comb += self.done.eq(0)

        # SCLK control
        # CPOL = 0, CPHA = 0
        m.d.sync += prev_sclk.eq(self.sclk)

        with m.If(xfer_in_progress):
            with m.If(sclk_div == 0):
                m.d.sync += [
                    self.sclk.eq(~self.sclk),
                    sclk_div.eq(4),
                    edge_cnt.eq(edge_cnt - 1)
                ]
            with m.Else():
                m.d.sync += sclk_div.eq(sclk_div - 1)
        with m.Else():
            m.d.sync += [
                sclk_div.eq(4),
                self.sclk.eq(0),
                edge_cnt.eq(2*self.width)
            ]

        # XFER control
        m.d.sync += prev_xfer_prog.eq(xfer_in_progress)

        with m.If(edge_cnt == 0):
            m.d.sync += xfer_in_progress.eq(0)

        with m.If(sclk_negedge):
             m.d.sync += tmp_dat.eq(Cat(tmp_in, tmp_dat[0:-1]));

        with m.If(self.wr & ~self.rd & self.cs & ~xfer_in_progress):
            m.d.sync += [
                tmp_dat.eq(self.din),
                xfer_in_progress.eq(1)
            ]

        with m.If(prev_xfer_prog & ~xfer_in_progress):
            m.d.sync += self.dout.eq(tmp_dat)

        with m.If(sclk_posedge):
            m.d.sync += tmp_in.eq(self.miso)

        # Formal
        m.d.comb += Assume(edge_cnt <= 16)

        return m


if __name__ == "__main__":
    core = SPICore(width=8)
    main(core, ports=[
            core.cs,
            core.rd,
            core.wr,
            core.din,
            core.dout,
            core.miso,
            core.mosi,
            core.sclk,
            core.done
        ])
