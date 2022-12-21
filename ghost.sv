module ghost(input Reset, frame_clk,
				 input [19:0] wall [21],
				 input [9:0] Pac_X_Pos, Pac_Y_Pos, Pac_Size_X, Pac_Size_Y,
				 input [1:0] state,
				 input [7:0] keycode,
				 input [1:0] ghost_num,
				 input [2:0] start_direction,
				 input logic patrol,
             output [9:0]  GhostX, GhostY,
				 output caught_check);

	 logic [9:0] Ghost_X_Pos, Ghost_X_Motion, Ghost_Y_Pos, Ghost_Y_Motion, Ghost_Y_Size, Ghost_X_Size;
	 logic start_check;
	 logic map_check_u, map_check_d, map_check_l, map_check_r;
	 logic [2:0] map_check;
	 int X_Disp, Y_Disp;
	 logic [2:0] direction;
	 logic X_Caught, Y_Caught;
	 logic map_check_ul, map_check_ur;
	 logic map_check_bl, map_check_br;
	 logic map_check_ru, map_check_rb;
	 logic map_check_lu, map_check_lb;
	 
    logic [9:0] Ghost_X_Center;  // Center position on the X axis
    logic [9:0] Ghost_Y_Center; // Center position on the Y axis*/
	 
    parameter [9:0] Ghost_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ghost_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ghost_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ghost_Y_Max=479;     // Bottommost point on the Y axis
    /*parameter [9:0] Ghost_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ghost_Y_Step=1;      // Step size on the Y axis*/
	 
	 always_comb begin
		if(ghost_num == 2'h0) begin
			Ghost_X_Center = 10'd320;
			Ghost_Y_Center = 10'd191;
		end
		else if(ghost_num == 2'h1) begin
			Ghost_X_Center = 10'd240;
			Ghost_Y_Center = 10'd127;
		end
		else if(ghost_num == 2'h2)begin
			Ghost_X_Center = 10'd400;
			Ghost_Y_Center = 10'd127;
		end
		else begin
			Ghost_X_Center = 10'd320;
			Ghost_Y_Center = 10'd319;
		end
	 end

	 assign Ghost_X_Size = 8;
	 assign Ghost_Y_Size = 8;
	 assign start_check = (keycode == 8'h04) || (keycode == 8'h07) || (keycode == 8'h16) || (keycode == 8'h1A);
	 
	 assign map_check_u = wall[(Ghost_Y_Pos - 72 - 1 - Ghost_Y_Size) / 16][(Ghost_X_Pos - 168) / 16];
	 assign map_check_d = wall[(Ghost_Y_Pos - 72 + 1 + Ghost_Y_Size) / 16][(Ghost_X_Pos - 168) / 16];
	 assign map_check_l = wall[(Ghost_Y_Pos - 72) / 16][(Ghost_X_Pos - 168 - 1 - Ghost_X_Size) / 16];
	 assign map_check_r = wall[(Ghost_Y_Pos - 72) / 16][(Ghost_X_Pos - 168 + 1 + Ghost_X_Size) / 16];
	 assign map_check = ~map_check_u + ~map_check_d + ~map_check_l + ~map_check_r;
	 
	 
	 assign map_check_ul = wall[(Ghost_Y_Pos - 72 - 1 - Ghost_Y_Size) / 16][(Ghost_X_Pos - 168 - 6) / 16];
	 assign map_check_ur = wall[(Ghost_Y_Pos - 72 - 1 - Ghost_Y_Size) / 16][(Ghost_X_Pos - 168 + 6) / 16];
	 assign map_check_bl = wall[(Ghost_Y_Pos - 72 + 1 + Ghost_Y_Size) / 16][(Ghost_X_Pos - 168 - 6) / 16];
	 assign map_check_br = wall[(Ghost_Y_Pos - 72 + 1 + Ghost_Y_Size) / 16][(Ghost_X_Pos - 168 + 6) / 16];
		
	 assign map_check_ru = wall[(Ghost_Y_Pos - 72 - 5) / 16][(Ghost_X_Pos - 168 + 1 + Ghost_X_Size) / 16];
	 assign map_check_rb = wall[(Ghost_Y_Pos - 72 + 5) / 16][(Ghost_X_Pos - 168 + 1 + Ghost_X_Size) / 16];
	 assign map_check_lu = wall[(Ghost_Y_Pos - 72 - 5) / 16][(Ghost_X_Pos - 168 - 1 - Ghost_X_Size) / 16];
	 assign map_check_lb = wall[(Ghost_Y_Pos - 72 + 5) / 16][(Ghost_X_Pos - 168 - 1 - Ghost_X_Size) / 16];
	 //Look into changing ghost collision detection
	
	 
	 //1: left, 2: right, 3: up, 4: down
	 always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ghost
			if(Reset) begin
				Ghost_X_Motion <= 10'd0;
				Ghost_Y_Motion <= 10'd0;
				Ghost_Y_Pos <= Ghost_Y_Center;
				Ghost_X_Pos <= Ghost_X_Center;
				direction <= 3'h4;
			end
			else if(state == 2'h2 || state == 2'h3) begin
				Ghost_X_Motion <= 10'd0;
				Ghost_Y_Motion <= 10'd0;
			end
			else if(state == 2'h1 && ~patrol)begin 
				direction <= direction;
				X_Disp <= Ghost_X_Pos - Pac_X_Pos;
				Y_Disp <= Ghost_Y_Pos - Pac_Y_Pos;
				
				if(direction == 3'h4) begin
					if(start_check) begin	
						direction <= start_direction;
					end
				end
				else if(direction == 2'h0) begin
					if(~map_check_lu && ~map_check_lb && (X_Disp != 0 || ~(map_check > 3))) begin
						Ghost_X_Motion <= -1;
						Ghost_Y_Motion <= 0;
					end
					else begin
						if(~map_check_bl && ~map_check_br && Y_Disp < 0) begin
							Ghost_X_Motion <= 0;
							Ghost_Y_Motion <= 1;
							direction <= 2'h3;
						end
						else if(~map_check_ur && ~map_check_ul && Y_Disp > 0) begin
							Ghost_X_Motion <= 0;
							Ghost_Y_Motion <= -1;
							direction <= 2'h2;
						end
						else if(~map_check_ru && ~map_check_rb)begin
							Ghost_X_Motion <= 1;
							Ghost_Y_Motion <= 0;
							direction <= 2'h1;
						end
						else begin
							Ghost_X_Motion <= 0;
							Ghost_Y_Motion <= 0;
						end
					end
				end
				else if(direction == 2'h1)  begin
					if(~map_check_ru && ~map_check_rb && (X_Disp != 0 || ~(map_check > 3))) begin
						Ghost_X_Motion <= 1;
						Ghost_Y_Motion <= 0;
					end
					else begin
						if(~map_check_bl && ~map_check_br && Y_Disp < 0) begin
							Ghost_X_Motion <= 0;
							Ghost_Y_Motion <= 1;
							direction <= 2'h3;
						end
						else if(~map_check_ur && ~map_check_ul && Y_Disp > 0) begin
							Ghost_X_Motion <= 0;
							Ghost_Y_Motion <= -1;
							direction <= 2'h2;
						end
						else if(~map_check_lu && ~map_check_lb)begin
							Ghost_X_Motion <= -1;
							Ghost_Y_Motion <= 0;
							direction <= 2'h0;
						end
						else begin
							Ghost_X_Motion <= 0;
							Ghost_Y_Motion <= 0;
						end
					end
				end
				else if(direction == 2'h2) begin
					if(~map_check_ul && ~map_check_ur && (Y_Disp != 0 || ~(map_check > 3))) begin
						Ghost_X_Motion <= 0;
						Ghost_Y_Motion <= -1;
					end
					else begin
						if(~map_check_ru && ~map_check_rb && X_Disp < 0) begin
							Ghost_X_Motion <= 1;
							Ghost_Y_Motion <= 0;
							direction <= 2'h1;
						end
						else if(~map_check_lu && ~map_check_lb && X_Disp > 0) begin
							Ghost_X_Motion <= -1;
							Ghost_Y_Motion <= 0;
							direction <= 2'h0;
						end
						else if(~map_check_bl && ~map_check_br) begin
							Ghost_X_Motion <= 0;
							Ghost_Y_Motion <= 1;
							direction <= 2'h3;
						end
						else begin
							Ghost_X_Motion <= 0;
							Ghost_Y_Motion <= 0;
						end
					end
				end
				else if(direction == 2'h3) begin
					if(~map_check_br && ~map_check_bl && (Y_Disp != 0 || ~(map_check > 3))) begin
						Ghost_X_Motion <= 0;
						Ghost_Y_Motion <= 1;
					end
					else begin
						if(~map_check_ru && ~map_check_rb && X_Disp < 0) begin
							Ghost_X_Motion <= 1;
							Ghost_Y_Motion <= 0;
							direction <= 2'h1;
						end
						else if(~map_check_lu && ~map_check_lb && X_Disp > 0) begin
							Ghost_X_Motion <= -1;
							Ghost_Y_Motion <= 0;
							direction <= 2'h0;
						end
						else if(~map_check_ur && ~map_check_ul)begin
							Ghost_X_Motion <= 0;
							Ghost_Y_Motion <= -1;
							direction <= 2'h2;
						end
						else begin
							Ghost_X_Motion <= 0;
							Ghost_Y_Motion <= 0;
						end
					end
				end
				Ghost_Y_Pos <= (Ghost_Y_Pos + Ghost_Y_Motion);  // Update ball position
				Ghost_X_Pos <= (Ghost_X_Pos + Ghost_X_Motion);
			end
			else if(state == 2'h1 && patrol) begin
				direction <= direction;
				X_Disp <= Ghost_X_Pos - Pac_X_Pos;
				Y_Disp <= Ghost_Y_Pos - Pac_Y_Pos;
				
				if(direction == 3'h4) begin
					if(start_check) begin	
						direction <= start_direction;
					end
				end
				else if(direction == 2'h0) begin
					if(~map_check_l) begin
						Ghost_X_Motion <= -1;
						Ghost_Y_Motion <= 0;
					end
					else begin
						if(~map_check_d) begin
							Ghost_X_Motion <= 0;
							Ghost_Y_Motion <= 1;
							direction <= 2'h3;
						end
						else if(~map_check_u) begin
							Ghost_X_Motion <= 0;
							Ghost_Y_Motion <= -1;
							direction <= 2'h2;
						end
						else if(~map_check_r)begin
							Ghost_X_Motion <= 1;
							Ghost_Y_Motion <= 0;
							direction <= 2'h1;
						end
						else begin
							Ghost_X_Motion <= 0;
							Ghost_Y_Motion <= 0;
						end
					end
				end
				else if(direction == 2'h1)  begin
					if(~map_check_r) begin
						Ghost_X_Motion <= 1;
						Ghost_Y_Motion <= 0;
					end
					else begin
						if(~map_check_d) begin
							Ghost_X_Motion <= 0;
							Ghost_Y_Motion <= 1;
							direction <= 2'h3;
						end
						else if(~map_check_u) begin
							Ghost_X_Motion <= 0;
							Ghost_Y_Motion <= -1;
							direction <= 2'h2;
						end
						else if(~map_check_l)begin
							Ghost_X_Motion <= -1;
							Ghost_Y_Motion <= 0;
							direction <= 2'h0;
						end
						else begin
							Ghost_X_Motion <= 0;
							Ghost_Y_Motion <= 0;
						end
					end
				end
				else if(direction == 2'h2) begin
					if(~map_check_u) begin
						Ghost_X_Motion <= 0;
						Ghost_Y_Motion <= -1;
					end
					else begin
						if(~map_check_r) begin
							Ghost_X_Motion <= 1;
							Ghost_Y_Motion <= 0;
							direction <= 2'h1;
						end
						else if(~map_check_l) begin
							Ghost_X_Motion <= -1;
							Ghost_Y_Motion <= 0;
							direction <= 2'h0;
						end
						else if(~map_check_d) begin
							Ghost_X_Motion <= 0;
							Ghost_Y_Motion <= 1;
							direction <= 2'h3;
						end
						else begin
							Ghost_X_Motion <= 0;
							Ghost_Y_Motion <= 0;
						end
					end
				end
				else if(direction == 2'h3) begin
					if(~map_check_d) begin
						Ghost_X_Motion <= 0;
						Ghost_Y_Motion <= 1;
					end
					else begin
						if(~map_check_r) begin
							Ghost_X_Motion <= 1;
							Ghost_Y_Motion <= 0;
							direction <= 2'h1;
						end
						else if(~map_check_l) begin
							Ghost_X_Motion <= -1;
							Ghost_Y_Motion <= 0;
							direction <= 2'h0;
						end
						else if(~map_check_u)begin
							Ghost_X_Motion <= 0;
							Ghost_Y_Motion <= -1;
							direction <= 2'h2;
						end
						else begin
							Ghost_X_Motion <= 0;
							Ghost_Y_Motion <= 0;
						end
					end
				end
				Ghost_Y_Pos <= (Ghost_Y_Pos + Ghost_Y_Motion);  // Update ball position
				Ghost_X_Pos <= (Ghost_X_Pos + Ghost_X_Motion);
			end			
	 end
	
	 assign X_Caught = Ghost_X_Pos - Pac_X_Pos <= 13 || Pac_X_Pos - Ghost_X_Pos <= 13;
	 assign Y_Caught = Ghost_Y_Pos - Pac_Y_Pos <= 13 || Pac_Y_Pos - Ghost_Y_Pos <= 13;
	 
	 
	 //Check for corners
	 
	 //assign caught_check = (X_Caught && (Ghost_Y_Pos - Pac_Y_Pos <= 3) && (Ghost_Y_Pos - Pac_Y_Pos + 3 >= 0)) || (Y_Caught && (Ghost_X_Pos - Pac_X_Pos <= 3) && (Ghost_X_Pos - Pac_X_Pos + 3 >= 0));
	 assign caught_check = X_Caught && Y_Caught;
	 
	 assign GhostX = Ghost_X_Pos;
	 assign GhostY = Ghost_Y_Pos;
	
endmodule
