module router_sync_counter(input clk,rst,vld_out,read_enb,
						   output reg soft_reset);
	reg[4:0] count;
	always@(posedge clk)
	begin
		if(!rst || soft_reset){count,soft_reset} <= 0;
		else if(vld_out)
		begin
			if(read_enb!=1) 
			begin
				if(count == 5'd30) soft_reset <= 1;
				else count <= count + 1'd1;
			end
			else count <= 0;
		end
		else count <= 0;
	end
endmodule