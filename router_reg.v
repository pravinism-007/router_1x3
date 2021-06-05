module router_reg(input clock,resetn,pkt_valid,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,
				  input[7:0] data_in,
				  output reg err,parity_done,low_packet_valid,
				  output reg[7:0] dout);
				  
	reg[7:0] header,full_state_byte,internal_parity,packet_parity;			  
	
	always@(posedge clock)if(detect_add)header <= data_in;
	
	always@(posedge clock)
	begin
		if(!resetn)dout <= 0;
		else if(lfd_state)
		begin
			dout <= {lfd_state,header};
			internal_parity <= header;
		end
		else if(ld_state)
		begin
			if(!fifo_full)
			begin
				dout <= data_in;
				if(!pkt_valid)packet_parity <= data_in;
			end
			else
			begin
				full_state_byte <= data_in;
				if(!pkt_valid)packet_parity <= data_in;
			end
			if(pkt_valid)internal_parity <= internal_parity ^ data_in;
		end
		else if(laf_state)dout <= full_state_byte;
	end
	
	always@(posedge clock)
		if(!resetn || detect_add)parity_done <= 0;
		else if(ld_state && !pkt_valid && !fifo_full)parity_done <= 1;
		else if(laf_state && low_packet_valid && !parity_done)parity_done <= 1;
	
	always@(posedge clock)
		if(!resetn || detect_add)err <= 0;
		else if(parity_done && internal_parity!=packet_parity)err <= 1;
	
	always@(posedge clock)
		if(!resetn || rst_int_reg)low_packet_valid <= 0;
		else if(ld_state && !pkt_valid)low_packet_valid <= 1;
	
endmodule