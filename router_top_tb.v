module router_top_tb;
	reg clock=0,resetn,pkt_valid,read_enb_0 = 0,read_enb_1,read_enb_2;
	reg[7:0] data_in;
	wire busy,err,vld_out_0,vld_out_1,vld_out_2;
	wire[7:0] data_out_0,data_out_1,data_out_2;
	
	reg[3*8:1] st;
	
	router_top DUT(clock,resetn,pkt_valid,read_enb_0,read_enb_1,read_enb_2,
				   data_in,
				   busy,err,vld_out_0,vld_out_1,vld_out_2,
				   data_out_0,data_out_1,data_out_2);
	
	task automatic transmit(input[5:0] i,input[1:0] addr,input corrupt);
	begin: abc
		reg[7:0] parity;
		reg flag = 0;
		integer count = 0;
		
		@(negedge clock)
		flag = 0;
			@(negedge clock)
			while(busy)#2 flag = 1;
			if(flag)@(negedge clock);
		resetn = 1;
		pkt_valid = 1;
		data_in = {i,addr};
		parity = data_in;
		
		repeat(i)
		begin
			flag = 0;
			@(negedge clock)
			while(busy)#2 flag = 1;
			if(flag)@(negedge clock);
			data_in = $random % 256;
			parity = parity ^ data_in;
		end
		
		flag = 0;
		@(negedge clock)
		while(busy)#2 flag = 1;
		pkt_valid = 0;
		data_in = corrupt ? ($random % 256) : parity;
	end
	endtask
	
	task reset;
		@(negedge clock)resetn = 0;
	endtask
	
	always@(*)
	case(DUT.FSM.state)
		0: st = "DA";
		1: st = "LFD";
		2: st = "LD";
		3: st = "FFS";
		4: st = "LAF";
		5: st = "LP";
		6: st = "CPE";
		7: st = "WTE";
	endcase
	
	always #5 clock = !clock;
	
	always@(posedge clock)
	begin: a
		while(!vld_out_0)#1;
		read_enb_0 = 1;
		while(vld_out_0)#1;
		read_enb_0 = 0;
	end
	
	always@(posedge clock)
	begin: b
		while(!vld_out_1)#1;
		read_enb_1 = 1;
		while(vld_out_1)#1;
		read_enb_1 = 0;
	end
	
	always@(posedge clock)
	begin: c
		while(!vld_out_2)#1;
		read_enb_2 = 1;
		while(vld_out_2)#1;
		read_enb_2 = 0;
	end
	
	initial
	begin
		reset;
		transmit(14,0,1);
		transmit(16,1,0);
		transmit(5,2,1);
		repeat(4)@(negedge clock);
		$finish;
	end
	
endmodule
