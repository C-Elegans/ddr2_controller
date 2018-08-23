#Stupid Simple DDR2 controller
This will allow you to use your DDR2 Ram Module with fairly poor performance(70.9MB/s read and 66.5MB/s write). But at least you get a working controller.In some sense, the problem is not the lack of DDR2 controllers - but their poor portability. 
The sheer complexitity of available controllers such as Xinlinx's MIG, and burdensome documenatation - not to mention a lack of a working test bench makes development with that tool difficult. 
## Portability
Xilinx's controller uses some Xilinx primitives. Since this controller originally targeted a Xilinx board, this repo uses the following three Xilinx primitives contained in ./rtl/IP:
To be honest, none of these IP sources seem to use any Xilinx specific code, so I imagine they might synthesize on non-Xilinx boards. If not, just replace them.
* IDDR.v (for implementing a Dual Data Rate muxer that can deliver data on both edges of a clock)
* ODDR.v (for implementing a Dual Data Rate demuxer that can deliver data on both edges of a clock )
* IOBUF.v (Xilinx IP implementation of a tristate that should work on Xilinx boards)
## What Works
* Initialization
* Read
* Write
##Organization
* ./doc contains documenatation
* ./rtl contains the rtl sources
* ./simulate contains the makefile and the testbench
* ./synthesize contains the synthesizeable testbench
## Simulation
cd simulate
make
gtkwave dump.vcd
## Usage 
The user visible interface is as follows:
```
    input   [25:0]  c_addr;     // the address to access
    input   [63:0]  c_data_in;  // data input, the ram is 16 bits and each access is a 4 word burst
    output  [63:0]  c_data_out; // data output from ram
    
    input           c_rd_req;   // raise when requesting a read
    input           c_wr_req;   // raise when requesting a write
    
    output          c_rdy;      // ready to service another request
    output          c_ack;      // the pending request has been serviced, and in the case of reads,
                                // the data is available on c_data_out
                    
    input           clk;        // 133+MHz clock input
    input           clk_90;     // 90 degree phase shifted clock input. 
                                // This clock must LAG 'clk' by 90 degrees
    input           rst;        // reset signal
        
```

To perform a read, first wait until `c_rdy` is high, then place an
address on `c_addr` and raise `c_rd_req`. When `c_ack` is high,
deassert `c_rd_req` and the data on `c_data_out` is valid and is the
result of the read.

To perfom a write, first wait until `c_rdy` is high, then place an
address on `c_addr` and some data on `c_data_in` and raise
`c_wr_req`. When `c_ack` is asserted the write has been serviced and
`c_wr_req` can be deasserted.

## Internals
![State machine diagram](./doc/statemachine.png)
