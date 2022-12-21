//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( input        [9:0] BallX, BallY, DrawX, DrawY, Ball_Size_X, Ball_Size_Y, 
							  input        [9:0] GhostXR, GhostYR, Ghost_Size_X, Ghost_Size_Y, GhostXP, GhostYP,
							  input        [9:0] GhostXB, GhostYB, GhostXO, GhostYO,
							  input        [19:0] pellet [21],
							  input        VGA_CLK, blank,
							  input        [1:0] state,
							  input int score,
							  input        [7:0] keycode,
                       output logic [3:0]  Red, Green, Blue);
    
    logic ball_on, pellet_on, ghost_on_R, ghost_on_P, ghost_on_B, ghost_on_O;
	 logic [4:0] map_file_ADDR;
	  
    int DistX, DistY;
	 assign DistX = DrawX - BallX;
    assign DistY = DrawY - BallY;	 
	 
	 logic [3:0] map_R, map_G, map_B;
	 logic [17:0] rom_address;
	 logic [4:0] rom_q;
	 
	 logic bounds, pellCheck, start_screen_bounds, end_screen_bounds;
	 
	 assign bounds = 72 < DrawY && DrawY < 407 && 168 < DrawX && DrawX < 471;
	 assign pellCheck = ((DrawY-72) % 16 == 7 || (DrawY-72) % 16 == 8) && ((DrawX-168) % 16 == 7 || (DrawX-168) % 16 == 8);
	 assign start_screen_bounds = 0 < DrawX && DrawX <= 639 && 0 < DrawY && DrawY <= 479;
	 assign end_screen_bounds = (220 <= DrawX && DrawX <= 420) && (181 < DrawY && DrawY <= 299);
	 
	 logic [3:0] pac_R, pac_G, pac_B, pac_Rr, pac_Gr, pac_Br, pac_Rl, pac_Gl, pac_Bl;
	 logic [3:0] pac_Ru, pac_Gu, pac_Bu, pac_Rd, pac_Gd, pac_Bd;
	 logic [8:0] pac_address, pac_x, pac_y;
	 logic [2:0] pac_qr, pac_ql, pac_qu, pac_qd;
	 logic [8:0] ghost_address_R, ghost_address_P, ghost_address_B, ghost_x_R, ghost_y_R, ghost_x_P, ghost_y_P, ghost_x_B, ghost_y_B;
	 logic [8:0] ghost_address_O, ghost_x_O, ghost_y_O;
	 logic [4:0] ghost_qR, ghost_qP, ghost_qB, ghost_qO;
	 logic [3:0] ghost_Rr, ghost_Gr, ghost_Br, ghost_Rp, ghost_Gp, ghost_Bp, ghost_Rb, ghost_Gb, ghost_Bb;
	 logic [3:0] ghost_Ro, ghost_Go, ghost_Bo;
	 
	 logic [3:0] start_R, start_G, start_B;
	 logic [18:0] start_address;
	 logic start_q;
	 logic start_screen_on;
	 
	 logic [3:0] end_R, end_G, end_B;
	 logic [14:0] end_address;
	 logic end_q;
	 logic end_screen_on;
	 
	 assign start_address = (DrawX*640/640) + (DrawY*480/480 * 640);
	 assign rom_address = (DrawX*640/640) + (DrawY*480/480 * 640);
	 assign start_screen_on = (state == 2'h3) && (start_screen_bounds);
	 
	 always_comb begin
		if(state == 2'h2 && end_screen_bounds) begin
			end_screen_on = 1'b1;
		end
		else begin
			end_screen_on = 1'b0;
		end
	 
	 end
	 
	 always_comb begin
		if(end_screen_on) begin
			end_address = (DrawX - 220) + (DrawY - 181)*200;
		end
		else begin
			end_address = 0;
		end
	 end
	 
    always_comb
    begin:Ball_on_proc
			/*
        if ( ( DistX*DistX) + (DistY*DistY) <= (Ball_Size_X * Ball_Size_Y) ) begin
            ball_on = 1'b1;
				end
        else begin
            ball_on = 1'b0;
				end*/
		
			if ((DrawX >= BallX - Ball_Size_X) &&
				(DrawX <= (BallX + Ball_Size_X - 1)) &&
				(DrawY >= (BallY - Ball_Size_Y + 1)) &&
				(DrawY <= BallY + Ball_Size_Y))
				ball_on = 1'b1;
			else
				ball_on = 1'b0;
				
			if ((DrawX >= GhostXR - Ghost_Size_X) &&
				(DrawX <= (GhostXR + Ghost_Size_X - 1)) &&
				(DrawY >= (GhostYR - Ghost_Size_Y + 1)) &&
				(DrawY <= GhostYR + Ghost_Size_Y))
				ghost_on_R = 1'b1;
			else
				ghost_on_R = 1'b0;
				
			if ((DrawX >= GhostXP - Ghost_Size_X) &&
				(DrawX <= (GhostXP + Ghost_Size_X - 1)) &&
				(DrawY >= (GhostYP - Ghost_Size_Y + 1)) &&
				(DrawY <= GhostYP + Ghost_Size_Y))
				ghost_on_P = 1'b1;
			else
				ghost_on_P = 1'b0;
				
			if ((DrawX >= GhostXB - Ghost_Size_X) &&
				(DrawX <= (GhostXB + Ghost_Size_X - 1)) &&
				(DrawY >= (GhostYB - Ghost_Size_Y + 1)) &&
				(DrawY <= GhostYB + Ghost_Size_Y))
				ghost_on_B = 1'b1;
			else
				ghost_on_B = 1'b0;
				
			if ((DrawX >= GhostXO - Ghost_Size_X) &&
				(DrawX <= (GhostXO + Ghost_Size_X - 1)) &&
				(DrawY >= (GhostYO - Ghost_Size_Y + 1)) &&
				(DrawY <= GhostYO + Ghost_Size_Y))
				ghost_on_O = 1'b1;
			else
				ghost_on_O = 1'b0;
				
     end 
	  
	 always_comb
	  begin: pellet_on_proc
			if ( pellet[ (DrawY - 72) / 16 ][ (DrawX - 168) / 16] == 1'b1 && pellCheck && bounds )
				pellet_on = 1'b1;
			else
				pellet_on= 1'b0;
	  end
	 
	 always_comb begin
		if(ball_on) begin
			pac_x = (DrawX - BallX) + 8;
			pac_y = (DrawY - BallY) + 7;
		end
		else begin
			pac_x = 9'b0;
			pac_y = 9'b0;
		end
	 end
	 
	 always_comb begin
		if(ghost_on_R) begin
			ghost_x_R = (DrawX - GhostXR) + 8;
			ghost_y_R = (DrawY - GhostYR) + 7;
		end
		else begin
			ghost_x_R = 9'b0;
			ghost_y_R = 9'b0;
		end
	 end
	 
	 always_comb begin
		if(ghost_on_P) begin
			ghost_x_P = (DrawX - GhostXP) + 8;
			ghost_y_P = (DrawY - GhostYP) + 7;
		end
		else begin
			ghost_x_P = 9'b0;
			ghost_y_P = 9'b0;
		end
	 end
	 
	 always_comb begin
		if(ghost_on_B) begin
			ghost_x_B = (DrawX - GhostXB) + 8;
			ghost_y_B = (DrawY - GhostYB) + 7;
		end
		else begin
			ghost_x_B = 9'b0;
			ghost_y_B = 9'b0;
		end
	 end
	 
	 always_comb begin
		if(ghost_on_O) begin
			ghost_x_O = (DrawX - GhostXO) + 8;
			ghost_y_O = (DrawY - GhostYO) + 7;
		end
		else begin
			ghost_x_O = 9'b0;
			ghost_y_O = 9'b0;
		end
	 end
	 
	 assign pac_address = pac_x + (16 * pac_y);
	 assign ghost_address_R = ghost_x_R + (16 * ghost_y_R);
	 assign ghost_address_P = ghost_x_P + (16 * ghost_y_P);
	 assign ghost_address_B = ghost_x_B + (16 * ghost_y_B);
	 assign ghost_address_O = ghost_x_O + (16 * ghost_y_O);
	 
	 always_ff @ (posedge VGA_CLK) begin
		case(keycode) 
			8'h04: begin
				pac_R <= pac_Rl;
				pac_G <= pac_Gl;
				pac_B <= pac_Bl;
			end
			8'h16: begin
				pac_R <= pac_Rd;
				pac_G <= pac_Gd;
				pac_B <= pac_Bd;
			end
			8'h1A: begin
				pac_R <= pac_Ru;
				pac_G <= pac_Gu;
				pac_B <= pac_Bu;
			end
			default: begin
				pac_R <= pac_Rr;
				pac_G <= pac_Gr;
				pac_B <= pac_Br;
			end
		endcase
	 
	 end
       
    always_ff @ (posedge VGA_CLK)
    begin:RGB_Display
		  if(start_screen_on) begin
			  Red <= start_R; 
			  Green <= start_G;
			  Blue <= start_B;
		  end
		  else if(end_screen_on) begin
			  Red <= end_R; 
			  Green <= end_G;
			  Blue <= end_B;
		  end
		  else if(ghost_on_R == 1'b1) begin 
				if(ghost_Rr != 4'h0 || ghost_Gr != 4'h0 || ghost_Br != 4'h0) begin
					Red <= ghost_Rr;
					Green <= ghost_Gr;
					Blue <= ghost_Br;
				end
				else begin
					Red <= map_R;
					Green <= map_G;
					Blue <= map_B;
				end
		  end
		  else if(ghost_on_P == 1'b1) begin 
				if(ghost_Rp != 4'h0 || ghost_Gp != 4'h0 || ghost_Bp != 4'h0) begin
					Red <= ghost_Rp;
					Green <= ghost_Gp;
					Blue <= ghost_Bp;
				end
				else begin
					Red <= map_R;
					Green <= map_G;
					Blue <= map_B;
				end
		  end
		  else if(ghost_on_B == 1'b1) begin 
				if(ghost_Rb != 4'h0 || ghost_Gb != 4'h0 || ghost_Bb != 4'h0) begin
					Red <= ghost_Rb;
					Green <= ghost_Gb;
					Blue <= ghost_Bb;
				end
				else begin
					Red <= map_R;
					Green <= map_G;
					Blue <= map_B;
				end
		  end
		  else if(ghost_on_O == 1'b1) begin 
				if(ghost_Ro != 4'h0 || ghost_Go != 4'h0 || ghost_Bo != 4'h0) begin
					Red <= ghost_Ro;
					Green <= ghost_Go;
					Blue <= ghost_Bo;
				end
				else begin
					Red <= map_R;
					Green <= map_G;
					Blue <= map_B;
				end
		  end
		  else if ((ball_on == 1'b1)) 
        begin 
			if(pac_R != 4'h0 || pac_G != 4'h0 || pac_B != 4'h0) begin
				Red <= pac_R; 
				Green <= pac_G;
				Blue <= pac_B;
			end
			else begin
				Red <= map_R;
				Green <= map_G;
				Blue <= map_B;
			end
        end 
		  else if(pellet_on == 1'b1) begin
				Red <= 4'hff;
				Green <= 4'hff;
				Blue <= 4'hff;
		  end
		  else if(bounds) begin
				Red <= map_R; 
            Green <= map_G;
            Blue <= map_B;
		  end
		  else if (score1_bounds)
          begin
                Red = score1_R;
                Green = score1_G;
                Blue = score1_B;
          end
          else if (score2_bounds)
          begin
                Red = score2_R;
                Green = score2_G;
                Blue = score2_B;
          end
          else if (score3_bounds)
          begin
                Red = score3_R;
                Green = score3_G;
                Blue = score3_B;
          end
          else if (score4_bounds)
          begin
                Red = score4_R;
                Green = score4_G;
                Blue = score4_B;
          end
        else 
        begin 
            Red <= 4'h0; 
            Green <= 4'h0;
            Blue <= 4'h0;
        end  
    end 

StartScreen_rom StartScreen_rom (
	.clock (VGA_CLK),
	.address(start_address),
	.q(start_q)
);

StartScreen_palette StartScreen_palette (
	.index(start_q),
	.red(start_R), .green(start_G), .blue(start_B)
);	


map_rom map_rom (
	.clock   (VGA_CLK),
	.address (rom_address),
	.q       (rom_q)
);

map_palette map_palette (
	.index (rom_q),
	.red   (map_R),
	.green (map_G),
	.blue  (map_B)
);

pacManOpenR_rom pacManOpenR_rom (
	.clock   (VGA_CLK),
	.address (pac_address),
	.q       (pac_qr)
);

pacManOpenR_palette pacManOpenR_palette (
	.index (pac_qr),
	.red   (pac_Rr),
	.green (pac_Gr),
	.blue  (pac_Br)
);

pacManOpenL_rom pacManOpenL_rom (
	.clock   (VGA_CLK),
	.address (pac_address),
	.q       (pac_ql)
);

pacManOpenL_palette pacManOpenL_palette (
	.index (pac_ql),
	.red   (pac_Rl),
	.green (pac_Gl),
	.blue  (pac_Bl)
);

pacManOpenU_rom pacManOpenU_rom (
	.clock   (VGA_CLK),
	.address (pac_address),
	.q       (pac_qu)
);

pacManOpenU_palette pacManOpenU_palette (
	.index (pac_qu),
	.red   (pac_Ru),
	.green (pac_Gu),
	.blue  (pac_Bu)
);

pacManOpenD_rom pacManOpenD_rom (
	.clock   (VGA_CLK),
	.address (pac_address),
	.q       (pac_qd)
);

pacManOpenD_palette pacManOpenD_palette (
	.index (pac_qd),
	.red   (pac_Rd),
	.green (pac_Gd),
	.blue  (pac_Bd)
);

ghostRed_palette ghostRed_palette (
	.index (ghost_qR),
	.red (ghost_Rr),
	.green (ghost_Gr),
	.blue (ghost_Br)
);

ghostRed_rom ghostRed_rom(
	.clock   (VGA_CLK),
	.address (ghost_address_R),
	.q       (ghost_qR)
);

ghostPink_palette ghostPink_palette (
	.index (ghost_qP),
	.red (ghost_Rp),
	.green (ghost_Gp),
	.blue (ghost_Bp)
);

ghostPink_rom ghostPink_rom(
	.clock   (VGA_CLK),
	.address (ghost_address_P),
	.q       (ghost_qP)
);

ghostBlue_palette ghostBlue_palette (
	.index (ghost_qB),
	.red (ghost_Rb),
	.green (ghost_Gb),
	.blue (ghost_Bb)
);

ghostBlue_rom ghostBlue_rom(
	.clock   (VGA_CLK),
	.address (ghost_address_B),
	.q       (ghost_qB)
);

ghostOrange_palette ghostOrange_palette (
	.index (ghost_qO),
	.red (ghost_Ro),
	.green (ghost_Go),
	.blue (ghost_Bo)
);

ghostOrange_rom ghostOrange_rom(
	.clock   (VGA_CLK),
	.address (ghost_address_O),
	.q       (ghost_qO)
);

endScreen_palette endScreen_palette (
	.index (end_q),
	.red (end_R),
	.green (end_G),
	.blue (end_B)
);

endScreen_rom endScreen_rom(
	.clock   (VGA_CLK),
	.address (end_address),
	.q       (end_q)
);



// ------------------------	Score	--------------------
logic score1_bounds, score2_bounds, score3_bounds, score4_bounds;
assign score1_bounds = 54 < DrawY && DrawY < 71 && 320 < DrawX && DrawX < 329;
assign score2_bounds = 54 < DrawY && DrawY < 71 && 330 < DrawX && DrawX < 339;
assign score3_bounds = 54 < DrawY && DrawY < 71 && 340 < DrawX && DrawX < 349;
assign score4_bounds = 54 < DrawY && DrawY < 71 && 350 < DrawX && DrawX < 359;
	 
logic [3:0] score1_address, score2_address, score3_address, score4_address;
logic [7:0] score1_q, score2_q, score3_q, score4_q;
logic [3:0] score1_R, score1_G, score1_B, score2_R, score2_G, score2_B, score3_R, score3_G, score3_B, score4_R, score4_G, score4_B;
logic [1:0] color_reg [4];
logic [9:0] sprite_x, sprite_y;


logic [7:0] score1_num[16];
logic [7:0] score2_num[16];
logic [7:0] score3_num[16];
logic [7:0] score4_num[16];
int eval1, eval2, eval3;
always_comb
	begin: Score_Index
	
		eval1 = score / 1000;
		case (eval1)
			0: begin
				score1_num = zero;
				end
			1: begin
				score1_num = one;
				end
			2: begin
				score1_num = two;
				end
			3: begin
				score1_num = three;
				end
			4: begin
				score1_num = four;
				end
			5: begin
				score1_num = five;
				end
			6: begin
				score1_num = six;
				end
			7: begin
				score1_num = seven;
				end
			8: begin
				score1_num = eight;
				end
			9: begin
				score1_num = nine;
				end
			default: begin
				score1_num = zero;
			end
		endcase
		
		eval2 = (score / 100) % 10;
		case (eval2)
			0: begin
				score2_num = zero;
				end
			1: begin
				score2_num = one;
				end
			2: begin
				score2_num = two;
				end
			3: begin
				score2_num = three;
				end
			4: begin
				score2_num = four;
				end
			5: begin
				score2_num = five;
				end
			6: begin
				score2_num = six;
				end
			7: begin
				score2_num = seven;
				end
			8: begin
				score2_num = eight;
				end
			9: begin
				score2_num = nine;
				end
			default: begin
				score2_num = zero;
			end
		endcase
		
		eval3 = (score / 10) % 10;
		case (eval3)
			0: begin
				score3_num = zero;
				end
			1: begin
				score3_num = one;
				end
			2: begin
				score3_num = two;
				end
			3: begin
				score3_num = three;
				end
			4: begin
				score3_num = four;
				end
			5: begin
				score3_num = five;
				end
			6: begin
				score3_num = six;
				end
			7: begin
				score3_num = seven;
				end
			8: begin
				score3_num = eight;
				end
			9: begin
				score3_num = nine;
				end
			default: begin
				score3_num = zero;
			end
		endcase
	
	end

always_comb
begin 

	if (score1_num[(DrawY - 54)][8-(DrawX - 320)] && score1_bounds)
		begin
			score1_R = 4'hff;
			score1_G = 4'hff;
			score1_B = 4'hff;
		end
	else
		begin
			score1_R = 4'h0;
			score1_G = 4'h0;
			score1_B = 4'h0;
		end
		
	if (score2_num[(DrawY - 54)][8-(DrawX - 330)] && score2_bounds)
		begin
			score2_R = 4'hff;
			score2_G = 4'hff;
			score2_B = 4'hff;
		end
	else
		begin
			score2_R = 4'h0;
			score2_G = 4'h0;
			score2_B = 4'h0;
		end
	
	if (score3_num[(DrawY - 54)][8-(DrawX - 340)] && score3_bounds)
		begin
			score3_R = 4'hff;
			score3_G = 4'hff;
			score3_B = 4'hff;
		end
	else
		begin
			score3_R = 4'h0;
			score3_G = 4'h0;
			score3_B = 4'h0;
		end
		
	if (zero[(DrawY - 54)][8-(DrawX - 350)] && score4_bounds)
		begin
			score4_R = 4'hff;
			score4_G = 4'hff;
			score4_B = 4'hff;
		end
	else
		begin
			score4_R = 4'h0;
			score4_G = 4'h0;
			score4_B = 4'h0;
		end
end

logic [7:0] zero[16];
logic [7:0] one[16];
logic [7:0] two[16];
logic [7:0] three[16];
logic [7:0] four[16];
logic [7:0] five[16];
logic [7:0] six[16];
logic [7:0] seven[16];
logic [7:0] eight[16];
logic [7:0] nine[16];

always_comb
	begin
		zero[0] = 8'b00000000; 	// 0
		zero[1] = 8'b00000000; 	// 1
		zero[2] = 8'b01111100; 	// 2  *****
		zero[3] = 8'b11000110; 	// 3 **   **
		zero[4] = 8'b11000110; 	// 4 **   **
		zero[5] = 8'b11001110; 	// 5 **  ***
		zero[6] = 8'b11011110; 	// 6 ** ****
		zero[7] = 8'b11110110; 	// 7 **** **
		zero[8] = 8'b11100110; 	// 8 ***  **
		zero[9] = 8'b11000110; 	// 9 **   **
		zero[10] = 8'b11000110; // a **   **
		zero[11] = 8'b01111100; // b  *****
		zero[12] = 8'b00000000; // c
		zero[13] = 8'b00000000; // d
		zero[14] = 8'b00000000; // e
		zero[15] = 8'b00000000; // f
		
      one[0] =  8'b00000000; // 0
		one[1] =  8'b00000000; // 1
		one[2] =  8'b00011000; // 2
		one[3] =  8'b00111000; // 3
		one[4] =  8'b01111000; // 4    **
		one[5] =  8'b00011000; // 5   ***
		one[6] =  8'b00011000; // 6  ****
		one[7] =  8'b00011000; // 7    **
		one[8] =  8'b00011000; // 8    **
		one[9] =  8'b00011000; // 9    **
		one[10] = 8'b00011000; // a    **
		one[11] = 8'b01111110; // b    **
		one[12] = 8'b00000000; // c    **
		one[13] = 8'b00000000; // d  ******
		one[14] = 8'b00000000; // e
		one[15] = 8'b00000000; // f
         
		two[0] =  8'b00000000; // 0
		two[1] =  8'b00000000; // 1
		two[2] =  8'b01111100; // 2  *****
		two[3] =  8'b11000110; // 3 **   **
		two[4] =  8'b00000110; // 4      **
		two[5] =  8'b00001100; // 5     **
		two[6] =  8'b00011000; // 6    **
		two[7] =  8'b00110000; // 7   **
		two[8] =  8'b01100000; // 8  **
		two[9] =  8'b11000000; // 9 **
		two[10] = 8'b11000110; // a **   **
		two[11] = 8'b11111110; // b *******
		two[12] = 8'b00000000; // c
		two[13] = 8'b00000000; // d
		two[14] = 8'b00000000; // e
		two[15] = 8'b00000000; // f
       
		three[0] =  8'b00000000; // 0
		three[1] =  8'b00000000; // 1
		three[2] =  8'b01111100; // 2  *****
		three[3] =  8'b11000110; // 3 **   **
		three[4] =  8'b00000110; // 4      **
		three[5] =  8'b00000110; // 5      **
		three[6] =  8'b00111100; // 6   ****
		three[7] =  8'b00000110; // 7      **
		three[8] =  8'b00000110; // 8      **
		three[9] =  8'b00000110; // 9      **
		three[10] = 8'b11000110; // a **   **
		three[11] = 8'b01111100; // b  *****
		three[12] = 8'b00000000; // c
		three[13] = 8'b00000000; // d
		three[14] = 8'b00000000; // e
		three[15] = 8'b00000000; // f
         
		four[0] =  8'b00000000; // 0
		four[1] =  8'b00000000; // 1
		four[2] =  8'b00001100; // 2     **
		four[3] =  8'b00011100; // 3    ***
		four[4] =  8'b00111100; // 4   ****
		four[5] =  8'b01101100; // 5  ** **
		four[6] =  8'b11001100; // 6 **  **
		four[7] =  8'b11111110; // 7 *******
		four[8] =  8'b00001100; // 8     **
		four[9] =  8'b00001100; // 9     **
		four[10] = 8'b00001100; // a     **
		four[11] = 8'b00011110; // b    ****
		four[12] = 8'b00000000; // c
		four[13] = 8'b00000000; // d
		four[14] = 8'b00000000; // e
		four[15] = 8'b00000000; // f
         // code x35
		five[0] =  8'b00000000; // 0
		five[1] =  8'b00000000; // 1
		five[2] =  8'b11111110; // 2 *******
		five[3] =  8'b11000000; // 3 **
		five[4] =  8'b11000000; // 4 **
		five[5] =  8'b11000000; // 5 **
		five[6] =  8'b11111100; // 6 ******
		five[7] =  8'b00000110; // 7      **
		five[8] =  8'b00000110; // 8      **
		five[9] =  8'b00000110; // 9      **
		five[10] = 8'b11000110; // a **   **
		five[11] = 8'b01111100; // b  *****
		five[12] = 8'b00000000; // c
		five[13] = 8'b00000000; // d
		five[14] = 8'b00000000; // e
		five[15] = 8'b00000000; // f
        
		six[0] =  8'b00000000; // 0
		six[1] =  8'b00000000; // 1
		six[2] =  8'b00111000; // 2   ***
		six[3] =  8'b01100000; // 3  **
		six[4] =  8'b11000000; // 4 **
		six[5] =  8'b11000000; // 5 **
		six[6] =  8'b11111100; // 6 ******
		six[7] =  8'b11000110; // 7 **   **
		six[8] =  8'b11000110; // 8 **   **
		six[9] =  8'b11000110; // 9 **   **
		six[10] = 8'b11000110; // a **   **
		six[11] = 8'b01111100; // b  *****
		six[12] = 8'b00000000; // c
		six[13] = 8'b00000000; // d
		six[14] = 8'b00000000; // e
		six[15] = 8'b00000000; // f
         
		seven[0] =  8'b00000000; // 0
		seven[1] =  8'b00000000; // 1
		seven[2] =  8'b11111110; // 2 *******
		seven[3] =  8'b11000110; // 3 **   **
		seven[4] =  8'b00000110; // 4      **
		seven[5] =  8'b00000110; // 5      **
		seven[6] =  8'b00001100; // 6     **
		seven[7] =  8'b00011000; // 7    **
		seven[8] =  8'b00110000; // 8   **
		seven[9] =  8'b00110000; // 9   **
		seven[10] = 8'b00110000; // a   **
		seven[11] = 8'b00110000; // b   **
		seven[12] = 8'b00000000; // c
		seven[13] = 8'b00000000; // d
		seven[14] = 8'b00000000; // e
		seven[15] = 8'b00000000; // f
        
		eight[0] =  8'b00000000; // 0
		eight[1] =  8'b00000000; // 1
		eight[2] =  8'b01111100; // 2  *****
		eight[3] =  8'b11000110; // 3 **   **
		eight[4] =  8'b11000110; // 4 **   **
		eight[5] =  8'b11000110; // 5 **   **
		eight[6] =  8'b01111100; // 6  *****
		eight[7] =  8'b11000110; // 7 **   **
		eight[8] =  8'b11000110; // 8 **   **
		eight[9] =  8'b11000110; // 9 **   **
		eight[10] = 8'b11000110; // a **   **
		eight[11] = 8'b01111100; // b  *****
		eight[12] = 8'b00000000; // c
		eight[13] = 8'b00000000; // d
		eight[14] = 8'b00000000; // e
		eight[15] = 8'b00000000; // f
    
		nine[0] =  8'b00000000; // 0
		nine[1] =  8'b00000000; // 1
		nine[2] =  8'b01111100; // 2  *****
		nine[3] =  8'b11000110; // 3 **   **
		nine[4] =  8'b11000110; // 4 **   **
		nine[5] =  8'b11000110; // 5 **   **
		nine[6] =  8'b01111110; // 6  ******
		nine[7] =  8'b00000110; // 7      **
		nine[8] =  8'b00000110; // 8      **
		nine[9] =  8'b00000110; // 9      **
		nine[10] = 8'b00001100; // a     **
		nine[11] = 8'b01111000; // b  ****
		nine[12] = 8'b00000000; // c
		nine[13] = 8'b00000000; // d
		nine[14] = 8'b00000000; // e
		nine[15] = 8'b00000000; // f
	end

endmodule
