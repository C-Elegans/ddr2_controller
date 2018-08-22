`define CAS_LATENCY 5
`define period 7520
module controller (/*AUTOARG*/
   // Outputs
   c_data_out, c_rdy, ck, ck_n, cke, cs_n, ras_n, cas_n, we_n, ba,
   addr, odt,
   // Inouts
   dm_rdqs, dq, dqs, dqs_n,
   // Inputs
   clk, rst, c_addr, c_data_in, c_rd_req, c_wr_req, rdqs_n
   );

`include "ddr2_parameters.vh"
   input clk;
   input rst;
   
   input [25:0] c_addr;
   input [63:0] c_data_in;
   output [63:0] c_data_out;
   output 	 c_rdy;
   input 	 c_rd_req;
   input 	 c_wr_req;
   
   

   // DRAM Signals
   output   ck;
   output   ck_n;
   output reg [CS_BITS-1:0] cke;
   output reg [CS_BITS-1:0] cs_n;
   output reg 		ras_n;
   output reg 		cas_n;
   output reg 		we_n;
   inout [DM_BITS-1:0] 	dm_rdqs;
   output reg [BA_BITS-1:0] ba;
   output reg [ADDR_BITS-1:0] addr;
   inout [DQ_BITS-1:0] 	  dq;
   inout [DQS_BITS-1:0]   dqs;
   inout [DQS_BITS-1:0]   dqs_n;
   input [DQS_BITS-1:0]   rdqs_n;
   output reg [CS_BITS-1:0]   odt;

   // ras, cas, we
   localparam // auto enum cmd
     cmd_load = 3'b000,
     cmd_pre = 3'b010,
     cmd_act = 3'b011,
     cmd_wr  = 3'b100,
     cmd_rd  = 3'b101,
     cmd_nop = 3'b111,
     cmd_ref = 3'b001;
   
 

   localparam [8:0] //auto enum state
     S_INIT_0 = {6'b000000, cmd_nop},
     S_INIT_1 = {6'b000001, cmd_nop},
     S_INIT_2 = {6'b000010, cmd_nop},
     S_INIT_3 = {6'b000011, cmd_pre},
     S_INIT_4 = {6'b000100, cmd_load},
     S_INIT_5 = {6'b000101, cmd_load},
     S_INIT_6 = {6'b000110, cmd_load},
     S_INIT_7 = {6'b000111, cmd_load},
     S_INIT_8 = {6'b001000, cmd_pre},
     S_INIT_9 = {6'b001001, cmd_ref},
     S_INIT_10 = {6'b001010, cmd_ref},
     S_INIT_11 = {6'b001011, cmd_load},
     S_INIT_12 = {6'b001100, cmd_load},
     S_INIT_13 = {6'b001101, cmd_load},
     S_INIT_14 = {6'b001110, cmd_nop},
     S_RF0 = {6'b100000, cmd_ref},
     S_RF1 = {6'b100001, cmd_nop},
     S_IDLE   = {6'b001111, cmd_nop};
   
   
   
   


   reg [8:0] 
	     state = S_INIT_0;

   wire [8:3] //auto enum state
	      state_state = state[8:3];
   wire [2:0] //auto enum cmd
	      state_cmd = state[2:0];
   
   reg [15:0] counter = 0;
   
   
   assign ck = ~clk;
   assign ck_n = clk;
   
   
   always @(/*AS*/state) begin
      we_n <= state[0];
      cas_n <= state[1];
      ras_n <= state[2];
   end
   

   always @(posedge clk) begin

      if(rst) begin
	 cke <= 0;
	 state <= S_INIT_0;
	 counter <= 0;
      end
      else begin
	 if(counter != 0)
	   counter <= counter - 1;
	 state[2:0] <= cmd_nop;
	 case (state[8:3])
	   S_INIT_0[8:3]: begin
	      counter <= (200*`US)/TCK_MIN; // 200 uS
	      state <= S_INIT_1;
	      cke <= 0;
	      
	   end
	   S_INIT_1[8:3]: 
	      if(counter == 0) begin
		 cke <= 1;
		 counter <= (400*`NS)/TCK_MIN;
		 state <= S_INIT_2;
	      end
	   S_INIT_2[8:3]:
	     if(counter == 0) begin
		state <= S_INIT_3;
		counter <= TRPA/TCK_MIN;
	     end
	   S_INIT_3[8:3]:
	      if(counter == 0) begin
		 state <= S_INIT_4;
		 ba <= 3'b010;
		 addr <= 12'b0;
		 addr[7] <= 1'b1;
		 counter <= TMRD;
	      end
	   S_INIT_4[8:3]:
	     if(counter == 0) begin
		ba <= 3'b011;
		addr <= 12'b0;
		counter <= TMRD;
		state <= S_INIT_5;
	     end
	   S_INIT_5[8:3]:
	     if(counter == 0) begin
		ba <= 3'b001;
		addr <= 12'b0;
		counter <= TMRD;
		state <= S_INIT_6;
	     end
	   S_INIT_6[8:3]:
	     if(counter == 0) begin
		ba <= 3'b0;
		addr <= 12'b0;
		addr[8] <= 1'b1;
		counter <= TMRD;
		state <= S_INIT_7;
	     end
	   S_INIT_7[8:3]:
	     if(counter == 0) begin
		addr[10] <= 1;
		counter <= TMRD;
		state <= S_INIT_8;
	     end
	   S_INIT_8[8:3]:
	     if(counter == 0) begin
		counter <= TRPA/TCK_MIN;
		state <= S_INIT_9;
	     end
	   S_INIT_9[8:3]:
	     if(counter == 0) begin
		counter <= TRFC_MIN/TCK_MIN;
		state <= S_INIT_10;
	     end
	   S_INIT_10[8:3]:
	     if(counter == 0) begin
		counter <= TRFC_MIN/TCK_MIN;
		state <= S_INIT_11;
		ba <= 3'b000;
		addr <= 12'b0;
		addr[11:9] <= TWR/TCK_MIN;
		addr[6:4] <= `CAS_LATENCY;
		addr[2:0] <= 3'b010;
	     end
	   S_INIT_11[8:3]:
	     if(counter == 0) begin
		counter <= TMRD;
		state <= S_INIT_12;
		ba <= 3'b001;
		addr <= 12'b0;
		addr[9:7] <= 3'b111;
	     end
	   S_INIT_12[8:3]:
	     if(counter == 0) begin
		counter <= TMRD;
		state <= S_INIT_13;
		ba <= 3'b001;
		addr <= 12'b0;
		addr[9:7] <= 3'b000;
	     end
	   S_INIT_13[8:3]:
	     if(counter == 0) begin
		counter <= 200;
		state <= S_INIT_14;
	     end
	   S_INIT_14[8:3]:
	     if(counter == 0)
	       state <= S_IDLE;
	   

	   S_IDLE[8:3]: begin
	      if(counter == 0)
		state <= S_RF0;
	   
	   end

	   S_RF0[8:3]: begin
	      counter <= TRFC_MIN/`period;
	      state <= S_RF1;
	   end
	   S_RF1[8:3]: 
	      if(counter == 0) begin
		 counter <= TRFC_MAX/`period;
		 state <= S_IDLE;
	      end
	      
	 endcase // case (state[8:3])
	 
      end
   end
   
   /*AUTOASCIIENUM("state_cmd", "cmd_ascii")*/
   // Beginning of automatic ASCII enum decoding
   reg [63:0]		cmd_ascii;		// Decode of state_cmd
   always @(state_cmd) begin
      case ({state_cmd})
	cmd_load: cmd_ascii = "cmd_load";
	cmd_pre:  cmd_ascii = "cmd_pre ";
	cmd_act:  cmd_ascii = "cmd_act ";
	cmd_wr:   cmd_ascii = "cmd_wr  ";
	cmd_rd:   cmd_ascii = "cmd_rd  ";
	cmd_nop:  cmd_ascii = "cmd_nop ";
	cmd_ref:  cmd_ascii = "cmd_ref ";
	default:  cmd_ascii = "%Error  ";
      endcase
   end
   // End of automatics
   /*AUTOASCIIENUM("state_state", "state_ascii", "s_")*/
   // Beginning of automatic ASCII enum decoding
   reg [47:0]		state_ascii;		// Decode of state_state
   always @(state_state) begin
      case ({state_state})
	S_INIT_0: state_ascii = "init_0";
	S_INIT_1: state_ascii = "init_1";
	S_INIT_2: state_ascii = "init_2";
	S_INIT_3: state_ascii = "init_3";
	S_INIT_4: state_ascii = "init_4";
	default:  state_ascii = "%Error";
      endcase
   end
   // End of automatics

endmodule // controller


