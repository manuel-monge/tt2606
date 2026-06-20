/*******************************************************************
Autor: Manuel Monge
Description:
    Top-level file for a Tiny Tapeout Project.
Copyright (c) 2026 Manuel Monge
SPDX-License-Identifier: Apache-2.0
*******************************************************************/

`default_nettype none
`include "intan.vh"
`include "components.v"
`include "spi_controllers.v"

module tt_um_top (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // *****************************************************************
    // BEGIN: Description of your design
    // *****************************************************************

    // Inputs
    wire SC_SDI, SC_SCLK, SC_SEN, REG_MOSI, REG_SCK, REG_CSb, SR_CLK, SR_EN;
    // Outputs
    wire RHD_MOSI, RHD_SCK, RHD_CSb, MCU_MISO, SC_SDO, REG_MISO, SR_DO;
    // io-inputs
    wire RHD_MISO0, RHD_MISO1, MCU_MOSI, MCU_SCK, MCU_CSb, SELM0;



	rhd2164x2_fpga_mcu_bridge bridge0 (
		.rstb	(rst_n),
		.clk	(clk),
		// SPI to MCU
		.spi0_csb	(MCU_CSb),	// MCU_CSb input
		.spi0_sck	(MCU_SCK),	// MCU_SCK input
		.spi0_mosi	(MCU_MOSI),	// MCU_MOSI input
		.spi0_miso	(MCU_MISO),	// MCU_MISO output
		// SPI to RHD2164x2
		.spi1_miso1	(RHD_MISO1),	// RHD_MISO1 input
		.spi1_miso0	(RHD_MISO0),	// RHD_MISO0 input
		.spi1_csb	(RHD_CSb),	// RHD_CSb output
		.spi1_sck	(RHD_SCK),	// RHD_SCK output
		.spi1_mosi	(RHD_MOSI),	// RHD_MOSI output
		// SPI to REG
		.spi2_csb	(REG_CSb),	// REG_CSb input
		.spi2_sck	(REG_SCK),	// REG_SCK input
		.spi2_mosi	(REG_MOSI),	// REG_MOSI input
		.spi2_miso	(REG_MISO),	// REG_MISO output
		// Scanchain
		.sc0_sdi	(SC_SDI),	// SC_SDI input
		.sc0_sclk	(SC_SCLK),	// SC_SCLK input
		.sc0_sen	(SC_SEN),	// SC_SEN input
		.sc0_sdo	(SC_SDO),	// SC_SDO output
		// Shift Register
		.sr0_clk	(SR_CLK),	// SR_CLK input
		.sr0_en	(SR_EN),		// SR_EN input
		.sr0_do	(SR_DO),		// SR_DO output
		// Selectors
		.selm0	(SELM0)		// SELM0 input
	);

    // Pin Mapping
    
	assign SC_SDI   = ui_in[0];
    assign SC_SCLK  = ui_in[1];
    assign SC_SEN   = ui_in[2];
    assign REG_MOSI = ui_in[3];
    assign REG_SCK  = ui_in[4];
    assign REG_CSb  = ui_in[5];
    assign SR_CLK   = ui_in[6];
    assign SR_EN  	= ui_in[7];

    assign uo_out[0] = RHD_MOSI;
    assign uo_out[1] = RHD_SCK;
    assign uo_out[2] = RHD_CSb;
    assign uo_out[3] = MCU_MISO;
    assign uo_out[4] = SC_SDO;
    assign uo_out[5] = REG_MISO;
    assign uo_out[6] = SR_DO;

    assign RHD_MISO0 = uio_in[0];
    assign RHD_MISO1 = uio_in[1];
    assign MCU_MOSI = uio_in[2];
    assign MCU_SCK  = uio_in[3];
    assign MCU_CSb  = uio_in[4];
    assign SELM0    = uio_in[5];



    // *****************************************************************
    // END: Description of your design
    // *****************************************************************

    // *****************************************************************
    // BEGIN: Unused inputs and outputs
    // *****************************************************************

    // All output pins must be assigned. If not used, assign to 0.
    assign uo_out[7] = 0;
    assign uio_out = 0;
    assign uio_oe  = 0; // Set all IOs to input by default (0=input, 1=output)

    // List all unused inputs to prevent warnings
    wire _unused = &{ena, uio_in[7:6], 1'b0};

    // *****************************************************************
    // END: Unused inputs and outputs
    // *****************************************************************

endmodule


// *******************************************************************************
// *******************************************************************************
// *******************************************************************************


/***********************************************************
	Author: Manuel Monge
	Description:
		Clock divider
	Inputs:
		clk: Input clock
	Outputs:
		clkout: Output clock
***********************************************************/

module rhd2164x2_fpga_mcu_bridge (
	input  wire	rstb,
	input  wire	clk,
	// SPI to MCU
	input  wire	spi0_csb,	// MCU_CSb input
	input  wire	spi0_sck,	// MCU_SCK input
	input  wire	spi0_mosi,	// MCU_MOSI input
	output wire	spi0_miso,	// MCU_MISO output
	// SPI to RHD2164x2
	input  wire	spi1_miso1,	// RHD_MISO1 input
	input  wire	spi1_miso0,	// RHD_MISO0 input
	output wire	spi1_csb,	// RHD_CSb output
	output wire	spi1_sck,	// RHD_SCK output
	output wire	spi1_mosi,	// RHD_MOSI output
	// SPI to REG
	input  wire	spi2_csb,	// REG_CSb input
	input  wire	spi2_sck,	// REG_SCK input
	input  wire	spi2_mosi,	// REG_MOSI input
	output wire	spi2_miso,	// REG_MISO output
	// Scanchain
	input  wire	sc0_sdi,	// SC_SDI input
	input  wire	sc0_sclk,	// SC_SCLK input
	input  wire	sc0_sen,	// SC_SEN input
	output wire	sc0_sdo,	// SC_SDO output
    // Shift Register
	input  wire	sr0_clk,	// SR_CLK input
	input  wire	sr0_en,		// SR_EN input
	output wire	sr0_do,		// SR_DO output
    // Selectors
	input wire	selm0		// SELM0 output
);
	
	// parameters
	parameter n = 16;
	parameter spi0_data_tx = 16'hbaba;
	parameter spi1_data_tx = 16'h8787;
	parameter cmd_00 = {2'b00,6'd3,8'b10000001};
	
	
	// wire & regs
	wire [n-1:0] spi0_data_rx;
	wire spi0_done;
	
	wire rhd_spi1_start;
	wire [n-1:0] spi1_data_rx_a0,spi1_data_rx_b0;
	wire [n-1:0] spi1_data_rx_a1,spi1_data_rx_b1;
	wire rhd_spi1_done;
	wire [15:0] rhd_dtx,rhd_dtx0,rhd_dtx1;
	wire rhd_dtx_sel;
	wire [5:0] rhd_addr_cfg,rhd_addr_sampling;
	
	// FIFO
	wire fifo_wen, fifo_ren, fifo_empty, fifo_full;
	wire [15:0] fifo_din, fifo_dout;
	
	
	wire [15:0] rhd2164_sampling_cmd0, rhd2164_sampling_cmd1, rhd2164_sampling_cmd2;
	wire [7:0] mode0_ch_a;
	wire regbank_wen;
	wire [5:0] regbank_addr0, regbank_addr1;
	wire [15:0] regbank_din0, regbank_dout0, regbank_dout1;
	

	wire [15:0] spi2_drx, sc0_dout, spi_sc_data_rx;
	wire spi2_done, sc0_done, spi_sc_done;


	// *******************************************************************************
	// TOP SECTION
	// *******************************************************************************

	// SPI-SLAVE to REG
	spi_slave_reg16b u_reg_spi (
        .RSTB     ( rstb       ),
        .CLK      ( clk        ),
        .REG_CSb  ( spi2_csb   ),
        .REG_SCK  ( spi2_sck   ),
        .REG_MOSI ( spi2_mosi  ),
        .REG_MISO ( spi2_miso  ),
        .REG_DRX  ( spi2_drx   ),
        .REG_DTX  ( regbank_dout0 ),
        .REG_DONE ( spi2_done  )
    );

	// ScanChain
	scanchain16 scanchain0 (
		.RSTB		(rstb),
		.CLK		(clk),
		.SC_SDI		(sc0_sdi),
		.SC_SCLK	(sc0_sclk),
		.SC_SEN		(sc0_sen),
		.SC_SDO		(sc0_sdo),
		.SC_DOUT	(sc0_dout),
		.SC_DONE	(sc0_done)
	);


	// Multiplexor
	assign spi_sc_data_rx = (selm0) ? sc0_dout : spi2_drx;
	assign spi_sc_done = (selm0) ? sc0_done : spi2_done;


	// FSM1
	regbank_controller fsm1 (
		.rstb			(rstb),						// Active-low asyncrhonous reset
		.clk			(clk),						// Input clock
		.spi_sc_done	(spi_sc_done),				// Active-high Input; indicates SPI communication with REG is done
		.regbank_wen	(regbank_wen)				// Active-high Output; FIFO read-enable
	);

	assign regbank_addr0 = spi_sc_data_rx[13:8];
	assign regbank_din0 = {8'd0,spi_sc_data_rx[7:0]};
	assign regbank_addr1 = 6'd0;
	
	
	// RegBank RAM
	ram #(
		.DATA_WIDTH	(16),
		.ADDR_WIDTH	(6)
		)
		regbank	(
		.rstb		(rstb),			// Active-low asyncrhonous reset
		.clk		(clk),			// Input clock
		.wen		(regbank_wen),	// Input; RegBank write enable
		.addr0		(regbank_addr0),	// Input Address, Port0
		.din0		(regbank_din0),	// Input Data, Port0
		.dout0		(regbank_dout0),	// Output Data, Port0
		.addr1		(regbank_addr1),	// Input Address, Port0
		.dout1		(regbank_dout1),	// Output Data, Port0
		// Config connections
		.rhd2164_sampling_cmd0	(rhd2164_sampling_cmd0),
		.rhd2164_sampling_cmd1	(rhd2164_sampling_cmd1),
		.rhd2164_sampling_cmd2	(rhd2164_sampling_cmd2),
		.mode0_ch_a	(mode0_ch_a)
	);
	

	// Shift Register
	shift_register_16b shiftreg16b0 (
		.RSTB	(rstb),
		.CLK	(clk),
		.DIN	(regbank_dout0),
		.SR_CLK	(sr0_clk),
		.SR_EN	(sr0_en),
		.SR_DO	(sr0_do)
	);




	// BOTTOM SECTION
	
	// SPI-Master to 2x RHD2164 chips
	spi_master_rhd2164x2 spi1_rhd2164x2 (
		.rstb		(rstb),				// Active-low asyncrhonous reset
		.clk		(clk),				// Input clock
		.start		(rhd_spi1_start),	// Active-high signal that starts SPI cycle
		.csb		(spi1_csb),			// Active-low chip-select
		.sck		(spi1_sck),			// SPI Clock
		.mosi		(spi1_mosi),		// Master-Output Slave-Input
		.miso		(spi1_miso0),		// Master-Input Slave-Output
		.miso1		(spi1_miso1),		// Master-Input Slave-Output 1
		.data_tx	(rhd_dtx),		// Data to be transmitted
		.data_rx_a	(spi1_data_rx_a0),	// DataA received
		.data_rx_b	(spi1_data_rx_b0),	// DataB received
		.data_rx_a1	(spi1_data_rx_a1),	// DataA1 received
		.data_rx_b1	(spi1_data_rx_b1),	// DataB1 received
		.done		(rhd_spi1_done)		// TX/RX operation completed; no communicacion happening
	);
	

	// RHD2164 CFG ROM
	rhd2164_cfg_rom rhd2164_rom0 (
		.addr	(rhd_addr_cfg),
		.data	(rhd_dtx0)
	);
	
	// RHD2164 Sampling ROM
	rhd2164_sampling_rom rhd2164_rom1 (
		.addr	(rhd_addr_sampling),
		.data	(rhd_dtx1),
		.cmd0	(rhd2164_sampling_cmd0),
		.cmd1	(rhd2164_sampling_cmd1),
		.cmd2	(rhd2164_sampling_cmd2)
	);

	// Data TX Mux
	assign rhd_dtx = (rhd_dtx_sel) ? rhd_dtx1:rhd_dtx0;
	
		
	// FSM
	
	rhd2164_controller controller0 (
		.rstb				(rstb),				// Active-low asyncrhonous reset
		.clk				(clk),				// Input clock
		.rhd_start			(rhd_spi1_start),	// Active-high output that starts RHD2164x2 SPI cycle
		.rhd_done			(rhd_spi1_done),		// Active-high input that indicates SPI cycle has finished
		.rhd_dtx_sel		(rhd_dtx_sel),		// Output selector to the data_sel mux
		.rhd_addr_cfg		(rhd_addr_cfg),		// Output controlling the address of RHD2164_CFG_ROM which contains instructions for the RHD2164 configuration
		.rhd_addr_sampling	(rhd_addr_sampling)	// Output controlling the address of RHD2164_SAMPLING_ROM which contains instructions for the RHD2164 operation
	);
	

	// Main Controller
	main_controller controller1 (
		.rstb		(rstb),			// Active-low asyncrhonous reset
		.clk		(clk),			// Input clock
		.fifo_empty	(fifo_empty),	// Active-high Input; indicates if FIFO is empty
		.fifo_ren	(fifo_ren),		// Active-high Output; FIFO read-enable
		.mcu_done	(spi0_done)		// Active-high Input; indicates SPI communication with MCU is done
	);
	

	// Channel Selector
	ch_sel #(
		.n(16)
		)
		ch_sel0 (
		.rstb		(rstb),				    // Active-low asyncrhonous reset
		.clk		(clk),				    // Input clock
		.ch_cnt		(rhd_addr_sampling),	// Input; channel count
		.data_a0	(spi1_data_rx_a0),	    // Input; 16-bit data coming from RHD2164-0 output a
		.data_b0	(spi1_data_rx_b0),	    // Input; 16-bit data coming from RHD2164-0 output b
		.data_a1	(spi1_data_rx_a1),	    // Input; 16-bit data coming from RHD2164-1 output a
		.data_b1	(spi1_data_rx_b1),	    // Input; 16-bit data coming from RHD2164-1 output b
		.dout		(fifo_din),			    // Output Data
		// Channel Config
		.mode0_ch_a	(mode0_ch_a),
        .dtx_sel    (rhd_dtx_sel),		    // Input: indicates Sampling mode when '1'
        .fifo_wen	(fifo_wen)			    // Output; FIFO write enable
	);
	

	// FIFO
	fifo #(
		.DATA_WIDTH	(16),
		.ADDR_WIDTH	(4)
		)
		fifo0 (
		.rstb	(rstb),			// Active-low asyncrhonous reset
		.clk	(clk),			// Input clock
		.wen	(fifo_wen),		// Input; FIFO write enable
		.ren	(fifo_ren),		// Input; FIFO read enable
		.DIN	(fifo_din),		// Input Data
		.DOUT	(fifo_dout),	// Output Data
		.empty	(fifo_empty),	// Output flag indicating empty FIFO
		.full	(fifo_full)		// Output flag indicating full FIFO
	);
	

	// SPI-Slave to MCU as Master
	spi_slave #(.n(16),.m(4)) spi0 (
		.rstb		(rstb),
		.clk		(clk),
		.csb		(spi0_csb),
		.sck		(spi0_sck),
		.mosi		(spi0_mosi),
		.miso		(spi0_miso),
		.data_tx	(fifo_dout),
		.data_rx	(spi0_data_rx),
		.done		(spi0_done)
	);
	
	
