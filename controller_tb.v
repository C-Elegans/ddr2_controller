`timescale 1ps/1ps
module controller_tb;
`include "ddr2_parameters.vh"
   `define period 7519
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [25:0]		c_addr;			// To controller of controller.v
   reg [63:0]		c_data_in;		// To controller of controller.v
   reg			c_rd_req;		// To controller of controller.v
   reg			c_wr_req;		// To controller of controller.v
   reg			clk;			// To controller of controller.v
   reg			clk_90;			// To controller of controller.v
   reg			rst;			// To controller of controller.v
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [ADDR_BITS-1:0]	addr;			// From controller of controller.v
   wire [BA_BITS-1:0]	ba;			// From controller of controller.v
   wire			c_ack;			// From controller of controller.v
   wire [63:0]		c_data_out;		// From controller of controller.v
   wire			c_rdy;			// From controller of controller.v
   wire			cas_n;			// From controller of controller.v
   wire			ck;			// From controller of controller.v
   wire			ck_n;			// From controller of controller.v
   wire [CS_BITS-1:0]	cke;			// From controller of controller.v
   wire [CS_BITS-1:0]	cs_n;			// From controller of controller.v
   wire [DM_BITS-1:0]	dm_rdqs;		// To/From ddr2 of ddr2.v, ...
   wire [DQ_BITS-1:0]	dq;			// To/From ddr2 of ddr2.v, ...
   wire [DQS_BITS-1:0]	dqs;			// To/From ddr2 of ddr2.v, ...
   wire [DQS_BITS-1:0]	dqs_n;			// To/From ddr2 of ddr2.v, ...
   wire [CS_BITS-1:0]	odt;			// From controller of controller.v
   wire			ras_n;			// From controller of controller.v
   wire [DQS_BITS-1:0]	rdqs_n;			// From ddr2 of ddr2.v
   wire			we_n;			// From controller of controller.v
   // End of automatics

   ddr2 ddr2(/*AUTOINST*/
	     // Outputs
	     .rdqs_n			(rdqs_n[DQS_BITS-1:0]),
	     // Inouts
	     .dm_rdqs			(dm_rdqs[DM_BITS-1:0]),
	     .dq			(dq[DQ_BITS-1:0]),
	     .dqs			(dqs[DQS_BITS-1:0]),
	     .dqs_n			(dqs_n[DQS_BITS-1:0]),
	     // Inputs
	     .ck			(ck),
	     .ck_n			(ck_n),
	     .cke			(cke),
	     .cs_n			(cs_n),
	     .ras_n			(ras_n),
	     .cas_n			(cas_n),
	     .we_n			(we_n),
	     .ba			(ba[BA_BITS-1:0]),
	     .addr			(addr[ADDR_BITS-1:0]),
	     .odt			(odt));
   

   controller controller(/*AUTOINST*/
			 // Outputs
			 .c_data_out		(c_data_out[63:0]),
			 .c_rdy			(c_rdy),
			 .c_ack			(c_ack),
			 .ck			(ck),
			 .ck_n			(ck_n),
			 .cke			(cke[CS_BITS-1:0]),
			 .cs_n			(cs_n[CS_BITS-1:0]),
			 .ras_n			(ras_n),
			 .cas_n			(cas_n),
			 .we_n			(we_n),
			 .ba			(ba[BA_BITS-1:0]),
			 .addr			(addr[ADDR_BITS-1:0]),
			 .odt			(odt[CS_BITS-1:0]),
			 // Inouts
			 .dm_rdqs		(dm_rdqs[DM_BITS-1:0]),
			 .dq			(dq[DQ_BITS-1:0]),
			 .dqs			(dqs[DQS_BITS-1:0]),
			 .dqs_n			(dqs_n[DQS_BITS-1:0]),
			 // Inputs
			 .clk			(clk),
			 .clk_90		(clk_90),
			 .rst			(rst),
			 .c_addr		(c_addr[25:0]),
			 .c_data_in		(c_data_in[63:0]),
			 .c_rd_req		(c_rd_req),
			 .c_wr_req		(c_wr_req),
			 .rdqs_n		(rdqs_n[DQS_BITS-1:0]));

   initial begin
      $dumpfile("dump.vcd");
      $dumpvars;

      clk <= 0;
      rst <= 1;
      #20 rst <= 0;
      

      #(8000 * `NS) $finish;
   end
   initial begin
      #(2000 * `NS)
      c_rd_req <= 1;
      c_addr <= 26'hdeadbeef;
      c_data_in <= 64'hf00dbeefdeadfeed;
      @(posedge c_ack)
	c_rd_req <= 0;
      @(posedge c_rdy)
	c_wr_req <= 1;
      c_addr <= 26'hdeadbeef;
      c_data_in <= 64'hf00dbeefdeadfeed;
      @(posedge c_ack)
	c_wr_req <= 0;
      @(posedge c_rdy)
	c_rd_req <= 1;
      @(posedge c_ack)
	c_rd_req <= 0;
      
		    
      
      
      
   end
   

   always #(`period/2) clk <= ~clk;

   always @(posedge clk or negedge clk)
     #(`period/4) clk_90 <= clk;
   
      
   
   
      

endmodule
