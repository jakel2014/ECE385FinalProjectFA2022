module map_palette (
	input logic [2:0] index,
	output logic [3:0] red, green, blue
);

logic [11:0] palette [8];
assign {red, green, blue} = palette[index];

always_comb begin
	palette[00] = {4'h0, 4'h0, 4'h0};
	palette[01] = {4'h0, 4'h0, 4'hC};
	palette[02] = {4'h0, 4'h0, 4'h4};
	palette[03] = {4'h0, 4'h0, 4'hD};
	palette[04] = {4'h0, 4'h0, 4'h2};
	palette[05] = {4'hC, 4'h7, 4'h7};
	palette[06] = {4'h0, 4'h0, 4'h7};
	palette[07] = {4'h0, 4'h0, 4'h0};
end

endmodule
