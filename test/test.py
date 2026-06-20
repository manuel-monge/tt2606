import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge, RisingEdge, Timer

# Function to test `scanchain` by sending a 16b-data stored in `dtx`
async def scanchain_tx(dut, dtx, clkperiod):
    for i in range(16):
        # Scanchain: bit i
        set_bit_in_array(dut.ui_in, 0, int(dtx[i])) # SC_SDI
        await Timer(25*clkperiod, unit="us")
        set_bit_in_array(dut.ui_in, 1, 1) # SC_SCLK = 1
        await Timer(50*clkperiod, unit="us")
        set_bit_in_array(dut.ui_in, 1, 0) # SC_SCLK = 0
        await Timer(25*clkperiod, unit="us")

    # Scanchain: SEN = 1 to load the data into output
    set_bit_in_array(dut.ui_in, 0, 0) # SC_SDI = 0
    await Timer(clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 2, 1) # SC_SEN = 1 
    await Timer(49*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 2, 0) # SEN = 0

    set_bit_in_array(dut.ui_in, 2, 1) # SC_SEN = 1 
    await Timer(25*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SC_SCLK = 1
    await Timer(50*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SC_SCLK = 0
    await Timer(25*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 2, 0) # SC_SEN = 0


# Function to read data from Shift Register and compare it with `dtx` sent via Scanchain
async def shift_register_read_assert(dut,clkperiod,dtx):
    # Pulse SR_EN to load the data into Shift Register
    set_bit_in_array(dut.ui_in, 7, 1) # SR_EN = 1
    await Timer(25*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 6, 1) # SR_CLK = 1
    await Timer(50*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 6, 0) # SR_CLK = 0
    await Timer(25*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 7, 0) # SR_EN = 0
    await Timer(25*clkperiod, unit="us")

    # Scanout the data with 16 SR_CLK cycles
    sr_data_out = []
    for i in range(16):
        set_bit_in_array(dut.ui_in, 6, 1) # SR_CLK = 1
        aux = dut.uo_out.value # Get the output value in binary string format
        sr_data_out.append(str(aux[6])) # Get the value of SR_DO and append it
        await Timer(50*clkperiod, unit="us")
        set_bit_in_array(dut.ui_in, 6, 0) # SR_CLK = 0
        await Timer(50*clkperiod, unit="us")

    dout_value = "".join(sr_data_out)
    # Check if read-value is the same as sent-value
    dut._log.info("SR_dout_value: %s", dout_value)
    assert dout_value[7:0] == dtx[7:0] # Check if SR_DO matches SC_DIN value.


# Function to test `SPI-SLAVE` by sending a 16b-data stored in `dtx`
async def spi_reg_trx(dut, dtx, clkperiod):
    # CSb = 0
    set_bit_in_array(dut.ui_in, 5, 0) # REG_CSb = 0

    for i in range(16):
        await Timer(25*clkperiod, unit="us")
        set_bit_in_array(dut.ui_in, 3, int(dtx[i])) # REG_MOSI
        await Timer(25*clkperiod, unit="us")
        set_bit_in_array(dut.ui_in, 4, 1) # REG_SCK = 1
        await Timer(50*clkperiod, unit="us")
        set_bit_in_array(dut.ui_in, 4, 0) # REG_SCK = 0
    
    await Timer(50*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 3, 0) # REG_MOSI = 0
    await Timer(25*clkperiod, unit="us")
    # CSb = 1
    set_bit_in_array(dut.ui_in, 5, 1) # REG_CSb = 1


# Function to read data from `SPI-SLAVE` and compare it with `dtx` sent via SPI
async def spi_reg_trx_assert(dut, dtx, clkperiod):
    # CSb = 0
    set_bit_in_array(dut.ui_in, 5, 0) # REG_CSb = 0

    spi_slave_miso = []
    for i in range(16):
        await Timer(25*clkperiod, unit="us")
        set_bit_in_array(dut.ui_in, 3, int(dtx[i])) # REG_MOSI
        await Timer(25*clkperiod, unit="us")
        set_bit_in_array(dut.ui_in, 4, 1) # REG_SCK = 1
        aux = dut.uo_out.value # Get the output value in binary string format
        spi_slave_miso.append(str(aux[5])) # Get the value of REG_MISO and append it
        await Timer(50*clkperiod, unit="us")
        set_bit_in_array(dut.ui_in, 4, 0) # REG_SCK = 0
    
    await Timer(50*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 3, 0) # REG_MOSI = 0
    await Timer(25*clkperiod, unit="us")
    # CSb = 1
    set_bit_in_array(dut.ui_in, 5, 1) # REG_CSb = 1

    dout_value = "".join(spi_slave_miso)
    # Check if read-value is the same as sent-value
    dut._log.info("SPI_slave_miso_value: %s", dout_value)
    assert dout_value[7:0] == dtx[7:0] # Check if REG_MISO matches REG_MOSI value sent previous cycle.


# Function to set a specific bit in an array of bits (like ui_in)
def set_bit_in_array(array, index, bit_value):
    # bit_value should be 0 or 1
    aux = array.value
    aux[index] = bit_value
    array.value = aux 


# MCU SPI request
async def mcu_spi_request(dut, dtx, drx, clkperiod):
    # CSb = 0
    set_bit_in_array(dut.uio_in, 4, 0) # MCU_CSb = 0

    mcu_spi_drx = []
    for i in range(16):
        await Timer(5*clkperiod, unit="us")
        set_bit_in_array(dut.uio_in, 2, int(dtx[i])) # MCU_MOSI
        await Timer(5*clkperiod, unit="us")
        set_bit_in_array(dut.uio_in, 3, 1) # MCU_SCK = 1
        aux = dut.uo_out.value # Get the output value in binary string format
        mcu_spi_drx.append(str(aux[3])) # Get the value of MCU_MISO and append it
        await Timer(10*clkperiod, unit="us")
        set_bit_in_array(dut.uio_in, 3, 0) # MCU_SCK = 0
    
    await Timer(10*clkperiod, unit="us")
    set_bit_in_array(dut.uio_in, 2, 0) # MCU_MOSI = 0
    await Timer(5*clkperiod, unit="us")
    # CSb = 1
    set_bit_in_array(dut.uio_in, 4, 1) # MCU_CSb = 1

    dout_value = "".join(mcu_spi_drx)
    # Check if read-value is the same as expected value
    dut._log.info("MCU_SPI_DRX_value: %s", dout_value)
    assert dout_value == drx # Check if MCU_MISO matches expected FIFO_DOUT value sent previous cycle.

    await Timer(20*clkperiod, unit="us")



# RHD SPI request
async def rhd_data(dut, dtxa, dtxb, clkperiod):
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
        # RHD_MISO0a: bit i
        set_bit_in_array(dut.uio_in, 0, int(dtxa[i])) # RHD_MISO0a
        await Timer(1*clkperiod, unit="us") # one clock cycle
        # RHD_MISO0b: bit i
        set_bit_in_array(dut.uio_in, 0, int(dtxb[i])) # RHD_MISO0b
        await Timer(1*clkperiod, unit="us") # one clock cycle

    set_bit_in_array(dut.uio_in, 0, 0) # RHD_MISO = 0

    await Timer(10*clkperiod, unit="us")




# DUT Pin Mapping
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


# ******************************************************
# ******************************************************
# Test to verify the behavior of the project
# ******************************************************
# ******************************************************

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 0.02 us (50 MHz)
    clkperiod = 0.02 # in us
    clock = Clock(dut.clk, clkperiod, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    # ******************************************************
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    # Reset pulse
    # ******************************************************
    dut._log.info("Initial Reset Pulse")
    dut._log.info("rst_n = 0")
    await ClockCycles(dut.clk, 3)
    dut._log.info("rst_n = 1")
    dut.rst_n.value = 1


    # Initial values
    # ******************************************************
    set_bit_in_array(dut.ui_in, 0, 0) # SC_SDI = 0
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SC_CLK = 0
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 2, 0) # SC_SEN = 0
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 3, 0) # REG_MOSI = 0
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 4, 0) # REG_SCK = 0
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 5, 1) # REG_CSb = 1
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 6, 0) # SR_CLK = 0
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 7, 0) # SR_EN = 0
    await Timer(1*clkperiod, unit="us")

    set_bit_in_array(dut.uio_in, 4, 1) # MCU_CSb = 1
    await Timer(1*clkperiod, unit="us")

    # ******************************************************
    # START: SCANCHAIN + REGBANK
    # Set SELM0 = 1 to select the Scanchain to write values to the RegBank
    # ******************************************************
    dut._log.info("SELM0 = 1")
    set_bit_in_array(dut.uio_in, 5, 1) # SELM0 = 1
    
    dut._log.info("Starting Timer")
    await Timer(5*clkperiod, unit="us")
    dut._log.info("Awaiting for 5 clock cycles after reset")
    await Timer(0.5*clkperiod, unit="us") # half clock cycle

    dut._log.info("Test Writing/Reading RegBank through Scanchain")

    # Set the scanchain inputs
    sc_d0 = "00" + "000000" + "10000000"
    sc_d1 = "00" + "000001" + "10000001"
    sc_d2 = "00" + "000010" + "10000010"
    sc_d3 = "00" + "000011" + "10000011"

    # Shift in the input values bit by bit into the scanchain using SDI and SEN signals.
    # ******************************************************
    dut._log.info("Shift in the data into the scanchain")

    await Timer(50*clkperiod, unit="us")
    
    # Testing scanchain writing to RAM and reading same value from Shift Register.
    # ******************************************************

    # Send data via scanchain
    dtx = sc_d0
    await scanchain_tx(dut, dtx, clkperiod)
    # Read data via shift register
    await Timer(10*clkperiod, unit="us")
    await shift_register_read_assert(dut, clkperiod, dtx)
    
    await Timer(10*clkperiod, unit="us")

    # Send data via scanchain
    dtx = sc_d1
    await scanchain_tx(dut, dtx, clkperiod)
    # Read data via shift register
    await Timer(10*clkperiod, unit="us")
    await shift_register_read_assert(dut, clkperiod, dtx)
    
    await Timer(10*clkperiod, unit="us")

    # Send data via scanchain
    dtx = sc_d2
    await scanchain_tx(dut, dtx, clkperiod)
    # Read data via shift register
    await Timer(10*clkperiod, unit="us")
    await shift_register_read_assert(dut, clkperiod, dtx)
    

    await Timer(10*clkperiod, unit="us")
    # Send data via scanchain
    dtx = sc_d3
    await scanchain_tx(dut, dtx, clkperiod)
    # Read data via shift register
    await Timer(10*clkperiod, unit="us")
    await shift_register_read_assert(dut, clkperiod, dtx)
    
    # ******************************************************
    # END: SCANCHAIN + REGBANK
    # ******************************************************



    # ******************************************************
    # START: SPI + REGBANK
    # Set SELM0 = 0 to select the Scanchain to write values to the RegBank
    # ******************************************************

    dut._log.info("SELM0 = 0")
    set_bit_in_array(dut.uio_in, 5, 0) # SELM0 = 0
    await Timer(100*clkperiod, unit="us")
    dut._log.info("Test Writing/Reading RegBank through SPI")


    # Set the REG_SPI inputs
    reg_spi_d0 = "00" + "000000" + "10000100"
    reg_spi_d1 = "00" + "000001" + "10000101"
    reg_spi_d2 = "00" + "000010" + "10000110"
    reg_spi_d3 = "00" + "000011" + "00010100"


    dtx = reg_spi_d0
    # Send data
    await spi_reg_trx(dut, dtx, clkperiod)
    await Timer(100*clkperiod, unit="us")
    # Read data
    await spi_reg_trx_assert(dut, dtx, clkperiod)
    await Timer(100*clkperiod, unit="us")

    dtx = reg_spi_d1
    # Send data
    await spi_reg_trx(dut, dtx, clkperiod)
    await Timer(100*clkperiod, unit="us")
    # Read data
    await spi_reg_trx_assert(dut, dtx, clkperiod)
    await Timer(100*clkperiod, unit="us")

    dtx = reg_spi_d2
    # Send data
    await spi_reg_trx(dut, dtx, clkperiod)
    await Timer(100*clkperiod, unit="us")
    # Read data
    await spi_reg_trx_assert(dut, dtx, clkperiod)
    await Timer(100*clkperiod, unit="us")

    dtx = reg_spi_d3
    # Send data
    await spi_reg_trx(dut, dtx, clkperiod)
    await Timer(100*clkperiod, unit="us")
    # Read data
    await spi_reg_trx_assert(dut, dtx, clkperiod)
    await Timer(100*clkperiod, unit="us")

    # ******************************************************
    # END: SPI + REGBANK
    # ******************************************************


    # ******************************************************
    # START: MCU requests for data stored in FIFO
    # SELM0 = X
    # ******************************************************
    
    # Set SPI-RHD inputs (SPI1 inputs)
    spi1_miso_d0a = "11100111" + "11100111" # 16'he7e7
    spi1_miso_d0b = "10000001" + "10000001" # 16'h8181


    dtxa = spi1_miso_d0a
    dtxb = spi1_miso_d0b
    dtx = "10000000" + "00000001" # 16'h8001
    drx = "00000000" + "00000000" # 16'h0000
    for i in range(20):
        await mcu_spi_request(dut, dtx, drx, clkperiod)

    await rhd_data(dut, dtxa, dtxb, clkperiod)
    drx = "00000000" + "00000000" # 16'h0000
    await mcu_spi_request(dut, dtx, drx, clkperiod)
    await Timer(25*45*clkperiod, unit="us")
    await Timer(1*45*clkperiod, unit="us")

    drx = spi1_miso_d0a
    for i in range(20):
        await rhd_data(dut, dtxa, dtxb, clkperiod)
        await mcu_spi_request(dut, dtx, drx, clkperiod)
        await Timer(25*45*clkperiod, unit="us")
        await Timer(1*45*clkperiod, unit="us")




    # ******************************************************
    # END: MCU requests for data stored in FIFO
    # ******************************************************
    

    await Timer(1000*clkperiod, unit="us")

