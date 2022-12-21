module pacManOpenR_rom (
	input logic clock,
	input logic [7:0] address,
	output logic [1:0] q
);

logic [1:0] memory [0:255] /* synthesis ram_init_file = "./pacManOpenR/pacManOpenR.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
