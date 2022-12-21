module reg_shift(
	input clock,
	input lrclock,
	input [31:0] d,
	output shift_out
);
logic [31:0] register;
	
	always_ff @ (posedge clock)
		if(lrclock)
			begin
				shift_out <= register[31];
				register <= {register[30:0], 1'b0};
			end
		else 
			register <=d [31:0];
	


endmodule 