endmodule




// =============================================================================
// SPI Slave REG 16b
// -----------------------------------------------------------------------------
// SPI slave controller to interface with an external unit.
// Protocol: CPOL=0, CPHA=0
//   - Data is captured on the RISING  edge of REG_SCK
//   - Data is shifted  on the FALLING edge of REG_SCK
//   - REG_CSb is active-low chip select
//   - Transfer width: 16 bits (MSB first)
//
// Ports
//   RSTB        : I  – Asynchronous, active-low reset (system domain)
//   CLK         : I  – System input clock (used for synchronisation)
//   REG_CSb     : I  – SPI chip-select, active low
//   REG_SCK     : I  – SPI clock from master
//   REG_MOSI    : I  – Master-Out Slave-In data
//   REG_MISO    : O  – Master-In  Slave-Out data
//   REG_DRX[15:0]: O – Received data; valid when REG_DONE is 1
//   REG_DTX[15:0]: I – Data to transmit; must be ready right after REG_DONE=1
//   REG_DONE    : O  – Active-high; pulses for one CLK cycle when 16-bit
//                      frame has been fully received / transmitted
// =============================================================================

module spi_slave_reg16b (
    // System
    input  wire        RSTB,          // async active-low reset
    input  wire        CLK,           // system clock (for sync & output domain)

    // SPI interface
    input  wire        REG_CSb,       // chip-select (active low)
    input  wire        REG_SCK,       // SPI clock
    input  wire        REG_MOSI,      // MOSI
    output reg         REG_MISO,      // MISO

    // User interface
    output reg  [15:0] REG_DRX,       // received word
    input  wire [15:0] REG_DTX,       // word to transmit
    output reg         REG_DONE       // transfer-complete strobe (1 CLK wide)
);

