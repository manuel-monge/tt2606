/*******************************************************************
Autor: Manuel Monge
Description:
    Top-level file for a Tiny Tapeout Project.
Copyright (c) 2026 Manuel Monge
SPDX-License-Identifier: Apache-2.0
*******************************************************************/

`default_nettype none

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
    //inputs
    wire sclk,sen,sdi;
    //outputs
    wire sdo;
    wire [15:0] dout;

    scanchain16 #(.n(16)) scanchain0 (
        .sclk   (sclk),
        .sen    (sen),
        .sdi    (sdi),
        .sdo    (sdo),
        .dout   (dout)
    );

    // Pin Mapping
    assign sclk = clk;
    assign sen = ui_in[0];
    assign sdi = ui_in[1];
    assign uo_out[0] = sdo;

    // *****************************************************************
    // END: Description of your design
    // *****************************************************************

    // *****************************************************************
    // BEGIN: Unused inputs and outputs
    // *****************************************************************

    // All output pins must be assigned. If not used, assign to 0.
    assign uo_out[7:1] = 0;
    assign uio_out = 0;
    assign uio_oe  = 0;

    // List all unused inputs to prevent warnings
    wire _unused = &{ena, rst_n, ui_in[7:2], uio_in, 1'b0};

    // *****************************************************************
    // END: Unused inputs and outputs
    // *****************************************************************

endmodule


/*******************************************************************
Autor: Manuel Monge
Description:
    Generic Scan Chain (Shift Register and 'valid' register).
Inputs:
    sclk: Scan clock
    sen: enables the parallel load to the second parallel register
    sdi: Scan chain input (MSB First)
Outputs:
    sdo: Scan chain output
    dout: Parallel data out
*******************************************************************/

module scanchain16(sclk,sen,sdi,sdo,dout);
    parameter n=16;//number of bits of the scan chain
    //inputs
    input sclk,sen,sdi;
    //outputs
    output sdo;
    output [n-1:0] dout;

    reg [n-1:0] chain,dout;

    //shift register
    always@(posedge sclk)
        chain<={chain[n-2:0],sdi};

    //Scan chain output
    assign sdo=chain[n-1];

    //Load bits to parallel output
    always@(posedge sclk)
        if(sen)
            dout<=chain;
endmodule
