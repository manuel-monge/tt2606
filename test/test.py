import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge, RisingEdge, Timer


async def scanchain_tx(dut, dtx, clkperiod):
    # Scanchain: bit 15
    set_bit_in_array(dut.ui_in, 0, int(dtx[15])) # SC_SDI
    await Timer(25*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SC_SCLK = 1
    await Timer(50*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SC_SCLK = 0
    await Timer(25*clkperiod, unit="us")
    
    # Scanchain: bit 14
    set_bit_in_array(dut.ui_in, 0, int(dtx[14])) # SC_SDI
    await Timer(25*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SC_SCLK = 1
    await Timer(50*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SC_SCLK = 0
    await Timer(25*clkperiod, unit="us")
    
    # Scanchain: bit 13
    set_bit_in_array(dut.ui_in, 0, int(dtx[13])) # SC_SDI
    await Timer(25*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SC_SCLK = 1
    await Timer(50*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SC_SCLK = 0
    await Timer(25*clkperiod, unit="us")
    
    # Scanchain: bit 12
    set_bit_in_array(dut.ui_in, 0, int(dtx[12])) # SC_SDI
    await Timer(25*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SC_SCLK = 1
    await Timer(50*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SC_SCLK = 0
    await Timer(25*clkperiod, unit="us")
    
    # Scanchain: bit 11
    set_bit_in_array(dut.ui_in, 0, int(dtx[11])) # SC_SDI
    await Timer(25*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SC_SCLK = 1
    await Timer(50*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SC_SCLK = 0
    await Timer(25*clkperiod, unit="us")
    
    # Scanchain: bit 10
    set_bit_in_array(dut.ui_in, 0, int(dtx[10])) # SC_SDI
    await Timer(25*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SC_SCLK = 1
    await Timer(50*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SC_SCLK = 0
    await Timer(25*clkperiod, unit="us")
    
    # Scanchain: bit 9
    set_bit_in_array(dut.ui_in, 0, int(dtx[9])) # SC_SDI
    await Timer(25*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SC_SCLK = 1
    await Timer(50*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SC_SCLK = 0
    await Timer(25*clkperiod, unit="us")
    
    # Scanchain: bit 8
    set_bit_in_array(dut.ui_in, 0, int(dtx[8])) # SC_SDI
    await Timer(25*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SC_SCLK = 1
    await Timer(50*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SC_SCLK = 0
    await Timer(25*clkperiod, unit="us")
    
    # Scanchain: bit 7
    set_bit_in_array(dut.ui_in, 0, int(dtx[7])) # SC_SDI
    await Timer(25*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SC_SCLK = 1
    await Timer(50*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SC_SCLK = 0
    await Timer(25*clkperiod, unit="us")
    
    # Scanchain: bit 6
    set_bit_in_array(dut.ui_in, 0, int(dtx[6])) # SC_SDI
    await Timer(25*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SC_SCLK = 1
    await Timer(50*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SC_SCLK = 0
    await Timer(25*clkperiod, unit="us")
    
    # Scanchain: bit 5
    set_bit_in_array(dut.ui_in, 0, int(dtx[5])) # SC_SDI
    await Timer(25*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SC_SCLK = 1
    await Timer(50*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SC_SCLK = 0
    await Timer(25*clkperiod, unit="us")
    
    # Scanchain: bit 4
    set_bit_in_array(dut.ui_in, 0, int(dtx[4])) # SC_SDI
    await Timer(25*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SC_SCLK = 1
    await Timer(50*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SC_SCLK = 0
    await Timer(25*clkperiod, unit="us")
    
    # Scanchain: bit 3
    set_bit_in_array(dut.ui_in, 0, int(dtx[3])) # SC_SDI
    await Timer(25*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SC_SCLK = 1
    await Timer(50*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SC_SCLK = 0
    await Timer(25*clkperiod, unit="us")
    
    # Scanchain: bit 2
    set_bit_in_array(dut.ui_in, 0, int(dtx[2])) # SC_SDI
    await Timer(25*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SC_SCLK = 1
    await Timer(50*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SC_SCLK = 0
    await Timer(25*clkperiod, unit="us")
    
    # Scanchain: bit 1
    set_bit_in_array(dut.ui_in, 0, int(dtx[1])) # SC_SDI
    await Timer(25*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SC_SCLK = 1
    await Timer(50*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SC_SCLK = 0
    await Timer(25*clkperiod, unit="us")
    
    # Scanchain: bit 0
    set_bit_in_array(dut.ui_in, 0, int(dtx[0])) # SC_SDI
    await Timer(25*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SC_SCLK = 1
    await Timer(50*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SC_SCLK = 0
    await Timer(25*clkperiod, unit="us")
    

    # Scanchain: SEN = 1 to load the data into output
    dut.ui_in.value = "00000100" # SDI = 0; SEN = 1
    await Timer(50*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 2, 0) # SEN = 0

    set_bit_in_array(dut.ui_in, 2, 1) # SC_SEN = 1 
    await Timer(25*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SC_SCLK = 1
    await Timer(50*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SC_SCLK = 0
    await Timer(25*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 2, 0) # SC_SEN = 0


# Function to set a specific bit in an array of bits (like ui_in)
def set_bit_in_array(array, index, bit_value):
    # bit_value should be 0 or 1
    aux = array.value
    aux[index] = bit_value
    array.value = aux 

# Test to verify the behavior of the project
@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Pin Mapping
    # assign rstb = rst_n; // Active low reset

    # assign SC_SDI   = ui_in[0];
    # assign SC_SCLK  = ui_in[1];
    # assign SC_SEN   = ui_in[2];
    # assign REG_MOSI = ui_in[3];
    # assign REG_SCK  = ui_in[4];
    # assign REG_CSb  = ui_in[5];
    # assign SR_CLK   = ui_in[6];
    # assign SR_EN  = ui_in[7];

    # assign uo_out[0] = RHD_MOSI;
    # assign uo_out[1] = RHD_SCK;
    # assign uo_out[2] = RHD_CSb;
    # assign uo_out[3] = MCU_MISO;
    # assign uo_out[4] = SC_SDO;
    # assign uo_out[5] = REG_MISO;
    # assign uo_out[6] = SR_DO;

    # assign RHD_MISO0 = uio_in[0];
    # assign RHD_MISO1 = uio_in[1];
    # assign MCU_MOSI = uio_in[2];
    # assign MCU_SCK  = uio_in[3];
    # assign MCU_CSb  = uio_in[4];
    # assign SELM0    = uio_in[5];


    # Set the clock period to 0.02 us (50 MHz)
    clkperiod = 0.02 # in us
    clock = Clock(dut.clk, clkperiod, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut._log.info("ena")
    dut.ui_in.value = 0
    dut._log.info("ui_in")
    dut.uio_in.value = 0
    dut._log.info("uio_in")
    dut.rst_n.value = 0
    dut._log.info("rst_n = 0")
    await ClockCycles(dut.clk, 10)
    dut._log.info("rst_n = 1")
    dut.rst_n.value = 1
    dut._log.info("SELM0 = 1")
    set_bit_in_array(dut.uio_in, 5, 1) # SELM0 = 1
    dut._log.info("Starting Timer")
    await RisingEdge(dut.clk)
    await Timer(5*clkperiod, unit="us")
    await RisingEdge(dut.clk)
    dut._log.info("Awaiting for 5 clock cycles after reset")
    await Timer(0.5*clkperiod, unit="us") # half clock cycle

    dut._log.info("Test project behavior")

    # Set the scanchain inputs
    sc_d0 = "00" + "000000" + "10000000"
    sc_d1 = "00" + "000001" + "10000001"
    sc_d2 = "00" + "000010" + "10000010"
    sc_d3 = "00" + "000011" + "10000011"

    # Set SPI1 inputs
    spi1_miso_d0a = "11100111" + "11100111"
    spi1_miso_d0b = "10000001" + "10000001"

    

    

    dut._log.info("sc_d0: %s", sc_d0)

    # Shift in the input values bit by bit into the scanchain using SDI and SEN signals.
    dut._log.info("Shift in the data into the scanchain")

    await Timer(50*clkperiod, unit="us")
    
    # Testing scanchain writing to RAM and reading same value from Shift Register.
    dtx = sc_d0[::-1] # Reverse the string
    await scanchain_tx(dut, dtx, clkperiod)

    await Timer(10*clkperiod, unit="us")
    dtx = sc_d1[::-1] # Reverse the string
    await scanchain_tx(dut, dtx, clkperiod)

    await Timer(10*clkperiod, unit="us")
    dtx = sc_d2[::-1] # Reverse the string
    await scanchain_tx(dut, dtx, clkperiod)

    await Timer(10*clkperiod, unit="us")
    dtx = sc_d3[::-1] # Reverse the string
    await scanchain_tx(dut, dtx, clkperiod)

    # obj = getattr(dut.dut.bridge0, 'sc0_dout', None) # Check for dut.bridge0-internal variable "sc0_dout" (which is the case for RTL simulation but not for GL simulation)
    
    # if obj == None:
    #     sim_is_rtl = 0
    #     dut._log.info("GL simulation detected")
    # else:
    #     sim_is_rtl = 1
    #     dut._log.info("RTL simulation detected")


    # if sim_is_rtl:
    #     # Assert if the parallel output of the scanchain is correct after shifting in the input values.
    #     dout_value = str(dut.dut.bridge0.sc0_dout.value) # Get the dut.bridge0.sc0_dout value in binary string format
    #     dut._log.info("dout_value: %s", dout_value)
    #     assert dout_value == sc_d3 # Check if the parallel output matches the input value.
    



    # wait until CSb is `1`
    aux = dut.uo_out.value
    rhd_csb = aux[2]
    while not rhd_csb:
        await RisingEdge(dut.clk) # Wait for a rising edge of the clock
        aux = dut.uo_out.value
        rhd_csb = aux[2]

    # wait until CSb is `0`
    aux = dut.uo_out.value
    rhd_csb = aux[2]
    while rhd_csb:
        await RisingEdge(dut.clk) # Wait for a rising edge of the clock
        aux = dut.uo_out.value
        rhd_csb = aux[2]

    await Timer(1.5*clkperiod, unit="us")

    for i in range(16):
        dut._log.info("Shifting out bit %d", i)
        
        # RHD_MISO0: bit i
        set_bit_in_array(dut.uio_in, 0, int(spi1_miso_d0a[i])) # SC_SDI
        await Timer(1*clkperiod, unit="us") # one clock cycle
        # RHD_MISO0: bit i
        set_bit_in_array(dut.uio_in, 0, int(spi1_miso_d0b[i])) # SC_SDI
        await Timer(1*clkperiod, unit="us") # one clock cycle

    set_bit_in_array(dut.uio_in, 0, 0) # SC_SDI = 0
    


    await Timer(10*clkperiod, unit="us")

    # Verify the last value of SDO after scanning out all bits is Zero.
    aux = str(dut.uo_out.value) # Get the output value in binary string format
    sdo_last = int(aux[0]) # Get the last value of SDO
    dut._log.info("sdo_last: %d", sdo_last)

    assert sdo_last == 0 # Check if the last value of SDO is 0.

