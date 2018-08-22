module ODDR (Q, C, CE, D1, D2, R, S);
    
    output Q;
    
    input C;
    input CE;
    input D1;
    input D2;    
    input R;
    input S;

    parameter DDR_CLK_EDGE = "OPPOSITE_EDGE";    
    parameter INIT = 1'b0;
    parameter SRTYPE = "SYNC";

    reg q0_out, qd2_posedge_int;    
    reg q1_out;

    wire qd2;

    buf buf_c (c_in, C);
    buf buf_ce (ce_in, CE);
    buf buf_d1 (d1_in, D1);
    buf buf_d2 (d2_in, D2);    
    buf buf_r (r_in, R);
    buf buf_s (s_in, S);    


    always @(r_in or s_in) begin
      if (r_in == 1'b1 && SRTYPE == "ASYNC") begin
	q0_out <= 1'b0;
        q1_out <= 1'b0;
	qd2_posedge_int <= 1'b0;
      end
      else if (r_in == 1'b0 && s_in == 1'b1 && SRTYPE == "ASYNC") begin
         q0_out <= 1'b1;
         q1_out <= 1'b1;
         qd2_posedge_int <= 1'b1;
      end 
    end	    
	    

    always @(posedge c_in) begin
 	if (r_in == 1'b1) begin
	    q0_out <= 1'b0;
	    qd2_posedge_int <= 1'b0;
	end
	else if (r_in == 1'b0 && s_in == 1'b1) begin
	    q0_out <= 1'b1;
	    qd2_posedge_int <= 1'b1;
	end
	else if (ce_in == 1'b1 && r_in == 1'b0 && s_in == 1'b0) begin
	    q0_out <= d1_in;
	    qd2_posedge_int <= d2_in;
	end
    end // always @ (posedge c_in)
    
	
    always @(negedge c_in) begin
	if (r_in == 1'b1)
	    q1_out <= 1'b0;
	else if (r_in == 1'b0 && s_in == 1'b1)
	    q1_out <= 1'b1;
	else if (ce_in == 1'b1 && r_in == 1'b0 && s_in == 1'b0) begin
	    if (DDR_CLK_EDGE == "SAME_EDGE")
		q1_out <= qd2_posedge_int;
	    else if (DDR_CLK_EDGE == "OPPOSITE_EDGE")
		q1_out <= d2_in;
	end
    end // always @ (negedge c_in)
    
  assign Q =  c_in ?  q0_out : q1_out;

endmodule // ODDR
