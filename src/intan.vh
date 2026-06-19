/***************************************************************************
Author: Manuel Monge
Description:
	Register addresses and OpCodes for Intan Chips.
	Supported chips:
	* RHD2164
	* (RHS2116)
***************************************************************************/

`ifndef INTAN_VH
`define INTAN_VH

// RHD2164
// *************************************************************************
// Register map: 64 registers, 8-bit each.
// All registers must be configured upon power-up.
// Keep in mind that you are interacting with 2x RHD2132 SPI controllers in 
// parallel which outputs are time-multiplexed.
// *************************************************************************

// COMMANDS

// CONVERT(C): Run ADC conversion on channel C. Result is sent to Master two commands later.
//             When C=63, the chip cycles through successive amplifier channels.
// Bit: 15 - 14 - 13 - 12 - 11 - 10 - 09 - 08 - 07 - 06 - 05 - 04 - 03 - 02 - 01 - 00
//       0    0  C[5] C[4] C[3] C[2] C[1] C[0]   0    0    0    0    0    0    0    H

`define RHD_CONVERT_CODE 2'b00
`define RHD_CONVERT_BOTTOMBYTE 8'b00000000

`define RHD_CONVERT(CHANNEL) {`RHD_CONVERT_CODE,CHANNEL,8'd0}


// CALIBRATE: Initiate ADC self-calibration routine. To be performed after chip power-up 
//            and register configuration. 9 dummy commands must be sent after a CALIBRATE command.
//            Dummy commands are not executed.
// Bit: 15 - 14 - 13 - 12 - 11 - 10 - 09 - 08 - 07 - 06 - 05 - 04 - 03 - 02 - 01 - 00
//       0    1    0    1    0    1    0    1    0    0    0    0    0    0    0    0

`define RHD_CALIBRATE 16'b0101010100000000
`define RHD_CALIBRATE_RSPND_2C 16'b0000000000000000
`define RHD_CALIBRATE_RSPND_OTHER 16'b1000000000000000


// CLEAR: Clear ADC calibration
// Bit: 15 - 14 - 13 - 12 - 11 - 10 - 09 - 08 - 07 - 06 - 05 - 04 - 03 - 02 - 01 - 00
//       0    1    1    0    1    0    1    0    0    0    0    0    0    0    0    0

`define RHD_CLEAR 16'b0110101000000000
`define RHD_CLEAR_RSPND_2C 16'b0000000000000000
`define RHD_CLEAR_RSPND_OTHER 16'b1000000000000000


// WRITE(R,D): Write data D to register R
// Bit: 15 - 14 - 13 - 12 - 11 - 10 - 09 - 08 - 07 - 06 - 05 - 04 - 03 - 02 - 01 - 00
//       1    0  R[5] R[4] R[3] R[2] R[1] R[0] D[7] D[6] D[5] D[4] D[3] D[2] D[1] D[0]
// Rspnd: 
//       1    1    1    1    1    1    1    1  D[7] D[6] D[5] D[4] D[3] D[2] D[1] D[0]

`define RHD_WRITE_CODE 2'b10
`define RHD_WRITE_RSPND_TOPBYTE 8'b11111111
`define RHD_WRITE(REGISTER, DATA) {`RHD_WRITE_CODE,REGISTER,DATA}

// READ(R): Read contents of register R
// Bit: 15 - 14 - 13 - 12 - 11 - 10 - 09 - 08 - 07 - 06 - 05 - 04 - 03 - 02 - 01 - 00
//       1    1  R[5] R[4] R[3] R[2] R[1] R[0]   0    0    0    0    0    0    0    0
// Rspnd:
//       0    0    0    0    0    0    0    0  D[7] D[6] D[5] D[4] D[3] D[2] D[1] D[0]

`define RHD_READ_CODE 2'b11
`define RHD_READ_RSPND_TOPBYTE 8'b00000000
`define RHD_READ(REGISTER) {`RHD_READ_CODE,REGISTER,8'd0}


// ON-CHIP Registers
// 64x 8-bit Registers
// Default values

