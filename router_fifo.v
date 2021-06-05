module router_fifo(input clock,resetn,soft_reset,write_enb,read_enb,lfd_state,
				   input[7:0] data_in,
				   output full,empty,
				   output reg[7:0] data_out);
	reg[8:0] mem[15:0];
	reg[4:0] rd_ptr,wr_ptr;
	reg[6:0] count;
	reg lfd;
	
	always@(posedge clock)lfd <= lfd_state;
	
	always@(posedge clock)
	begin
		if(!resetn){rd_ptr,data_out} <= 0;
		else if(soft_reset)
		begin
			rd_ptr <= 0;
			data_out <= 'bz;
		end
		else if(read_enb && !empty)
		begin
			data_out <= mem[rd_ptr[3:0]][7:0];
			rd_ptr <= rd_ptr + 1'b1;
		end
		
		if(data_out && !count)data_out <= 'bz;
	end
	
	always@(posedge clock)
	begin
		if(!resetn || soft_reset)wr_ptr <= 0;
		else if(write_enb && !full)
		begin
			mem[wr_ptr[3:0]] <= {lfd,data_in};
			wr_ptr <= wr_ptr + 1'b1;
		end
	end
	
	always@(posedge clock)
	begin
		if(!resetn || soft_reset)count <= 0;
		else if(read_enb && !empty)count <= mem[rd_ptr[3:0]][8] ? mem[rd_ptr[3:0]][7:2] + 1'b1 : count ? count - 1'b1 : 0;
		else count <= count;
	end
	
	assign full = (rd_ptr[3:0]==wr_ptr[3:0] && rd_ptr[4]!=wr_ptr[4])?1:0;
	assign empty = (rd_ptr==wr_ptr)?1:0;
endmodule