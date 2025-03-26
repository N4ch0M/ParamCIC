//! @title CIC filter
//! @author J. I. Morales (morales.juan.ignacio@gmail.com)
//! @version 1.0
//! @date Simple CIC filter (M=2 delays, R=2 decimation factor, N=3 sections)
//! width=bits de entrada+log2​(decimation ratio)×numero de etapas

`timescale 1ns / 1ps

module cic_dec
  #(
     parameter NBits     = 16,  //! Number of Bits data signal
     parameter width     = 19,  //! Number of Bits registers
     parameter dec_ratio = 2    //! Decimation ratio
   )
   (
     clk,
     rst,
     data_in,
     data_out,
     d_clk
   );

  input                             clk;        //! Clock
  input                             rst;        //! Reset
  input  wire signed  [NBits-1:0]   data_in;    //! Input data
  output  reg signed  [NBits-1:0]   data_out;   //! Output data
  output  reg 				        d_clk;      //! Decimated Clock

  // --------------------------------------------------------------- //
  //******************** Register Declarations **********************//
  // --------------------------------------------------------------- //
  reg signed [width-1:0]    d_tmp, d_d_tmp;

  // Integrator stage registers
  reg signed [width-1:0]    d1;
  reg signed [width-1:0]    d2;
  reg signed [width-1:0]    d3;

  // Comb stage registers
  reg signed [width-1:0]    d4, d_d4;
  reg signed [width-1:0]    d5, d_d5;
  reg signed [width-1:0]    d6, d_d6;

  reg        [15:0]         count;
  reg                       v_comb;
  reg                       d_clk_tmp;

  // --------------------------------------------------------------- //
  // ************************ Main Code  *************************** //
  // --------------------------------------------------------------- //

  always @(posedge clk)
  begin
    if (rst)
    begin
      d1    <= 0;
      d2    <= 0;
      d3    <= 0;
      count <= 0;
      v_comb <= 0;
    end
    else
    begin
      // Integrator section
      d1    <= data_in + d1;
      d2    <= d1 + d2;
      d3    <= d2 + d3;

      // Decimation
      if (count == dec_ratio - 1)
      begin
        count       <= 16'b0;
        d_tmp       <= d3;
        d_clk_tmp   <= 1'b1;
        v_comb      <= 1'b1;
      end
      else
      begin
        count       <= count + 16'd1;
        d_clk_tmp   <= 1'b0;
        v_comb      <= 1'b0;
      end
    end
  end

  always @(posedge clk)
  begin
    d_clk <= d_clk_tmp;
    if (rst)
    begin
      d4    <= 0;
      d_d4  <= 0;
      d5    <= 0;
      d_d5  <= 0;
      d6    <= 0;
      d_d6  <= 0;
      data_out <= 8'b0;
    end
    else if (v_comb)
    begin
      d_d_tmp <= d_tmp;
      d4    <= d_tmp - d_d_tmp;
      d_d4  <= d4;
      d5    <= d4 - d_d4;
      d_d5  <= d5;
      d6    <= d5 - d_d5;

      // Output with adjusted bit shift for NBits output
      data_out <= d6 >>> (width - NBits);
    end
  end

endmodule
