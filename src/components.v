`default_nettype none
`include "intan.vh"


/*********************************************************************************
	Author: Manuel Monge
	Description:
		Demo FSM to send a cte data via SPI and check if the received data is as expected.
*********************************************************************************/

module regbank_controller (
	input  wire	rstb,						// Active-low asyncrhonous reset
	input  wire	clk,						// Input clock
	input  wire	spi_sc_done,				// Active-high Input; indicates SPI communication with REG is done
	output reg	regbank_wen				// Active-high Output; FIFO read-enable
);
	
	// state
	localparam idle = 3'd0;
	localparam op0a = 3'd1; // Start SPI-Frame
	localparam op0b = 3'd2; // Wait until SPI-Frame is done
	localparam op0c = 3'd3; // Increase counter. Done with configuration?
	localparam op1a = 3'd4; // Start SPI-Frame
	localparam op1b = 3'd5; // Wait until SPI-Frame is done
	localparam op1c = 3'd6; // Increase counter

	reg [2:0] current_state,next_state;
	wire redge_spi_sc_done;
	reg spi_sc_done_reg;
	
	
	// Detect rising-edge of spi_sc_done
	always@(negedge rstb or posedge clk)
		if (!rstb)
			spi_sc_done_reg <= 0;
		else
			spi_sc_done_reg <= spi_sc_done;
			
	assign redge_spi_sc_done = (~spi_sc_done_reg) && (spi_sc_done);
	
	// FSM
	
	// state register
	always@(negedge rstb or posedge clk)
		if (!rstb)
			current_state <= idle;
		else
			current_state <= next_state;
	
	// next_state logic
	always@(*) begin
		// default values
		regbank_wen = 1'b0;
		
		case (current_state)
			idle: begin
				next_state = op0a;
			end
			
			// FIFO reading
			op0a: begin
				if (redge_spi_sc_done)
					next_state = op0b;
				else
					next_state = op0a;
			end
			op0b: begin
				regbank_wen = 1'b1;
				next_state = op0a;
			end
			
			// Other States
			default: begin
				next_state = idle;
			end
		endcase
	end
	
endmodule


/*********************************************************************************
	Author: Manuel Monge
	Description:
		Demo FSM to send a cte data via SPI and check if the received data is as expected.
*********************************************************************************/

module main_controller (
	input  wire	rstb,						// Active-low asyncrhonous reset
	input  wire	clk,						// Input clock
	input  wire	fifo_empty,					// Active-high Input; indicates if FIFO is empty
	output reg	fifo_ren,					// Active-high Output; FIFO read-enable
	input  wire	mcu_done					// Active-high Input; indicates SPI communication with MCU is done
);
	
	// state
	localparam idle = 3'd0;
	localparam op0a = 3'd1; // Start SPI-Frame
	localparam op0b = 3'd2; // Wait until SPI-Frame is done
	localparam op0c = 3'd3; // Increase counter. Done with configuration?
	localparam op1a = 3'd4; // Start SPI-Frame
	localparam op1b = 3'd5; // Wait until SPI-Frame is done
	localparam op1c = 3'd6; // Increase counter

	reg [2:0] current_state,next_state;
	wire redge_mcu_done;
	reg mcu_done_reg;
	
	
	// Detect rising-edge of mcu_done
	always@(negedge rstb or posedge clk)
		if (!rstb)
			mcu_done_reg <= 0;
		else
			mcu_done_reg <= mcu_done;
			
	assign redge_mcu_done = (~mcu_done_reg) && (mcu_done);
	
	// FSM
	
	// state register
	always@(negedge rstb or posedge clk)
		if (!rstb)
			current_state <= idle;
		else
			current_state <= next_state;
	
	// next_state logic
	always@(*) begin
		// default values
		fifo_ren = 1'b0;
		
		case (current_state)
			idle: begin
				next_state = op0a;
			end
			
			// FIFO reading
			op0a: begin
				if (redge_mcu_done)
					next_state = op0b;
				else
					next_state = op0a;
			end
			op0b: begin
				if (!fifo_empty)
					fifo_ren = 1'b1;
				else
					fifo_ren = 1'b0;
				next_state = op0a;
			end
			
			// Other States
			default: begin
				next_state = idle;
			end
		endcase
	end
	
endmodule




/*********************************************************************************
	Author: Manuel Monge
	Description:
		Demo FSM to send a cte data via SPI and check if the received data is as expected.
	Inputs:
		rstb: Active-low asyncrhonous reset.
		clk:  Input clock.
		?data: n-bit Input signal.
	Outputs:
		?a:    serial output.
*********************************************************************************/

