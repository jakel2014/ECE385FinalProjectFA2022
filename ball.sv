//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball ( input Reset, frame_clk,
					input [7:0] keycode,
					input [1:0] state,
               output [9:0]  BallX, BallY, BallSX, BallSY,
					output [9:0] GhostXR, GhostYR, GhostSX, GhostSY, GhostXP, GhostYP, GhostXO, GhostYO,
					output [19:0] pellet [21],
					output logic caught_check,
					output logic game_over_check,
					output int score,
					output [9:0] GhostXB, GhostYB,
					output logic play);
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, Ball_Size_X, Ball_Size_Y;
	 logic [9:0] Ghost_X_Pos_R, Ghost_Y_Pos_R, Ghost_Size_X, Ghost_Size_Y;
	 logic [9:0] Ghost_X_Pos_P, Ghost_Y_Pos_P;
	 logic [9:0] Ghost_X_Pos_B, Ghost_Y_Pos_B;
	 logic [9:0] Ghost_X_Pos_O, Ghost_Y_Pos_O;
	 logic caught_check_r, caught_check_p, caught_check_b, caught_check_o;
	 
    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=255;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis

    //assign Ball_Size_X = 12;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
	 assign Ball_Size_X = 8;
	 assign Ball_Size_Y = 8;
	 
//	 logic [4:0] map_file_rom_addr;
//	 logic [18:0] map_bits, map_bits_up, map_bits_down;
	 logic map_check_u;
	 logic map_check_d;
	 logic map_check_l;
	 logic map_check_r;
	 
	 logic map_check_ul, map_check_ur;
	 logic map_check_bl, map_check_br;
	 logic map_check_ru, map_check_rb;
	 logic map_check_lu, map_check_lb;
