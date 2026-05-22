import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer

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

    # Set the clock period to 1 us (1 MHz)
    clkperiod = 1 # in us
    clock = Clock(dut.clk, clkperiod, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 1)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)
    await Timer(0.5*clkperiod, unit="us") # half clock cycle

    dut._log.info("Test project behavior")

    # Set the scanchain inputs for 0x1001100110011001
    din_value = "1001100110011001"
    dut._log.info("din_value: %s", din_value)

    # Shift in the input values bit by bit into the scanchain using SDI and SEN signals.
    dut._log.info("Shift in the data into the scanchain")

    set_bit_in_array(dut.ui_in, 1, 1) # SDI = 1
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SDI = 0
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SDI = 0
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SDI = 1
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SDI = 1
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SDI = 0
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SDI = 0
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SDI = 1
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SDI = 1
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SDI = 0
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SDI = 0
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SDI = 1
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SDI = 1
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SDI = 0
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 0) # SDI = 0
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 1, 1) # SDI = 1
    await Timer(1*clkperiod, unit="us")
    dut.ui_in.value = "00000001" # SDI = 0; SEN = 1
    await Timer(1*clkperiod, unit="us")
    set_bit_in_array(dut.ui_in, 0, 0) # SEN = 0

    # Assert if the parallel output of the scanchain is correct after shifting in the input values.
    dout_value = str(dut.dut.dout.value) # Get the dut.sdo value in binary string format
    dut._log.info("dout_value: %s", dout_value)

    assert dout_value == din_value # Check if the parallel output matches the input value.

    # continue with test by scanning out all bits
    await Timer(16*clkperiod, unit="us")

    # Verify the last value of SDO after scanning out all bits is Zero.
    aux = str(dut.uo_out.value) # Get the output value in binary string format
    sdo_last = int(aux[0]) # Get the last value of SDO
    dut._log.info("sdo_last: %d", sdo_last)

    assert sdo_last == 0 # Check if the last value of SDO is 0.

