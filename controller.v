`define CAS_LATENCY 5
`define period 7520
module controller (/*AUTOARG*/
   // Outputs
   c_data_out, c_rdy, c_ack, ck, ck_n, cke, cs_n, ras_n, cas_n, we_n,
   ba, addr, odt,
   // Inouts
   dm_rdqs, dq, dqs, dqs_n,
   // Inputs
   clk, clk_90, rst, c_addr, c_data_in, c_rd_req, c_wr_req, rdqs_n
   );

`include "ddr2_parameters.vh"
   input clk;
   input clk_90;
   
   input rst;
   
   input [25:0] c_addr;
   input [63:0] c_data_in;
   output [63:0] c_data_out;
   output 	 c_rdy;
   output reg	 c_ack;
   input 	 c_rd_req;
   input 	 c_wr_req;
   
   

   // DRAM Signals
   output   ck;
   output   ck_n;
   output reg [CS_BITS-1:0] cke;
   output [CS_BITS-1:0] cs_n;
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
     S_INIT_0	= {6'b000000, cmd_nop},
     S_INIT_1	= {6'b000001, cmd_nop},
     S_INIT_2	= {6'b000010, cmd_nop},
     S_INIT_3	= {6'b000011, cmd_pre},
     S_INIT_4	= {6'b000100, cmd_load},
     S_INIT_5	= {6'b000101, cmd_load},
     S_INIT_6	= {6'b000110, cmd_load},
     S_INIT_7	= {6'b000111, cmd_load},
     S_INIT_8	= {6'b001000, cmd_pre},
     S_INIT_9	= {6'b001001, cmd_ref},
     S_INIT_10	= {6'b001010, cmd_ref},
     S_INIT_11	= {6'b001011, cmd_load},
     S_INIT_12	= {6'b001100, cmd_load},
     S_INIT_13	= {6'b001101, cmd_load},
     S_INIT_14	= {6'b001110, cmd_nop},
     S_RF0	= {6'b100000, cmd_ref},
     S_RF1	= {6'b100001, cmd_nop},
     S_ACT0	= {6'b100010, cmd_act},
     S_ACT1	= {6'b100011, cmd_nop},
     S_ACT2	= {6'b100100, cmd_nop},

     S_PRE0	= {6'b100101, cmd_pre},
     S_PRE1	= {6'b100110, cmd_nop},
     S_PRE2	= {6'b100111, cmd_nop},
     S_PRE3	= {6'b101000, cmd_nop},

     S_RD0	= {6'b110100, cmd_rd},
     S_RD1	= {6'b110101, cmd_nop},
     S_RD2	= {6'b110110, cmd_nop},
     S_RD3	= {6'b110111, cmd_nop},
     S_RD4	= {6'b111000, cmd_nop},
     S_RD5	= {6'b111001, cmd_nop},
     S_RD6	= {6'b111010, cmd_nop},
     S_RD7	= {6'b111011, cmd_nop},

     S_WR0      = {6'b010000, cmd_wr},
     S_WR1      = {6'b010001, cmd_nop},
     S_WR2      = {6'b010010, cmd_nop},
     S_WR3      = {6'b010011, cmd_nop},
     S_WR4      = {6'b010100, cmd_nop},
     S_WR5      = {6'b010101, cmd_nop},
     S_WR6      = {6'b010110, cmd_nop},
   
     S_IDLE	= {6'b001111, cmd_nop};
   
   
   
   


   reg [8:0] //auto enum state 
	     state = S_INIT_0;

   wire [8:3] //auto enum state
	      state_state = state[8:3];
   wire [2:0] //auto enum cmd
	      state_cmd = state[2:0];
   
   reg [15:0] counter = 0;
   reg [25:0] cur_addr = 0;
   
   
   
   assign ck = ~clk;
   assign ck_n = clk;
   assign cs_n = 0;
   
   assign c_rdy = state[8:3] == S_IDLE[8:3];
   assign dm_rdqs = 2'b00;


   reg 	      dqs_pre = 0;
   reg 	      dqs_en = 0;

   assign dqs = dqs_en ? (dqs_pre ? 0 : {ck,ck}) : 'bZ;
   assign dqs_n = dqs_en ? ~dqs : 'bZ;
   
   
   
   reg [15:0] dq_out0 = 0;
   reg [15:0] dq_out1 = 0;

   reg 	      dq_oe = 0;
   reg 	      dq_oe90 = 0;

   always @(posedge clk_90)
     dq_oe90 <= dq_oe;
   

   ddrbank dqbank (
		   .d1(dq_out1),
		   .d0(dq_out0),
		   .io(dq),
		   .clk(clk_90),
		   .oe(dq_oe90));
   
   
   
   
   
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
	 c_ack <= 0;
	 dqs_en <= 0;
	 dqs_pre <= 0;
	 dq_oe <= 0;
	 
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
		addr <= 0;
		addr[10] <= 1'b1;
		
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
		addr[11:9] <= TWR/TCK_MIN;
		addr[6:4] <= `CAS_LATENCY;
		addr[2:0] <= 3'b010;
		counter <= TMRD;
		state <= S_INIT_7;
	     end
	   S_INIT_7[8:3]:
	     if(counter == 0) begin
		addr[10] <= 1;
		counter <= TRPA/TCK_MIN + 1;
		state <= S_INIT_8;
	     end
	   S_INIT_8[8:3]:
	     if(counter == 0) begin
		counter <= TRFC_MIN/TCK_MIN;
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
	     if(counter == 0) begin
		state <= S_IDLE;
		counter <= TRFC_MAX/`period;
	     end
	   
	   

	   S_IDLE[8:3]: begin
	      if(counter == 0)
		state <= S_RF0;
	      if(c_rd_req || c_wr_req) begin
		 state <= S_ACT0;
		 addr <= c_addr[25:13];
		 ba <= c_addr[12:10];
		 cur_addr <= c_addr;
		 
	      end
	      
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
	   S_ACT0[8:3]:
	     state <= S_ACT1;
	   S_ACT1[8:3]:
	     state <= S_ACT2;
	   S_ACT2[8:3]:
	      if(c_rd_req) begin
		 state <= S_RD0;
		 addr <= cur_addr[9:0];
	      end
	      else if(c_wr_req) begin
		 state <= S_WR0;
		 addr <= cur_addr[9:0];
	      end
	   
	      else
		state <= S_PRE0;
	   S_RD0[8:3]:
	     state <= S_RD1;
	   S_RD1[8:3]:
	     state <= S_RD2;
	   S_RD2[8:3]:
	     state <= S_RD3;
	   S_RD3[8:3]:
	     state <= S_RD4;
	   S_RD4[8:3]:
	     state <= S_RD5;
	   S_RD5[8:3]:
	     state <= S_RD6;
	   S_RD6[8:3]:
	     state <= S_RD7;
	   S_RD7[8:3]: begin
	     state <= S_PRE0;
	      c_ack <= 1;
	      
	   end
	   
	   S_PRE0[8:3]:
	     state <= S_PRE1;
	   S_PRE1[8:3]:
	     state <= S_PRE2;
	   S_PRE2[8:3]:
	     state <= S_PRE3;
	   S_PRE3[8:3]:
	     state <= S_IDLE;
	   
	   S_WR0[8:3]: begin
	      state <= S_WR1;
	      c_ack <= 1;
	      
	   end
	   
	   S_WR1[8:3]:begin
	      state <= S_WR2;
	      
	   end
	   

	   S_WR2[8:3]: begin
	     state <= S_WR3;
	      
	   end
	   S_WR3[8:3]: begin
	      state <= S_WR4;
	      dqs_en <= 1;
	      dq_oe <= 1;
	      dq_out0 <= c_data_in[63:48];
	      dq_out1 <= c_data_in[47:32];
	      
	   end
	   S_WR4[8:3]: begin
	      state <= S_WR5;
	      dqs_en <= 1;
	      dq_oe <= 1;
	      dq_out0 <= c_data_in[31:16];
	      dq_out1 <= c_data_in[15:0];
	      
	   end
	   
	   S_WR5[8:3]: begin
	     state <= S_WR6;
	   end
	   
	   S_WR6[8:3]:
	     state <= S_PRE0;
	   
	   
	   
	   
	   
 

	   
	      
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
   /*AUTOASCIIENUM("state", "state_ascii", "s_")*/
   // Beginning of automatic ASCII enum decoding
   reg [55:0]		state_ascii;		// Decode of state
   always @(state) begin
      case ({state})
	S_INIT_0:  state_ascii = "init_0 ";
	S_INIT_1:  state_ascii = "init_1 ";
	S_INIT_2:  state_ascii = "init_2 ";
	S_INIT_3:  state_ascii = "init_3 ";
	S_INIT_4:  state_ascii = "init_4 ";
	S_INIT_5:  state_ascii = "init_5 ";
	S_INIT_6:  state_ascii = "init_6 ";
	S_INIT_7:  state_ascii = "init_7 ";
	S_INIT_8:  state_ascii = "init_8 ";
	S_INIT_9:  state_ascii = "init_9 ";
	S_INIT_10: state_ascii = "init_10";
	S_INIT_11: state_ascii = "init_11";
	S_INIT_12: state_ascii = "init_12";
	S_INIT_13: state_ascii = "init_13";
	S_INIT_14: state_ascii = "init_14";
	S_RF0:     state_ascii = "rf0    ";
	S_RF1:     state_ascii = "rf1    ";
	S_ACT0:    state_ascii = "act0   ";
	S_ACT1:    state_ascii = "act1   ";
	S_ACT2:    state_ascii = "act2   ";
	S_PRE0:    state_ascii = "pre0   ";
	S_PRE1:    state_ascii = "pre1   ";
	S_PRE2:    state_ascii = "pre2   ";
	S_PRE3:    state_ascii = "pre3   ";
	S_RD0:     state_ascii = "rd0    ";
	S_RD1:     state_ascii = "rd1    ";
	S_RD2:     state_ascii = "rd2    ";
	S_RD3:     state_ascii = "rd3    ";
	S_RD4:     state_ascii = "rd4    ";
	S_RD5:     state_ascii = "rd5    ";
	S_RD6:     state_ascii = "rd6    ";
	S_RD7:     state_ascii = "rd7    ";
	S_WR0:     state_ascii = "wr0    ";
	S_WR1:     state_ascii = "wr1    ";
	S_WR2:     state_ascii = "wr2    ";
	S_WR3:     state_ascii = "wr3    ";
	S_WR4:     state_ascii = "wr4    ";
	S_WR5:     state_ascii = "wr5    ";
	S_WR6:     state_ascii = "wr6    ";
	S_IDLE:    state_ascii = "idle   ";
	default:   state_ascii = "%Error ";
      endcase
   end
   // End of automatics

endmodule // controller