module ch_sel #(
	parameter n = 16
	)(
	input  wire	rstb,					// Active-low asyncrhonous reset
	input  wire	clk,					// Input clock
	input  wire [5:0]	ch_cnt,			// Input; channel count
	input  wire [n-1:0]	data_a0,		// Input; 16-bit data coming from RHD2164-0 output a
	input  wire [n-1:0]	data_b0,		// Input; 16-bit data coming from RHD2164-0 output b
	input  wire [n-1:0]	data_a1,		// Input; 16-bit data coming from RHD2164-1 output a
	input  wire [n-1:0]	data_b1,		// Input; 16-bit data coming from RHD2164-1 output b
	output wire	[n-1:0]	dout,			// Output Data
	// Channel Config
	input  wire	[7:0]	mode0_ch_a,
	// TX FIFO
	input  wire	dtx_sel,				// Input: indicates Sampling mode when '1'
	output reg	fifo_wen				// Output; FIFO write enable
);
	
	// wire & regs
	reg [n-1:0] data0;
	wire ch_is_mode0_ch_a, ch_is_redge;
	reg ch_is_mode0_ch_a_reg, ch_is_mode0_ch_a_reg2;
	
	// Comparator
	assign ch_is_mode0_ch_a = (ch_cnt == mode0_ch_a[5:0]);

	// Rising edge detector sets 'fifo_wen'
	assign ch_is_redge = (ch_is_mode0_ch_a_reg) & (~ch_is_mode0_ch_a_reg2);

	always@(negedge rstb or posedge clk)
		if (!rstb) begin
			ch_is_mode0_ch_a_reg <= 0;
			ch_is_mode0_ch_a_reg2 <= 0;
			fifo_wen <= 0;
		end
		else if (dtx_sel) begin
			ch_is_mode0_ch_a_reg <= ch_is_mode0_ch_a;
			ch_is_mode0_ch_a_reg2 <= ch_is_mode0_ch_a_reg;
			fifo_wen <= ch_is_redge;
		end


	// channel selection
	always@(negedge rstb or posedge clk)
		if (!rstb)
			data0 <= 0;
		else if ( (dtx_sel) && (ch_is_redge) )
			case (mode0_ch_a[7:6])
				2'd0: data0 <= data_a0;
				2'd1: data0 <= data_b0;
				2'd2: data0 <= data_a1;
				2'd3: data0 <= data_b1;
				default: data0 <= 0;
			endcase

	
	assign dout = data0;
		
endmodule



/*********************************************************************************
	Author: Manuel Monge
	Description:
		Demo FSM to send a cte data via SPI and check if the received data is as expected.
	Inputs:
		rstb: Active-low asyncrhonous reset.
		clk:  Input clock.
		?data: n-bit Input signal.
	Outputs:
		?a:    serial output.
*********************************************************************************/

