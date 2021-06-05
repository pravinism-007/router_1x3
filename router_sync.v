module router_sync(input clock,resetn,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,
				   input[1:0] data_in,
				   output reg[2:0] write_enb,
				   output reg fifo_full,
				   output soft_reset_0,soft_reset_1,soft_reset_2,vld_out_0,vld_out_1,vld_out_2);
	reg[1:0] addr;
	
	always@(posedge clock)
		if(!resetn)addr <= 2'b11;
		else if(detect_add)addr <= data_in;
		else addr <= addr;
	
	always@(*)
		if(write_enb_reg)
			case(addr)
				2'b00: write_enb = 3'b001;
				2'b01: write_enb = 3'b010;
				2'b10: write_enb = 3'b100;
				default: write_enb = 0;
			endcase
		else write_enb = 0;
		
	router_sync_counter counter_0(clock,resetn,vld_out_0,read_enb_0,soft_reset_0);
	router_sync_counter	counter_1(clock,resetn,vld_out_1,read_enb_1,soft_reset_1);
	router_sync_counter	counter_2(clock,resetn,vld_out_2,read_enb_2,soft_reset_2);
	
	always@(*)
		case(addr)
			2'b00: fifo_full = full_0;
			2'b01: fifo_full = full_1;
			2'b10: fifo_full = full_2;
			default: fifo_full = 'bz;
		endcase
		
	assign vld_out_0 = ~empty_0;
	assign vld_out_1 = ~empty_1;
	assign vld_out_2 = ~empty_2; 
endmodule