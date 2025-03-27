# CIC Interpolator Implementation in Python and Verilog

This project implements a **CIC (Cascaded Integrator-Comb) interpolator**, designed using a parameterized approach in both **Python** and **Verilog**. The CIC filter is an efficient solution for increasing the sampling rate of a signal without requiring multipliers, making it ideal for digital signal processing applications such as software-defined radios and telecommunications.

## Features
- **CIC Filter Parameterization**: The design supports different interpolation factors, word widths, and the number of filter stages.
- **Efficient Hardware Implementation**: No multipliers are required, making it suitable for FPGA and ASIC applications.
- **Python Analysis**: The Python script provides visualization and coefficient generation for hardware implementation.
- **Verilog Implementation**: The filter is implemented in a fully parameterized Verilog module.

## Python Script
The Python script allows for configuring and analyzing the CIC interpolator. It provides:
- Calculation of required bit-width and scaling based on the filter order and interpolation factor.
- Frequency response visualization, including magnitude and phase plots.
- File generation for Verilog-compatible data signals and parameters.

## Verilog Implementation
The Verilog module `cic_int` implements the CIC interpolator with the following key features:

### Parameters
- `NBits`: Bit-width of the input and output signals.
- `width`: Internal bit-width for the filter registers (determined by interpolation factor and number of stages).
- `int_ratio`: Interpolation factor, defining the upsampling rate.
- `M`: Differential delay for the comb section.

### Inputs
- `clk`: Base clock signal.
- `clk_int`: Interpolated clock (higher frequency).
- `rst`: Reset signal to clear registers.
- `data_in`: Input data signal.

### Outputs
- `data_out`: Interpolated output signal.

### Processing Stages
1. **Comb Section**: Computes the difference between input samples delayed by `M` cycles.
2. **Zero Insertion**: Inserts zeros between upsampled data.
3. **Integrator Section**: Performs cumulative summation at the higher clock rate.

## How to Use
1. Configure the parameters in the Verilog file to match your desired interpolation factor and bit-width.
2. Run the Python script to analyze the filter response and generate necessary coefficients.
3. Integrate the Verilog module into your FPGA or ASIC design.

## License
This project is released under the MIT License.

## Author
[Your Name]