// ---------------------------------------------------------------------------
// 1.  Double-flop synchronisers for SCK, CSb and MOSI (CLK domain)
//     Prevents metastability when CLK >> SCK.
// ---------------------------------------------------------------------------
reg [1:0] sck_sync;
reg [1:0] csb_sync;
reg [1:0] mosi_sync;

always @(posedge CLK or negedge RSTB) begin
    if (!RSTB) begin
        sck_sync  <= 2'b00;
        csb_sync  <= 2'b11;   // deasserted (high)
        mosi_sync <= 2'b00;
    end else begin
        sck_sync  <= {sck_sync[0],  REG_SCK};
        csb_sync  <= {csb_sync[0],  REG_CSb};
        mosi_sync <= {mosi_sync[0], REG_MOSI};
    end
end

// Stable (synchronised) versions of SPI signals in CLK domain
wire sck_s  = sck_sync[1];
wire csb_s  = csb_sync[1];
wire mosi_s = mosi_sync[1];

// Edge detection on SCK (previous value is bit [1], current is captured next)
reg sck_prev;
always @(posedge CLK or negedge RSTB) begin
    if (!RSTB) sck_prev <= 1'b0;
    else        sck_prev <= sck_s;
end

wire sck_rising  = ( sck_s & ~sck_prev);   // CPOL=0,CPHA=0 → sample
wire sck_falling = (~sck_s &  sck_prev);   // CPOL=0,CPHA=0 → shift

