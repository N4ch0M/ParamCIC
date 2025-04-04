//! @title CIC interpolation filter
//! @author J. I. Morales (morales.juan.ignacio@gmail.com)
//! @version 1.0
//! @date Simple CIC filter (M=3 delays, R=2 interpolation factor, N=3 sections)
//! Calculo de Width = NBits + log2​(M × N)

`timescale 1ns / 1ps

module cic_int
  #(
     parameter integer NBits  = 16,  //! Number of Bits data signal
     parameter integer Width  = 20,  //! Number of Bits registers
     parameter integer R      = 5,   //! Interpolation ratio
     parameter integer M      = 3    //! Number of delays
   )
   (
     clk,
     clk_int,
     rst,
     data_in,
     data_out
   );

  input                             clk;        //! Clock
  input                             clk_int;    //! Interpolation Clock (f_clk * R)
  input                             rst;        //! Reset
  input  wire signed  [NBits-1:0]   data_in;    //! Input data
  output  reg signed  [NBits-1:0]   data_out;   //! Output data

  // --------------------------------------------------------------- //
  //******************** Register Declarations **********************//
  // --------------------------------------------------------------- //

  // Shift registers for the delay of M cycles
  reg signed [Width-1:0]    shift_reg1 [0:M-1];
  reg signed [Width-1:0]    shift_reg2 [0:M-1];
  reg signed [Width-1:0]    shift_reg3 [0:M-1];

  // Comb stage registers
  reg signed [Width-1:0]    d1;
  reg signed [Width-1:0]    d2;
  reg signed [Width-1:0]    d3;

  // Integrator stage registers
  reg signed [Width-1:0]    d4;
  reg signed [Width-1:0]    d5;
  reg signed [Width-1:0]    d6;

  reg signed [Width-1:0]    d_sync;
  reg        [15:0]         count;
  reg                       v_interp;

  integer i;

  // --------------------------------------------------------------- //
  // ************************ Main Code  *************************** //
  // --------------------------------------------------------------- //

  always @(posedge clk)
  begin
    if (rst)
    begin
      d1           <= 0;
      d2           <= 0;
      d3           <= 0;
      // Inicialización de los shift registers
      for ( i = 0; i < M; i = i + 1)
      begin
        shift_reg1[i] <= 0;
        shift_reg2[i] <= 0;
        shift_reg3[i] <= 0;
      end
    end
    else
    begin
      // Shift register para el retardo M en la primera etapa
      shift_reg1[0] <= data_in;
      for ( i = 1; i < M; i = i + 1)
        shift_reg1[i] <= shift_reg1[i-1];

      d1 <= data_in - shift_reg1[M-1];

      // Shift register para el retardo M en la segunda etapa
      shift_reg2[0] <= d1;
      for ( i = 1; i < M; i = i + 1)
        shift_reg2[i] <= shift_reg2[i-1];

      d2 <= d1 - shift_reg2[M-1];

      // Shift register para el retardo M en la tercera etapa
      shift_reg3[0] <= d2;
      for ( i = 1; i < M; i = i + 1)
        shift_reg3[i] <= shift_reg3[i-1];

      d3 <= d2 - shift_reg3[M-1];

    end
  end

  // Interpolación x R e inserción de ceros
  always @(posedge clk_int)
  begin
    if (rst)
    begin
      d_sync   <= 0;
      v_interp <= 0;
      count    <= 0;
    end
    else
    begin
      if (count == R - 1)
      begin
        count    <= 0;
        d_sync   <= d3;  // Se toma la salida del comb
        v_interp <= 1;
      end
      else
      begin
        count    <= count + 16'd1;
        d_sync   <= 0;  // Insertar ceros
        v_interp <= 0;
      end
    end
  end

  // Sección de integración trabajando a clk_int
  always @(posedge clk_int)
  begin
    if (rst)
    begin
      d4    <= 0;
      d5    <= 0;
      d6    <= 0;
      data_out <= 0;
    end
    else
    begin
      if (v_interp)
      begin
        d4    <= d4 + d_sync;
        d5    <= d5 + d4;
        d6    <= d6 + d5;
      end

      data_out <= d6 >>> (Width - NBits);
    end
  end


endmodule
