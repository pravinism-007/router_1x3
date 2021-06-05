module router_fsm(input clock,resetn,pkt_valid,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid,
				  input[1:0] data_in,
				  output write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);
				  
	parameter DECODE_ADDRESS = 3'b000,
			  LOAD_FIRST_DATA = 3'b001,
			  LOAD_DATA = 3'b010,
			  FIFO_FULL_STATE = 3'b011,
			  LOAD_AFTER_FULL = 3'b100,
			  LOAD_PARITY = 3'b101,
			  CHECK_PARITY_ERROR = 3'b110,
			  WAIT_TILL_EMPTY = 3'b111;
			  
	reg[2:0] state,next_state;
	reg[1:0] addr;
	
	always@(posedge clock)
	if(!resetn)state <= DECODE_ADDRESS;
	else if((addr==2'd0 && soft_reset_0) || (addr==2'd1 && soft_reset_1) || (addr==2'd2 && soft_reset_2))state <= DECODE_ADDRESS;
	else state <= next_state;
	
	always@(posedge clock)
	if(!resetn)addr <= 2'b11;
	else if(state==DECODE_ADDRESS)addr <= data_in;
	else addr <= addr;
	
	always@(*)
		case(state)
			DECODE_ADDRESS: if(pkt_valid)
							begin
								if((data_in==2'd0 && fifo_empty_0)||(data_in==2'd1 && fifo_empty_1)||(data_in==2'd2 && fifo_empty_2))
								next_state <= LOAD_FIRST_DATA;
								else if((data_in==2'd0 && !fifo_empty_0)||(data_in==2'd1 && !fifo_empty_1)||(data_in==2'd2 && !fifo_empty_2))
								next_state <= WAIT_TILL_EMPTY;
								else next_state <= DECODE_ADDRESS;
							end
							else next_state <= DECODE_ADDRESS;
			WAIT_TILL_EMPTY: begin
								next_state <= WAIT_TILL_EMPTY;
								case(data_in)
									0: if(fifo_empty_0)next_state <= LOAD_FIRST_DATA;
									1: if(fifo_empty_1)next_state <= LOAD_FIRST_DATA;
									2: if(fifo_empty_2)next_state <= LOAD_FIRST_DATA;
								endcase
							end
			LOAD_FIRST_DATA: next_state <= LOAD_DATA;
			LOAD_DATA: next_state <= fifo_full ? FIFO_FULL_STATE : pkt_valid ? LOAD_DATA : LOAD_PARITY;
			FIFO_FULL_STATE: next_state <= fifo_full ? FIFO_FULL_STATE : LOAD_AFTER_FULL;
			LOAD_AFTER_FULL: next_state <= parity_done ? DECODE_ADDRESS : low_packet_valid ? LOAD_PARITY : LOAD_DATA;
			LOAD_PARITY: next_state <= CHECK_PARITY_ERROR;
			CHECK_PARITY_ERROR: next_state <= fifo_full ? FIFO_FULL_STATE : DECODE_ADDRESS;
		endcase
		
	assign detect_add = state==DECODE_ADDRESS;
	assign lfd_state = state==LOAD_FIRST_DATA;
	assign ld_state = state==LOAD_DATA;
	assign write_enb_reg = (state==LOAD_DATA) || (state==LOAD_PARITY) || (state==LOAD_AFTER_FULL);
	assign busy = (state!=DECODE_ADDRESS) && (state!=LOAD_DATA);
	assign laf_state = state==LOAD_AFTER_FULL;
	assign full_state = state==FIFO_FULL_STATE;
	assign rst_int_reg = state==CHECK_PARITY_ERROR;
endmodule