// ---------------------------------------------------------------------------
// 2.  Bit counter and shift registers
// ---------------------------------------------------------------------------
reg [3:0]  bit_cnt;        // counts 0..15
reg [15:0] rx_shreg;       // shift-in  register
reg [15:0] tx_shreg;       // shift-out register

// ---------------------------------------------------------------------------
// 3.  Main state machine (CLK domain)
// ---------------------------------------------------------------------------
// States
localparam IDLE  = 2'b00;
localparam ARMED = 2'b01;   // CSb asserted, waiting for first SCK rise
localparam XFER  = 2'b10;   // shifting bits
localparam DONE  = 2'b11;   // 16 bits done, assert REG_DONE for 1 cycle

reg [1:0] state;

always @(posedge CLK or negedge RSTB) begin
    if (!RSTB) begin
        state     <= IDLE;
        bit_cnt   <= 4'd0;
        rx_shreg  <= 16'd0;
        tx_shreg  <= 16'd0;
        REG_DRX   <= 16'd0;
        REG_DONE  <= 1'b0;
        REG_MISO  <= 1'b0;
    end else begin
        // Default: clear single-cycle signals
        REG_DONE <= 1'b0;

        case (state)
            // ------------------------------------------------------------------
            IDLE: begin
                REG_MISO <= REG_DTX[15];   // pre-drive MSB on MISO
                if (!csb_s) begin
                    // CSb just asserted → load TX shift-register, go ARMED
                    tx_shreg <= REG_DTX;
                    REG_MISO <= REG_DTX[15];
                    bit_cnt  <= 4'd0;
                    state    <= ARMED;
                end
            end

            // ------------------------------------------------------------------
            // CSb is low; wait for the first rising edge of SCK
            ARMED: begin
                if (csb_s) begin
                    // CS deasserted before any clock → back to IDLE
                    state <= IDLE;
                end else if (sck_rising) begin
                    // Sample MOSI on first rising edge
                    rx_shreg <= {rx_shreg[14:0], mosi_s};
                    bit_cnt  <= bit_cnt + 4'd1;
                    state    <= XFER;
                end else if (sck_falling) begin
                    // Shift out next TX bit on falling edge (pre-shift for bit 0)
                    tx_shreg <= {tx_shreg[14:0], 1'b0};
                    REG_MISO <= tx_shreg[14];   // next bit is [14] after shift
                end
            end

            // ------------------------------------------------------------------
            XFER: begin
                if (csb_s) begin
                    // Unexpected CS deassert mid-frame → abort
                    state <= IDLE;
                end else begin
                    // Falling edge: shift out next TX bit
                    if (sck_falling) begin
                        tx_shreg <= {tx_shreg[14:0], 1'b0};
                        REG_MISO <= tx_shreg[14];
                    end

                    // Rising edge: sample MOSI
                    if (sck_rising) begin
                        rx_shreg <= {rx_shreg[14:0], mosi_s};
                        bit_cnt  <= bit_cnt + 4'd1;

                        if (bit_cnt == 4'd15) begin
                            // This was the 16th (last) bit
                            state <= DONE;
                        end
                    end
                end
            end

            // ------------------------------------------------------------------
            DONE: begin
                // Latch received word and signal done for one clock
                REG_DRX  <= rx_shreg;
                REG_DONE <= 1'b1;

                // Pre-load next TX word immediately so master can start a new
                // frame right after CSb is re-asserted
                tx_shreg <= REG_DTX;
                REG_MISO <= REG_DTX[15];

                // Return to IDLE (or ARMED if CSb is still asserted)
                if (!csb_s) begin
                    // Back-to-back frames: stay ready
                    bit_cnt <= 4'd0;
                    state   <= ARMED;
                end else begin
                    state <= IDLE;
                end
            end

            default: state <= IDLE;
        endcase
    end
end

endmodule




/*******************************************************************
Author: Julio
Description:
    16-bit Shift Register with edge detection on SR_CLK.
    - RSTB: Asynchronous reset (active low)
    - CLK: System clock (fast, always running)
    - DIN[15:0]: Parallel input (internal, not from pins)
    - SR_CLK: External signal whose rising edge triggers a shift
    - SR_EN: Enable (1 = load parallel, 0 = shift)
    - SR_DO: Serial output

Modification by Manuel Monge:
	- Added additional register to `SR_CLK` to help with synchronization.
	- Change output to MSB first
*******************************************************************/

module shift_register_16b (
    input  wire       RSTB,
    input  wire       CLK,
    input  wire [15:0] DIN,
    input  wire       SR_CLK,
    input  wire       SR_EN,
    output wire       SR_DO
);
    reg [15:0] shift_reg;
    reg sr_clk_prev,sr_clk_prev2; // Previous value of SR_CLK for edge detection
    wire shift_pulse;             // Single-cycle pulse when SR_CLK rises
    
    // Edge detector for SR_CLK (sampled on CLK)
    always @(posedge CLK or negedge RSTB) begin
        if (!RSTB) begin
            sr_clk_prev <= 1'b0;
			sr_clk_prev2 <= 1'b0;
        end
        else begin
            sr_clk_prev <= SR_CLK;  // Sample SR_CLK on every CLK edge
			sr_clk_prev2 <= sr_clk_prev; // Sample SR_CLK_PREV
        end
    end
    
    // Single-cycle pulse when SR_CLK transitions from 0 to 1
    assign shift_pulse = sr_clk_prev && !sr_clk_prev2;
    
    // Shift register logic (updates on CLK edge when shift_pulse is high)
    always @(posedge CLK or negedge RSTB) begin
        if (!RSTB) begin
            shift_reg <= 16'b0;
        end
        else if (shift_pulse) begin
            if (SR_EN) begin
                // Parallel load
                shift_reg <= DIN;
            end
            else begin
                // Shift left (0 shifts in from the right)
                shift_reg <= {shift_reg[14:0], 1'b0};
            end
        end
    end
    
    // Serial output is the MSB of the shift register
    assign SR_DO = shift_reg[15];
    
endmodule




/*******************************************************************
Author: Julio
Description:
    16-bit Scan Chain (Shift Register + Parallel Output Register).
    - RSTB: Asynchronous reset (active low)
    - CLK: System clock (used to sample SC_SCLK)
    - SC_SDI: Serial data input (sampled on rising edge of SC_SCLK)
    - SC_SCLK: External clock input (rising edge triggers shift)
    - SC_SEN: Enable for parallel load (when =1, dout <= chain)
    - SC_SDO: Serial output (MSB of shift register)
    - SC_DOUT[15:0]: Parallel output register
    - SC_DONE: Active high for one cycle when new data is available at SC_DOUT

Modification by Manuel Monge:
	- Added additional register to `SR_CLK` to help with synchronization.
*******************************************************************/

module scanchain16 (
    input  wire       RSTB,
    input  wire       CLK,
    input  wire       SC_SDI,
    input  wire       SC_SCLK,
    input  wire       SC_SEN,
    output wire       SC_SDO,
    output wire [15:0] SC_DOUT,
    output wire       SC_DONE
);
    parameter n = 16;
    
    reg [n-1:0] chain;               // Shift register
    reg [n-1:0] dout_reg;            // Parallel output register
    reg sc_sclk_prev, sc_sclk_prev2; // Previous value of SC_SCLK (for edge detection)
    wire sclk_pulse;                 // Single-cycle pulse on rising edge of SC_SCLK
    reg done_reg;                    // Internal register for SC_DONE
    
    // Edge detector for SC_SCLK (sampled on CLK)
    always @(posedge CLK or negedge RSTB) begin
        if (!RSTB) begin
            sc_sclk_prev <= 1'b0;
			sc_sclk_prev2 <= 1'b0;
        end
        else begin
            sc_sclk_prev <= SC_SCLK;
			sc_sclk_prev2 <= sc_sclk_prev;
        end
    end
    
    // Single-cycle pulse on rising edge of SC_SCLK
    assign sclk_pulse = sc_sclk_prev && !sc_sclk_prev2;
    
    // Shift register logic (updates on CLK edge when sclk_pulse is high)
    always @(posedge CLK or negedge RSTB) begin
        if (!RSTB) begin
            chain <= {n{1'b0}};
        end
        else if (sclk_pulse) begin
            // Shift left, MSB first: new bit enters from the right
            chain <= {chain[n-2:0], SC_SDI};
        end
    end
    
    // Serial output is the MSB of the shift register
    assign SC_SDO = chain[n-1];
    
    // Parallel output register (loads when SC_SEN is high on sclk_pulse)
    always @(posedge CLK or negedge RSTB) begin
        if (!RSTB) begin
            dout_reg <= {n{1'b0}};
        end
        else if (sclk_pulse && SC_SEN) begin
            dout_reg <= chain;
        end
    end
    
    assign SC_DOUT = dout_reg;
    
    // SC_DONE: active high for one CLK cycle after a parallel load
    always @(posedge CLK or negedge RSTB) begin
        if (!RSTB) begin
            done_reg <= 1'b0;
        end
        else begin
            // Set done_reg when parallel load occurs
            if (sclk_pulse && SC_SEN) begin
                done_reg <= 1'b1;
            end
            else begin
                done_reg <= 1'b0;
            end
        end
    end
    
    assign SC_DONE = done_reg;
    
endmodule