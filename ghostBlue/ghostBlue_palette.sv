module ghostBlue_palette (
	input logic [1:0] index,
	output logic [3:0] red, green, blue
);

logic [11:0] palette [4];
assign {red, green, blue} = palette[index];

always_comb begin
	palette[00] = {4'h0, 4'hE, 4'hD};
	palette[01] = {4'h0, 4'h0, 4'h0};
	palette[02] = {4'hB, 4'hD, 4'hD};
	palette[03] = {4'h2, 4'h4, 4'hD};
end

endmodule
