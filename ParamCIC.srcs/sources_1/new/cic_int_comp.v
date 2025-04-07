//! @title CIC interpolation filter with FIR compensation
//! @brief Parametrizable CIC filter (M delays, R interpolation factor, N sections) with FIR compensation
//! @author J. I. Morales (morales.juan.ignacio@gmail.com)
//! @version 1.2
//! @date 28/03/25
//! Calculo de Width = NBits + log2​(M × N)

`timescale 1ns / 1ps

module cic_int_comp
  #(
     parameter  NBits      = 16,                     //! Number of bits data signal
     parameter  NCoeff     = 86,                     //! Number of Coefficients FIR
     parameter  Coeff_File = "M86_coefficients.dat", //! Coefficients filename
     parameter  Width      = 20,                     //! Number of bits internal registers
     parameter  R          = 10,                     //! Interpolation ratio
     parameter  M          = 3,                      //! Number of delays
     parameter  N          = 3                       //! Number of sections
   )
   (
     clk,
     clk_int,
     rst,
     data_in,
     data_out
   );

  input                             clk;        //! Clock at frequency f_clk
  input                             clk_int;    //! Interpolation Clock (f_clk * R)
  input                             rst;        //! Reset
  input  wire signed  [NBits-1:0]   data_in;    //! Input data
  output wire signed  [NBits-1:0]   data_out;   //! Output data

  // --------------------------------------------------------------- //
  //********************** Wire Declarations ************************//
  // --------------------------------------------------------------- //
  wire signed [NBits-1:0]           fir_data_out;

  // --------------------------------------------------------------- //
  // ************************ Main Code  *************************** //
  // --------------------------------------------------------------- //

  fir_param #(
              // Parameters
              .NBits      (NBits),
              .NCoeff     (NCoeff),
              .Coeff_File (Coeff_File)
            ) fir_param_i (
              // Data Signals
              .data_out   (fir_data_out),
              .data_in    (data_in),
              // Control Signals
              .rst        (rst),
              .clk        (clk)
            );

  cic_int_param #(
                  // Parameters
                  .NBits      (NBits),
                  .Width      (Width),
                  .R          (R),
                  .M          (M),
                  .N          (N)
                ) cic_int_param_i (
                  // Control Signals
                  .rst        (rst),
                  .clk        (clk),
                  .clk_int    (clk_int),
                  // Data Signals
                  .data_in    (fir_data_out),
                  .data_out   (data_out)

                );


endmodule
