# Adder-uvm-arch

1. Adder (DUT) - add.sv
The DUT is a simple 4-bit synchronous adder that computes the sum of two 4-bit inputs (a and b) and produces a 5-bit output (sum). The addition is performed on the positive edge of the clock.

2. Interface - add_if.sv
The add_if interface defines the signals connecting the testbench to the DUT, including:

clk: Clock signal.
a, b: 4-bit input signals.
sum: 5-bit output signal.

3. Transaction Class - transaction.sv
The transaction class encapsulates the data for a single transaction, including:

Random cyclic inputs a and b (4-bit each, declared as randc).
Output sum (5-bit).
A display() function to print transaction details.
A copy() function to create a deep copy of the transaction object.

4. Generator Class - generator.sv
The generator class generates random transactions and sends them to the driver via a mailbox. Key features:

Randomizes a and b using trans.randomize().
Sends a copy of the transaction to the driver.
Uses an event (nxt) for handshaking with the driver.
Generates 10 transactions in a loop.
Signals completion using the done event.
5. Driver Class - driver.sv
The driver class receives transactions from the generator via the mailbox and drives them to the DUT through the interface. Key features:

Drives a and b to the DUT on the positive clock edge.
Captures the DUT's sum output after a small delay.
Triggers the next event for handshaking with the generator.
Displays transaction details for debugging.

6. Testbench - tb.sv
The testbench instantiates all components, connects them, and orchestrates the simulation. It:

Generates a clock signal with a 40ns period (always #20 aif.clk <= ~aif.clk).
Initializes the mailbox, generator, driver, and events.
Runs the generator and driver concurrently using a fork-join_none construct.
Waits for the done event to terminate the simulation.
Generates a VCD waveform file (dump.vcd) for analysis.
