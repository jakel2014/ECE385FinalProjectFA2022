module FSM(input logic clk,
			  input logic Reset,
			  input logic start_check,
			  input logic start_screen_check,
			  input logic caught_check,
			  input logic game_over_check,
			  output logic [1:0] state);

	 enum int unsigned {
		Intro,
		Start,
		Game,
		End} State, Next_state;
		
	 always_ff @ (posedge Reset or posedge clk )
    begin
		if(Reset) begin
			State <= Intro;
		end
		else begin
			State <= Next_state;
		end
	 end
	 
	 always_comb begin
		Next_state = State;
		
		unique case(State)
			Intro:
				if(start_screen_check) 
					Next_state = Start;
			Start:
				if(start_check)
					Next_state = Game;
			Game: begin
				if(caught_check || game_over_check)
					Next_state = End;
			end
			End: begin
			end
			default: begin
				if(start_check)
					Next_state = Game;
			end
		endcase
		
		case(State)
			Intro: begin
				state = 2'h3;
			end
			Start: begin
				state = 2'h0;
			end
			
			Game: begin
				state = 2'h1;
			end
			
			End: begin
				state = 2'h2;
			end
			
			default: begin
			end
		endcase
		
	 end

endmodule
