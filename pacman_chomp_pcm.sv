module pacman_chomp_pcm_rom (
input clk,
input [13:0] addr,
output logic [7:0] q
);

logic [7:0] rom [15800];
always_ff @(posedge clk) begin
	q <= rom[addr];
end
initial begin $readmemh("pacman_chomp_pcm.txt", rom); end
endmodule