module ram #(
	parameter DATA_WIDTH = 16,
	parameter ADDR_WIDTH = 6
	)(
	input  wire	rstb,					// Active-low asyncrhonous reset
	input  wire	clk,					// Input clock
	input  wire	wen,						// Input; RegBank write enable
	input  wire	[ADDR_WIDTH-1:0] addr0,	// Input Address, Port0
	input  wire [DATA_WIDTH-1:0] din0,	// Input Data, Port0
	output reg	[DATA_WIDTH-1:0] dout0,	// Output Data, Port0
	input  wire	[ADDR_WIDTH-1:0] addr1,	// Input Address, Port0
	output reg	[DATA_WIDTH-1:0] dout1,	// Output Data, Port0
	// Config connections
	output wire	[15:0]	rhd2164_sampling_cmd0,
	output wire	[15:0]	rhd2164_sampling_cmd1,
	output wire	[15:0]	rhd2164_sampling_cmd2,
	output wire	[7:0]	mode0_ch_a
);
	
	// memory
	reg [DATA_WIDTH-1:0] ram [0:(2**2)-1];

	// Config connections
	assign rhd2164_sampling_cmd0 = ram[2'd0];
	assign rhd2164_sampling_cmd1 = ram[2'd1];
	assign rhd2164_sampling_cmd2 = ram[2'd2];
	
	assign mode0_ch_a = ram[2'd3][7:0];
	
	
	// Writing
	always@(negedge rstb or posedge clk)
		if (!rstb) begin
			ram[2'd0] <= `RHD_READ(6'd63);	// RHD2164 Sampling: cmd0
			ram[2'd1] <= `RHD_READ(6'd63);	// RHD2164 Sampling: cmd1
			ram[2'd2] <= `RHD_READ(6'd63);	// RHD2164 Sampling: cmd2
			ram[2'd3] <= 16'h0100;	// Mode 0: Full BW channels: {ch_b[7:0],ch_a[7:0]}. Default: Ch1, Ch0
		end
		else if (wen)
			ram[addr0[1:0]] <= din0;
		
	// Reading
	always@(negedge rstb or posedge clk)
		if (!rstb) begin
			dout0 <= 0;
			dout1 <= 0;
		end
		else begin
			dout0 <= ram[addr0[1:0]];
			dout1 <= ram[addr1[1:0]];
		end
		
endmodule




/*********************************************************************************
	Author: Manuel Monge
	Description:
		Demo FSM to send a cte data via SPI and check if the received data is as expected.
	Inputs:
		rstb: Active-low asyncrhonous reset.
		clk:  Input clock.
		?data: n-bit Input signal.
	Outputs:
		?a:    serial output.
*********************************************************************************/

module fifo #(
	parameter DATA_WIDTH = 16,
	parameter ADDR_WIDTH = 16
	)(
	input  wire	rstb,					// Active-low asyncrhonous reset
	input  wire	clk,					// Input clock
	input  wire wen,						// Input; FIFO write enable
	input  wire ren,						// Input; FIFO read enable
	input  wire [DATA_WIDTH-1:0]	DIN,	// Input Data
	output reg	[DATA_WIDTH-1:0] DOUT,	// Output Data
	output wire	empty,					// Output flag indicating empty FIFO
	output wire	full					// Output flag indicating full FIFO
);
	
	// memory
	reg [DATA_WIDTH-1:0] fifo_ram [0:(2**ADDR_WIDTH)-1];

	// wire & regs
	reg [ADDR_WIDTH:0] in_ptr, out_ptr; // PTRs with additional bit as flag
	
	// Writing
	always@(negedge rstb or posedge clk)
		if (!rstb)
			in_ptr <= 0;
		else if (wen && !full) begin
			fifo_ram[in_ptr[ADDR_WIDTH-1:0]] <= DIN;
			in_ptr <= in_ptr + 1'b1;
		end
		
	// Reading
	always@(negedge rstb or posedge clk)
		if (!rstb) begin
			out_ptr <= 0;
			DOUT <= 0;
		end
		else if (ren && !empty) begin
			out_ptr <= out_ptr + 1'b1;
			DOUT <= fifo_ram[out_ptr[ADDR_WIDTH-1:0]];
		end
	
		
	// Status Flags
	assign empty = (in_ptr == out_ptr) ? 1:0; // both pointers are the same
	assign full = ((in_ptr[ADDR_WIDTH-1:0] == out_ptr[ADDR_WIDTH-1:0]) & (in_ptr[ADDR_WIDTH] != out_ptr[ADDR_WIDTH])) ? 1:0; // pointers have the same [ADDR_WIDTH-1:0] value but the MSBs are different
	
endmodule



/*********************************************************************************
	Author: Manuel Monge
	Description:
		Demo FSM to send a cte data via SPI and check if the received data is as expected.
	Inputs:
		rstb: Active-low asyncrhonous reset.
		clk:  Input clock.
		?data: n-bit Input signal.
	Outputs:
		?a:    serial output.
*********************************************************************************/

module rhd2164_controller (
	input  wire	rstb,						// Active-low asyncrhonous reset
	input  wire	clk,						// Input clock
	output reg	rhd_start,					// Active-high output that starts RHD2164x2 SPI cycle
	input  wire rhd_done,					// Active-high input that indicates SPI cycle has finished
	output reg	rhd_dtx_sel,				// Output selector to the data_sel mux
	output wire	[5:0]	rhd_addr_cfg,		// Output controlling the address of RHD2164_CFG_ROM which contains instructions for the RHD2164 configuration
	output wire	[5:0]	rhd_addr_sampling	// Output controlling the address of RHD2164_SAMPLING_ROM which contains instructions for the RHD2164 operation
);
	
	// state
	localparam idle = 3'd0;
	localparam op0a = 3'd1; // Start SPI-Frame
	localparam op0b = 3'd2; // Wait until SPI-Frame is done
	localparam op0c = 3'd3; // Increase counter. Done with configuration?
	localparam op1a = 3'd4; // Start SPI-Frame
	localparam op1b = 3'd5; // Wait until SPI-Frame is done
	localparam op1c = 3'd6; // Increase counter

	reg [2:0] current_state,next_state;
	
	// wire & regs
	reg [5:0] cnt0,cnt1;
	localparam cfg_max = 6'd33;
	localparam sampling_max = 6'd34;
	reg cnt0_en,cnt1_en;
	wire cnt0_is_max,cnt1_is_max;
	
	
	// 6-bit cfg-counter
	always@(negedge rstb or posedge clk)
		if (!rstb)
			cnt0 <= 0;
		else if (cnt0_en)
			if (cnt0_is_max)
				cnt0 <= 0;
			else
				cnt0 <= cnt0 + 1'b1;
	
	// comparator to max
	assign cnt0_is_max = (cnt0 == cfg_max) ? 1:0;
	
	assign rhd_addr_cfg = cnt0;
	
	// 6-bit sampling-counter
	always@(negedge rstb or posedge clk)
		if (!rstb)
			cnt1 <= 0;
		else if (cnt1_en)
			if (cnt1_is_max)
				cnt1 <= 0;
			else
				cnt1 <= cnt1 + 1'b1;
	
	// comparator to max
	assign cnt1_is_max = (cnt1 == sampling_max) ? 1:0;
	
	assign rhd_addr_sampling = cnt1;


	//FSM
	
	// state register
	always@(negedge rstb or posedge clk)
		if (!rstb)
			current_state <= idle;
		else
			current_state <= next_state;
	
	// next_state logic
	always@(current_state or rhd_done or cnt0_is_max) begin
		// default values
		cnt0_en = 1'b0;
		cnt1_en = 1'b0;
		rhd_start = 1'b0;
		rhd_dtx_sel = 1'b0;
		
		case (current_state)
			idle: begin
				next_state = op0a;
			end
			
			// RHD2164 Configuration
			op0a: begin
				next_state = op0b;
				rhd_start = 1'b1;
			end
			op0b: begin
				if (rhd_done)
					next_state = op0c;
				else
					next_state = op0b;
			end
			op0c: begin
				if (cnt0_is_max)
					next_state = op1a;
				else
					next_state = op0a;
				cnt0_en = 1'b1;
			end
			
			// RHD2164 Sampling Cycle
			op1a: begin
				next_state = op1b;
				rhd_start = 1'b1;
				rhd_dtx_sel = 1'b1;
			end
			op1b: begin
				if (rhd_done)
					next_state = op1c;
				else
					next_state = op1b;
				rhd_dtx_sel = 1'b1;
			end
			op1c: begin
				next_state = op1a;
				cnt1_en = 1'b1;
				rhd_dtx_sel = 1'b1;
			end
			
			// Other States
			default: begin
				next_state = idle;
			end
		endcase
	end
	
endmodule




/*********************************************************************************
	Author: Manuel Monge
	Description:
		Demo FSM to send a cte data via SPI and check if the received data is as expected.
	Inputs:
		rstb: Active-low asyncrhonous reset.
		clk:  Input clock.
		?data: n-bit Input signal.
	Outputs:
		?a:    serial output.
*********************************************************************************/

module rhd2164_cfg_rom (
	input  wire	[5:0]	addr,
	output reg	[15:0]	data
);
	
	// commands
	// `define RHD_READ(REGISTER) {RHD_READ_CODE,REGISTER,8'd0}
	// `define RHD_WRITE(REGISTER, DATA) {RHD_WRITE_CODE,REGISTER,DATA}
	
	// ROM
	always@(addr) begin		
		case (addr)
			6'd0: data <= `RHD_READ(6'd63);
			6'd1: data <= `RHD_READ(6'd63);
			6'd2: data <= `RHD_WRITE(6'd0, `RHD_REG0);
			6'd3: data <= `RHD_WRITE(6'd1, `RHD_REG1);
			6'd4: data <= `RHD_WRITE(6'd2, `RHD_REG2);
			6'd5: data <= `RHD_WRITE(6'd3, `RHD_REG3);
			6'd6: data <= `RHD_WRITE(6'd4, `RHD_REG4);
			6'd7: data <= `RHD_WRITE(6'd5, `RHD_REG5);
			6'd8: data <= `RHD_WRITE(6'd6, `RHD_REG6);
			6'd9: data <= `RHD_WRITE(6'd7, `RHD_REG7);
			6'd10: data <= `RHD_WRITE(6'd8, `RHD_REG8);
			6'd11: data <= `RHD_WRITE(6'd9, `RHD_REG9);
			6'd12: data <= `RHD_WRITE(6'd10, `RHD_REG10);
			6'd13: data <= `RHD_WRITE(6'd11, `RHD_REG11);
			6'd14: data <= `RHD_WRITE(6'd12, `RHD_REG12);
			6'd15: data <= `RHD_WRITE(6'd13, `RHD_REG13);
			6'd16: data <= `RHD_WRITE(6'd14, `RHD_REG14);
			6'd17: data <= `RHD_WRITE(6'd15, `RHD_REG15);
			6'd18: data <= `RHD_WRITE(6'd16, `RHD_REG16);
			6'd19: data <= `RHD_WRITE(6'd17, `RHD_REG17);
			6'd20: data <= `RHD_WRITE(6'd18, `RHD_REG18);
			6'd21: data <= `RHD_WRITE(6'd19, `RHD_REG19);
			6'd22: data <= `RHD_WRITE(6'd20, `RHD_REG20);
			6'd23: data <= `RHD_WRITE(6'd21, `RHD_REG21);
			6'd24: data <= `RHD_CALIBRATE;
			6'd25: data <= `RHD_READ(6'd63);
			6'd26: data <= `RHD_READ(6'd63);
			6'd27: data <= `RHD_READ(6'd63);
			6'd28: data <= `RHD_READ(6'd63);
			6'd29: data <= `RHD_READ(6'd63);
			6'd30: data <= `RHD_READ(6'd63);
			6'd31: data <= `RHD_READ(6'd63);
			6'd32: data <= `RHD_READ(6'd63);
			6'd33: data <= `RHD_READ(6'd63);
			default: data <= `RHD_READ(6'd63);
		endcase
	end
	
endmodule


/*********************************************************************************
	Author: Manuel Monge
	Description:
		Demo FSM to send a cte data via SPI and check if the received data is as expected.
	Inputs:
		rstb: Active-low asyncrhonous reset.
		clk:  Input clock.
		?data: n-bit Input signal.
	Outputs:
		?a:    serial output.
*********************************************************************************/

module rhd2164_sampling_rom (
	input  wire	[5:0]	addr,
	output reg	[15:0]	data,
	input  wire	[15:0]	cmd0,
	input  wire	[15:0]	cmd1,
	input  wire	[15:0]	cmd2
);
	
	// commands
	// `define RHD_READ(REGISTER) {RHD_READ_CODE,REGISTER,8'd0}
	// `define RHD_WRITE(REGISTER, DATA) {RHD_WRITE_CODE,REGISTER,DATA}
	
	// ROM
	always@(*) begin
		case (addr)
			6'd0: data <= `RHD_CONVERT(6'd0);
			6'd1: data <= `RHD_CONVERT(6'd63);
			6'd2: data <= `RHD_CONVERT(6'd63);
			6'd3: data <= `RHD_CONVERT(6'd63);
			6'd4: data <= `RHD_CONVERT(6'd63);
			6'd5: data <= `RHD_CONVERT(6'd63);
			6'd6: data <= `RHD_CONVERT(6'd63);
			6'd7: data <= `RHD_CONVERT(6'd63);
			6'd8: data <= `RHD_CONVERT(6'd63);
			6'd9: data <= `RHD_CONVERT(6'd63);
			6'd10: data <= `RHD_CONVERT(6'd63);
			6'd11: data <= `RHD_CONVERT(6'd63);
			6'd12: data <= `RHD_CONVERT(6'd63);
			6'd13: data <= `RHD_CONVERT(6'd63);
			6'd14: data <= `RHD_CONVERT(6'd63);
			6'd15: data <= `RHD_CONVERT(6'd63);
			6'd16: data <= `RHD_CONVERT(6'd63);
			6'd17: data <= `RHD_CONVERT(6'd63);
			6'd18: data <= `RHD_CONVERT(6'd63);
			6'd19: data <= `RHD_CONVERT(6'd63);
			6'd20: data <= `RHD_CONVERT(6'd63);
			6'd21: data <= `RHD_CONVERT(6'd63);
			6'd22: data <= `RHD_CONVERT(6'd63);
			6'd23: data <= `RHD_CONVERT(6'd63);
			6'd24: data <= `RHD_CONVERT(6'd63);
			6'd25: data <= `RHD_CONVERT(6'd63);
			6'd26: data <= `RHD_CONVERT(6'd63);
			6'd27: data <= `RHD_CONVERT(6'd63);
			6'd28: data <= `RHD_CONVERT(6'd63);
			6'd29: data <= `RHD_CONVERT(6'd63);
			6'd30: data <= `RHD_CONVERT(6'd63);
			6'd31: data <= `RHD_CONVERT(6'd63);
			6'd32: data <= cmd0;
			6'd33: data <= cmd1;
			6'd34: data <= cmd2;
			default: data <= `RHD_READ(6'd63);
		endcase
	end
	
endmodule