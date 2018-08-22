module ddrbank(/*AUTOARG*/
   // Outputs
   o1, o0,
   // Inouts
   io,
   // Inputs
   clk, oe, d1, d0
   );

   parameter BANK_WIDTH = 16;
   
   input clk;
   input oe;
   
   input [BANK_WIDTH-1:0] d1;
   input [BANK_WIDTH-1:0] d0;
   inout [BANK_WIDTH-1:0] io;

   output [BANK_WIDTH-1:0] o1;
   output [BANK_WIDTH-1:0] o0;
   
   wire [BANK_WIDTH-1:0] oddr;
   wire [BANK_WIDTH-1:0] iddr;
   
   genvar 		  i;
   for(i=0; i<BANK_WIDTH; i=i+1) begin : genoddr
      
      ODDR oddr(
		// Outputs
		.Q				(oddr[i]),
		// Inputs
		.C				(clk),
		.CE			(1'b1),
		.D1			(d0[i]),
		.D2			(d1[i]),
		.R				(1'b0),
		.S				(1'b0));
      IOBUF iobuf(
		  .I (oddr[i]),
		  .O (iddr[i]),
		  .T(oe),
		  .IO(io[i]));
      
   end // block: genoddr
   
   

endmodule // ddrbank