//	 
//	 assign map_file_rom_addr = Ball_Y_Pos/23;
//	 map_file_rom mfr(.map_file_ADDR(map_file_rom_addr), .map_bits(map_bits));
//	 map_file_rom mfr_u(.map_file_ADDR(map_file_rom_addr - 1), .map_bits(map_bits_up));
//	 map_file_rom mfr_d(.map_file_ADDR(map_file_rom_addr + 1), .map_bits(map_bits_down));
//	 
//	 assign map_check_u = ~map_bits_up[(Ball_X_Pos)/34];
//	 assign map_check_d = ~map_bits_down[(Ball_X_Pos)/34];
//	 assign map_check_l = ~map_bits[(Ball_X_Pos - 14 - 1)/34];
//	 assign map_check_r = ~map_bits[(Ball_X_Pos + 14 + 1)/34];

	logic [19:0] grid_wall [21];
	logic [19:0] grid_pellet [21];
	assign pellet = grid_pellet;
 
	 always_comb begin
		grid_wall[0] =  19'b1111111111111111111;
		grid_wall[1] =  19'b1000000001000000001;
		grid_wall[2] =  19'b1011011101011101101;
		grid_wall[3] =  19'b1000000000000000001;
		grid_wall[4] =  19'b1011010111110101101;
		grid_wall[5] =  19'b1000010001000100001;
		grid_wall[6] =  19'b1111011101011101111;
		grid_wall[7] =  19'b0001010000000101000;
		grid_wall[8] =  19'b1111010111110101111;
		grid_wall[9] =  19'b1000000100010000001;
		grid_wall[10] = 19'b1111010111110101111;
		grid_wall[11] = 19'b0001010000000101000;
		grid_wall[12] = 19'b1111010111110101111;
		grid_wall[13] = 19'b1000000001000000001;
		grid_wall[14] = 19'b1011011101011101101;
		grid_wall[15] = 19'b1001000000000001001;
		grid_wall[16] = 19'b1101010111110101011;
		grid_wall[17] = 19'b1000010001000100001;
		grid_wall[18] = 19'b1011111101011111101;
		grid_wall[19] = 19'b1000000000000000001;
		grid_wall[20] = 19'b1111111111111111111;
		
		map_check_u = grid_wall[(Ball_Y_Pos - 72 - 1 - Ball_Size_Y) / 16][(Ball_X_Pos - 168) / 16];
		map_check_d = grid_wall[(Ball_Y_Pos - 72 + 1 + Ball_Size_Y) / 16][(Ball_X_Pos - 168) / 16];
		map_check_l = grid_wall[(Ball_Y_Pos - 72) / 16][(Ball_X_Pos - 168 - 1 - Ball_Size_X) / 16];
		map_check_r = grid_wall[(Ball_Y_Pos - 72) / 16][(Ball_X_Pos - 168 + 1 + Ball_Size_X) / 16];
		
		map_check_ul = grid_wall[(Ball_Y_Pos - 72 - 1 - Ball_Size_Y) / 16][(Ball_X_Pos - 168 - 6) / 16];
		map_check_ur = grid_wall[(Ball_Y_Pos - 72 - 1 - Ball_Size_Y) / 16][(Ball_X_Pos - 168 + 6) / 16];
		map_check_bl = grid_wall[(Ball_Y_Pos - 72 + 1 + Ball_Size_Y) / 16][(Ball_X_Pos - 168 - 6) / 16];
		map_check_br = grid_wall[(Ball_Y_Pos - 72 + 1 + Ball_Size_Y) / 16][(Ball_X_Pos - 168 + 6) / 16];
		
		map_check_ru = grid_wall[(Ball_Y_Pos - 72 - 5) / 16][(Ball_X_Pos - 168 + 1 + Ball_Size_X) / 16];
		map_check_rb = grid_wall[(Ball_Y_Pos - 72 + 5) / 16][(Ball_X_Pos - 168 + 1 + Ball_Size_X) / 16];
		map_check_lu = grid_wall[(Ball_Y_Pos - 72 - 5) / 16][(Ball_X_Pos - 168 - 1 - Ball_Size_X) / 16];
		map_check_lb = grid_wall[(Ball_Y_Pos - 72 + 5) / 16][(Ball_X_Pos - 168 - 1 - Ball_Size_X) / 16];
	
	 end
	 
	 always_ff @ (posedge Reset or posedge frame_clk )
	 begin: Pellet_Grid
	  if (Reset)
	  begin
			grid_pellet[0] =  19'b0000000000000000000;
			grid_pellet[1] =  19'b0111111110111111110;
			grid_pellet[2] =  19'b0100100010100010010;
			grid_pellet[3] =  19'b0111111111111111110;
			grid_pellet[4] =  19'b0100101000001010010;
			grid_pellet[5] =  19'b0111101110111011110;
			grid_pellet[6] =  19'b0000100000000010000;
			grid_pellet[7] =  19'b0000100000000010000;
			grid_pellet[8] =  19'b0000100000000010000;
			grid_pellet[9] =  19'b0000100000000010000;
			grid_pellet[10] = 19'b0000100000000010000;
			grid_pellet[11] = 19'b0000100000000010000;
			grid_pellet[12] = 19'b0000100000000010000;
			grid_pellet[13] = 19'b0111111110111111110;
			grid_pellet[14] = 19'b0100100010100010010;
			grid_pellet[15] = 19'b0110111110111110110;
			grid_pellet[16] = 19'b0010101000001010100;
			grid_pellet[17] = 19'b0111101110111011110;
			grid_pellet[18] = 19'b0100000010100000010;
			grid_pellet[19] = 19'b0111111111111111110;
			grid_pellet[20] = 19'b0000000000000000000;
			
			score <= 0;
	  end
	  else if (grid_pellet[(Ball_Y_Pos - 72)/16][(Ball_X_Pos - 168)/16] == 1) begin
                score <= score + 10;
                grid_pellet[(Ball_Y_Pos - 72)/16][(Ball_X_Pos - 168)/16] = 0;
					 play <= 1;
     end
	  else begin
			score <= score;
			play <= 0;
	  end
	 end
	 
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ball
        if (Reset)  // Asynchronous Reset
        begin 
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
				Ball_Y_Pos <= Ball_Y_Center;
				Ball_X_Pos <= Ball_X_Center;
        end
		  
        else if(state == 2'h2 || state == 2'h3) begin
				Ball_X_Motion <= 10'd0;
				Ball_Y_Motion <= 10'd0;
		  end
		  
		  else if(state == 2'h1)begin 
			  case (keycode)
					8'h04 : begin
								if((Ball_X_Pos - Ball_Size_X) > Ball_X_Min && (~map_check_l && ~map_check_lu && ~map_check_lb)) begin
									Ball_X_Motion <= -1;//A
									Ball_Y_Motion<= 0;
									Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position
									Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
								end
							  end
							  
					8'h07 : begin
								if((Ball_X_Pos + Ball_Size_X) < Ball_X_Max && (~map_check_ru && ~map_check_rb && ~map_check_r)) begin
									Ball_X_Motion <= 1;//D
									Ball_Y_Motion <= 0;
									Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position
									Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
								end
							  end

							  
					8'h16 : begin
								if((Ball_Y_Pos + Ball_Size_Y) < Ball_Y_Max && (~map_check_bl && ~map_check_br)) begin
									Ball_Y_Motion <= 1;//S
									Ball_X_Motion <= 0;
									Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position
									Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
								end
							  
							 end
							  
					8'h1A : begin
								if((Ball_Y_Pos - Ball_Size_Y > Ball_Y_Min) && (~map_check_ul && ~map_check_ur)) begin
									Ball_Y_Motion <= -1;//W
									Ball_X_Motion <= 0;
									Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position
									Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
								end
							 end	  
					default: ;
				endcase

		  end
		  else begin
		  end
			
	  /**************************************************************************************
	    ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
		 Hidden Question #2/2:
          Note that Ball_Y_Motion in the above statement may have been changed at the same clock edge
          that is causing the assignment of Ball_Y_pos.  Will the new value of Ball_Y_Motion be used,
          or the old?  How will this impact behavior of the ball during a bounce, and how might that 
          interact with a response to a keypress?  Can you fix it?  Give an answer in your Post-Lab.
      **************************************************************************************/
        
    end
       
    assign BallX = Ball_X_Pos;
    assign BallY = Ball_Y_Pos;
    assign BallSX = Ball_Size_X;
	 assign BallSY = Ball_Size_Y;
	 
	 assign GhostXR = Ghost_X_Pos_R;
	 assign GhostYR = Ghost_Y_Pos_R;
	 assign GhostXP = Ghost_X_Pos_P;
	 assign GhostYP = Ghost_Y_Pos_P;
	 assign GhostXB = Ghost_X_Pos_B;
	 assign GhostYB = Ghost_Y_Pos_B;
	 assign GhostXO = Ghost_X_Pos_O;
	 assign GhostYO = Ghost_Y_Pos_O;
	 assign GhostSX = 8;
	 assign GhostSY = 8;
	 
	 assign game_over_check = (score == 1500);
	 assign caught_check = caught_check_r || caught_check_p || caught_check_b || caught_check_o;
	 
	 ghost r(.Reset(Reset), .frame_clk(frame_clk), .GhostX(Ghost_X_Pos_R), .GhostY(Ghost_Y_Pos_R),
				.wall(grid_wall), .keycode(keycode), .Pac_X_Pos(Ball_X_Pos), .Pac_Y_Pos(Ball_Y_Pos),
				.state(state), .caught_check(caught_check_r), .Pac_Size_X(Ball_Size_X), .Pac_Size_Y(Ball_Size_Y),
				.ghost_num(2'h0), .start_direction(3'h1), .patrol(1));
				
	 ghost p(.Reset(Reset), .frame_clk(frame_clk), .GhostX(Ghost_X_Pos_P), .GhostY(Ghost_Y_Pos_P), 
				.wall(grid_wall), .keycode(keycode), .Pac_X_Pos(Ball_X_Pos), .Pac_Y_Pos(Ball_Y_Pos), 
				.state(state), .caught_check(caught_check_p), .Pac_Size_X(Ball_Size_X), .Pac_Size_Y(Ball_Size_Y), 
				.ghost_num(2'h1), .start_direction(3'h0), .patrol(0));
				
	 ghost b(.Reset(Reset), .frame_clk(frame_clk), .GhostX(Ghost_X_Pos_B), .GhostY(Ghost_Y_Pos_B), 
				.wall(grid_wall), .keycode(keycode), .Pac_X_Pos(Ball_X_Pos), .Pac_Y_Pos(Ball_Y_Pos), 
				.state(state), .caught_check(caught_check_b), .Pac_Size_X(Ball_Size_X), .Pac_Size_Y(Ball_Size_Y), 
				.ghost_num(2'h2), .start_direction(3'h1), .patrol(0));
	
	 ghost o(.Reset(Reset), .frame_clk(frame_clk), .GhostX(Ghost_X_Pos_O), .GhostY(Ghost_Y_Pos_O), 
				.wall(grid_wall), .keycode(keycode), .Pac_X_Pos(Ball_X_Pos), .Pac_Y_Pos(Ball_Y_Pos), 
				.state(state), .caught_check(caught_check_o), .Pac_Size_X(Ball_Size_X), .Pac_Size_Y(Ball_Size_Y), 
				.ghost_num(2'h3), .start_direction(3'h0), .patrol(1));
    

endmodule