`define RHD_ADC_REF_BW 2'b11
`define RHD_AMP_FAST_SETTLE 1'b0
`define RHD_AMP_VREF_ENABLE 1'b1
`define RHD_ADC_COMP_BIAS 2'b11
`define RHD_ADC_COMP_SEL 2'b10

`define RHD_REG0 {`RHD_ADC_REF_BW, `RHD_AMP_FAST_SETTLE, `RHD_AMP_VREF_ENABLE, `RHD_ADC_COMP_BIAS, `RHD_ADC_COMP_SEL}

`define RHD_VDD_SENSE_ENABLE 1'b0
`define RHD_ADC_BUFFER_BIAS 6'd2

`define RHD_REG1 {1'b0, `RHD_VDD_SENSE_ENABLE, `RHD_ADC_BUFFER_BIAS}

`define RHD_MUX_BIAS 6'd4

`define RHD_REG2 {2'b00, `RHD_MUX_BIAS}

`define RHD_MUX_LOAD 3'b000
`define RHD_TEMPS2 1'b0
`define RHD_TEMPS1 1'b0
`define RHD_TEMPEN 1'b0
`define RHD_DIGOUT_HIZ 1'b1
`define RHD_DIGOUT 1'b0

`define RHD_REG3 {`RHD_MUX_LOAD, `RHD_TEMPS2, `RHD_TEMPS1, `RHD_TEMPEN, `RHD_DIGOUT_HIZ, `RHD_DIGOUT}

`define RHD_WEAK_MISO 1'b1
`define RHD_TWOSCMP 1'b1
`define RHD_ABSMODE 1'b0
`define RHD_DSPEN 1'b0
`define RHD_DSP_CUTOFF 4'b0000

`define RHD_REG4 {`RHD_WEAK_MISO, `RHD_TWOSCMP, `RHD_ABSMODE, `RHD_DSPEN, `RHD_DSP_CUTOFF}

`define RHD_ZCHECK_DAC_POWER 1'b0
`define RHD_ZCHECK_LOAD 1'b0
`define RHD_ZCHECK_SCALE 2'b00
`define RHD_ZCHECK_CONN_ALL 1'b0
`define RHD_ZCHECK_SEL_POL 1'b0
`define RHD_ZCHECK_EN 1'b0

`define RHD_REG5 {1'b0, `RHD_ZCHECK_DAC_POWER, `RHD_ZCHECK_LOAD, `RHD_ZCHECK_SCALE, `RHD_ZCHECK_CONN_ALL, `RHD_ZCHECK_SEL_POL, `RHD_ZCHECK_EN}

`define RHD_ZCHECK_DAC 8'b00000000

`define RHD_REG6 {`RHD_ZCHECK_DAC}

`define RHD_ZCHECK_SEL 6'b000000

`define RHD_REG7 {2'b00, `RHD_ZCHECK_SEL}

`define RHD_OFFCHIP_RH1 1'b0
`define RHD_OFFCHIP_RH2 1'b0
`define RHD_OFFCHIP_RL 1'b0
`define RHD_RH1_DAC1 6'd8
`define RHD_RH1_DAC2 5'd0
`define RHD_RH2_DAC1 6'd4
`define RHD_RH2_DAC2 5'd0
`define RHD_RL_DAC1 7'd35
`define RHD_RL_DAC2 6'd17
`define RHD_RL_DAC3 1'b0
`define RHD_ADC_AUX1_EN 1'b0
`define RHD_ADC_AUX2_EN 1'b0
`define RHD_ADC_AUX3_EN 1'b0

`define RHD_REG8 {`RHD_OFFCHIP_RH1, 1'b0, `RHD_RH1_DAC1}
`define RHD_REG9 {`RHD_ADC_AUX1_EN, 2'b00, `RHD_RH1_DAC2}
`define RHD_REG10 {`RHD_OFFCHIP_RH2, 1'b0, `RHD_RH2_DAC1}
`define RHD_REG11 {`RHD_ADC_AUX2_EN, 2'b00, `RHD_RH2_DAC2}
`define RHD_REG12 {`RHD_OFFCHIP_RL, `RHD_RL_DAC1}
`define RHD_REG13 {`RHD_ADC_AUX3_EN, `RHD_RL_DAC3, `RHD_RH1_DAC2}

// Individual Amplifier Power
`define RHD_APWR_7_0 8'b11111111
`define RHD_APWR_15_8 8'b11111111
`define RHD_APWR_23_16 8'b11111111
`define RHD_APWR_31_24 8'b11111111
`define RHD_APWR_32_39 8'b11111111
`define RHD_APWR_40_47 8'b11111111
`define RHD_APWR_48_55 8'b11111111
`define RHD_APWR_56_63 8'b11111111

`define RHD_REG14 {`RHD_APWR_7_0}
`define RHD_REG15 {`RHD_APWR_15_8}
`define RHD_REG16 {`RHD_APWR_23_16}
`define RHD_REG17 {`RHD_APWR_31_24}
`define RHD_REG18 {`RHD_APWR_32_39}
`define RHD_REG19 {`RHD_APWR_40_47}
`define RHD_REG20 {`RHD_APWR_48_55}
`define RHD_REG21 {`RHD_APWR_56_63}



// ROM Registers

// RHD _REG40-RHD_REG44: Company Designation
`define RHD_REG40_VAL 8'h49 // I in ASCII
`define RHD_REG41_VAL 8'h4e // N in ASCII
`define RHD_REG42_VAL 8'h54 // T in ASCII
`define RHD_REG43_VAL 8'h41 // A in ASCII
`define RHD_REG44_VAL 8'h4e // N in ASCII

// RHD REG59: MMISO A/B Marker // MISOA = 8'b00110101; MISOB = 8'b00111010;
// RHD_REG60: Die Revision
// RHD_REG61: Unipolar(1)/Bipolar(0) Amplifiers
// RHD_REG62: Number of Amplifiers
// RHD_REG63: Intan Technologies Chip ID (RHD2164 ID = 4)
`define RHD_2164_MISOA_MARKER 8'b00110101
`define RHD_2164_MISOB_MARKER 8'b00111010
`define RHD_2164_UNIBIAMP 8'd0
`define RHD_2164_NUMAMP 8'd64
`define RHD_2164_CHIPID 8'd4


`endif // INTAN_VH