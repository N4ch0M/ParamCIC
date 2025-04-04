//! @title Parameterized FIR filter
//! @author J. I. Morales (morales.juan.ignacio@gmail.com)
//! @version 1.1
//! @date Simple FIR filter with parameterized number of coefficients, signed data version

`timescale 1ns / 1ps

module fir_param
 #(
    parameter integer  NBits  = 24,                         //! Number of bits
    parameter integer  NCoeff = 14,                         //! Number of coefficients
    parameter   Coeff_File = "M14_coefficients.dat"  //! Coefficients filename
  ) 
  (
    data_out, 
    data_in,
    rst,      
    clk       
  );

    output  [NBits-1:0]   data_out;         //! Output data (signed)
    input   [NBits-1:0]   data_in;          //! Input data (signed)
    input                     rst;          //! Reset
    input                     clk;          //! Clock


    // --------------------------------------------------------------- //
    //******************** Register Declarations **********************//
    // --------------------------------------------------------------- //
    reg     signed [NBits-1:0]     register [NCoeff-1:0];  //! Matrix for signed Registers
    reg     signed [NBits-1:0]     coeff    [NCoeff-1:0];  //! Matrix for signed Coefficients
    reg     signed [NBits*2-1:0]   prod     [NCoeff-1:0];  //! Partial Products (to handle overflow)
    reg     signed [NBits*2+3:0]   sum;                    //! Accumulated Sum (to handle overflow)

    // --------------------------------------------------------------- //
    integer i;

    // --------------------------------------------------------------- //
    // ************************ Main Code  *************************** //
    // --------------------------------------------------------------- //

    // Coefficients init from file
    initial begin
        $readmemh(Coeff_File, coeff, 0, NCoeff-1);  
    end

    //! Shift Register and accumulation model
    always @(posedge clk) 
        begin
        if (rst) 
            begin
            for (i = 0; i < NCoeff; i = i + 1)
                begin
                register[i] <= {NBits{1'b0}};
                end
            sum <= {NBits*2{1'b0}};
            end  
        else 
            begin
            // Shift the input samples in the delay line
            for (i = NCoeff-1; i > 0; i = i - 1) 
                begin
                register[i] <= register[i-1];  
                end
            register[0] <= data_in; 
            
            // Perform the accumulation of products (blocking assignment)
            sum = {NBits*2+4{1'b0}}; 
            for (i = 0; i < NCoeff; i = i + 1) 
                begin
                sum = sum + (coeff[i] * register[i]);  
                end
            end
        end

    //! Output Adder Truncation (previous scaling amplitude)
    assign data_out = sum*(2**5) >>> (NBits + 4);  

    endmodule
