//! @title CIC filter
//! @author J. I. Morales (morales.juan.ignacio@gmail.com)
//! @version 1.0
//! @date Simple CIC filter (N=1 sections, M=2 delays, R=1 interpolation factor)
//! width=bits de entrada+log2​(decimation ratio)×numero de etapas

`timescale 1ns / 1ps

module cic_dec
  #(
     parameter width  = 40,           //! Number of Bits
     parameter decimation_ratio  = 2  //! Number of Bits
   )
   (
     clk,
     rst,
     d_in,
     d_out,
     d_clk
   );

  input                        clk;          //! Clock
  input                        rst;          //! Reset
  input  wire signed  [15:0]   data_in;      //! Input data
  output  reg signed  [15:0]   data_out;     //! Output data
  output  reg 				         d_clk;

  // --------------------------------------------------------------- //
  //******************** Register Declarations **********************//
  // --------------------------------------------------------------- //
  reg signed [width-1:0] d_tmp, d_d_tmp;

  // Integrator stage registers
  reg signed [width-1:0] d1;
  reg signed [width-1:0] d2;
  reg signed [width-1:0] d3;

  // Comb stage registers
  reg signed [width-1:0] d4, d_d4;
  reg signed [width-1:0] d5, d_d5;
  reg signed [width-1:0] d6;

  reg [15:0] count;
  reg v_comb;  // Señal de validación para el comb
  reg d_clk_tmp;

  // --------------------------------------------------------------- //
  // ************************ Main Code  *************************** //
  // --------------------------------------------------------------- //

  always @(posedge clk)
  begin
    if (rst)
    begin
      d1 <= 0;
      d2 <= 0;
      d3 <= 0;
      count <= 0;
      v_comb <= 0;
    end
    else
    begin
      // Integrator section
      d1 <= d_in + d1;
      d2 <= d1 + d2;
      d3 <= d2 + d3;

      // Decimation
      if (count == decimation_ratio - 1)
      begin
        count <= 16'b0;
        d_tmp <= d3;
        d_clk_tmp <= 1'b1;
        v_comb <= 1'b1;
      end
      else
      begin
        count <= count + 16'd1;
        d_clk_tmp <= 1'b0;
        v_comb <= 1'b0;
      end
    end
  end

  always @(posedge clk)
  begin
    d_clk <= d_clk_tmp;
    if (rst)
    begin
      d4 <= 0;
      d_d4 <= 0;
      d5 <= 0;
      d_d5 <= 0;
      d6 <= 0;
      d_out <= 8'b0;
    end
    else if (v_comb)
    begin
      // Comb section
      d_d_tmp <= d_tmp;

      d4 <= d_tmp - d_d_tmp;
      d_d4 <= d4;

      d5 <= d4 - d_d4;
      d_d5 <= d5;

      d6 <= d5 - d_d5;

    // Ajuste de bits para salida de 16 bits
		d_out <= d6 >>> (width - 16);
    end
  end

endmodule
