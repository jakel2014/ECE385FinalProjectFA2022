module FinalProject1 (

      ///////// Clocks /////////
      input     MAX10_CLK1_50,  //use counter for 50/4

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,


      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 

);




logic Reset_h, vssig, blank, sync, VGA_Clk;


//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST, collision_flag_d, collision_flag_u, collision_flag_r, collision_flag_l;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;
	logic [9:0] drawxsig, drawysig, ballxsig, ballysig, ballsizexsig, ballsizeysig, ballxmotion, ballymotion, ghostxsigR, ghostysigR, ghostsizexsig, ghostsizeysig;
	logic [9:0] ghostxsigP, ghostysigP;
	logic [9:0] ghostxsigB, ghostysigB;
	logic [9:0] ghostxsigO, ghostysigO;
	logic [3:0] Red, Blue, Green;
	logic [7:0] keycode;
	logic [19:0] pellet [21];
	logic i2c_sda_in, i2c_scl_in, i2c_sda_oe, i2c_scl_oe;

//=======================================================
//  Structural coding
//=======================================================
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	//HEX drivers to convert numbers to HEX output
	HexDriver hex_driver4 (hex_num_4, HEX4[6:0]);
	assign HEX4[7] = 1'b1;
	
	HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
	assign HEX3[7] = 1'b1;
	
	HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	HexDriver hex_driver0 (hex_num_0, HEX0[6:0]);
	assign HEX0[7] = 1'b1;
	
	//fill in the hundreds digit as well as the negative sign
	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	
	//Assign one button to reset
	assign {Reset_h}=~ (KEY[0]);

	//Our A/D converter is only 12 bit
	assign VGA_R = Red;
	assign VGA_B = Blue;
	assign VGA_G = Green;
	
	//i2c assignments
	assign ARDUINO_IO[1] = ARDUINO_IO[2];
	
	assign i2c_sda_in = ARDUINO_IO[14];
	assign i2c_scl_in = ARDUINO_IO[15];
	
	assign ARDUINO_IO[15] = i2c_scl_oe ? 1'b0:1'bz;
	assign ARDUINO_IO[14] = i2c_sda_oe ? 1'b0:1'bz;
	
	logic [1:0] sgtl_clk;
	always_ff @(posedge MAX10_CLK1_50) begin
		sgtl_clk <= sgtl_clk+1;
	end
	assign ARDUINO_IO[3] = sgtl_clk[1];
	
	
	//-----------------------	AUDIO	----------------
	logic counter;
	
	always_ff @ (posedge ARDUINO_IO[4]) begin
		counter <= counter + 1;
	end
	
	logic [31:0] audio;
	logic [7:0]  sample;
	logic [13:0] audio_address;
	logic play;
	
	//assign play = start_check;
	
	always_ff @ (posedge ARDUINO_IO[4])
		begin
			if (play == 1 && audio_address ==0)
				audio_address <= 1;
			else if (audio_address != 0)
				begin
					if (audio_address >= 15800)
						begin
							audio_address <= 0;
						end
					else
						audio_address <= audio_address + 1;
				end
		end
		
	pacman_chomp_pcm_rom (
									.clk(counter),
									.addr(audio_address),
									.q(sample)
								);
	
	logic audio_l, audio_r;
	reg_shift audio_left(.clock(ARDUINO_IO[5]),
								.lrclock(ARDUINO_IO[4]),
								.d({8'h00, sample, 16'h0}),
								.shift_out(audio_l)
								);
								
	reg_shift audio_right(.clock(ARDUINO_IO[5]),
								.lrclock(~ARDUINO_IO[4]),
								.d({8'h00, sample, 16'h0}),
								.shift_out(audio_r)
								);
	always_comb
		begin
			if(ARDUINO_IO[4])
				ARDUINO_IO[2] = audio_l;
			else
				ARDUINO_IO[2] = audio_r;
		end
	
	
	FinalProject1_soc u0 (
		.clk_clk                           (MAX10_CLK1_50),  //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
		.key_external_connection_export    (KEY),            //key_external_connection.export

		//SDRAM
		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                             //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
		.sdram_wire_cke(DRAM_CKE),                           //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
		.sdram_wire_dq(DRAM_DQ),                             //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n

		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//have something for i2c
		.i2c_sda_in    (i2c_sda_in),                          //       i2c_serial.sda_in
		.i2c_scl_in    (i2c_scl_in),                          //                 .scl_in
		.i2c_sda_oe    (i2c_sda_oe),                          //                 .sda_oe
		.i2c_scl_oe    (i2c_scl_oe),
		
		//connect Arduino pins (lecture)
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		//LEDs and HEX
		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),
		.leds_export({hundreds, signs, LEDR}),
		.keycode_export(keycode)
		
	 );
	
//State Machine Stuff
logic start_check, caught_check, game_over_check, start_screen_check;
logic [1:0] state;
assign start_check = (keycode == 8'h04) || (keycode == 8'h07) || (keycode == 8'h16) || (keycode == 8'h1A);
assign start_screen_check = (keycode == 8'h28);
	 
FSM f(.clk(VGA_VS), .Reset(Reset_h), .start_check(start_check), .caught_check(caught_check), .state(state), .game_over_check(game_over_check),
		.start_screen_check(start_screen_check));

int score;
	 
	 
//instantiate a vga_controller, ball, and color_mapper here with the ports.
vga_controller v(.Clk(MAX10_CLK1_50), .Reset(Reset_h), .hs(VGA_HS), .vs(VGA_VS), .pixel_clk(VGA_Clk), 
					 .blank(blank), .sync(sync), .DrawX(drawxsig), .DrawY(drawysig));
			
ball b(.Reset(Reset_h), .frame_clk(VGA_VS), 
					.keycode(keycode), .BallX(ballxsig), .BallY(ballysig), .BallSX(ballsizexsig), .BallSY(ballsizeysig),
					.pellet(pellet), .GhostXR(ghostxsigR), .GhostYR(ghostysigR), .GhostSX(ghostsizexsig), .GhostSY(ghostsizeysig),
					.state(state), .caught_check(caught_check), .score(score), .game_over_check(game_over_check),
					.GhostXP(ghostxsigP), .GhostYP(ghostysigP), .GhostXB(ghostxsigB), .GhostYB(ghostysigB),
					.GhostXO(ghostxsigO), .GhostYO(ghostysigO), .play(play));			

color_mapper m(.BallX(ballxsig), .BallY(ballysig), .DrawX(drawxsig), .DrawY(drawysig), 
                .Red(Red), .Green(Green), .Blue(Blue), .VGA_CLK(VGA_Clk), .blank(blank),
					 .Ball_Size_X(ballsizexsig), .Ball_Size_Y(ballsizeysig), .keycode(keycode), .pellet(pellet),
					 .GhostXR(ghostxsigR), .GhostYR(ghostysigR), .Ghost_Size_X(ghostsizexsig), .Ghost_Size_Y(ghostsizeysig),
					 .score(score), .state(state), .GhostXP(ghostxsigP), .GhostYP(ghostysigP), .GhostXB(ghostxsigB), .GhostYB(ghostysigB),
					 .GhostXO(ghostxsigO), .GhostYO(ghostysigO));

endmodule