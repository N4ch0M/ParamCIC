//! @title CIC interpolation filter
//! @author J. I. Morales (morales.juan.ignacio@gmail.com)
//! @version 1.1
//! @date Parametrizable CIC filter (M delays, R interpolation factor, N sections)
//! Calculo de Width = NBits + log2​(M × N)

`timescale 1ns / 1ps

module cic_int_param
  #(
     parameter integer NBits  = 16,  //! Number of bits data signal
     parameter integer Width  = 20,  //! Number of bits internal registers
     parameter integer R      = 10,  //! Interpolation ratio
     parameter integer M      = 1,   //! Number of delays
     parameter integer N      = 3    //! Number of sections
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
  output  reg signed  [NBits-1:0]   data_out;   //! Output data

  // --------------------------------------------------------------- //
  //******************** Register Declarations **********************//
  // --------------------------------------------------------------- //
  
  //! Integers for loop control
  integer i, j;
  //! Shift registers for the COMB stage: M delays, N sections
  reg signed [Width-1:0]  shift_reg [0:N-1][0:M-1];
  //! Registers for the COMB stage: N sections
  reg signed [Width-1:0]  d_comb [0:N-1];
  //! Registers for the INTEGRATOR stage
  reg signed [Width-1:0]  d_int [0:N-1];
  //! Interpolation registers
  reg signed [Width-1:0]  d_sync;
  reg        [15:0]       count;
  reg                     v_interp;

  // --------------------------------------------------------------- //
  // ************************ Main Code  *************************** //
  // --------------------------------------------------------------- //

  //! Comb stage (operating at f_clk)
  always @(posedge clk)
  begin
    if (rst)
    begin
      for (i = 0; i < N; i = i + 1)
      begin
        d_comb[i] <= 0;
        for (j = 0; j < M; j = j + 1)
          shift_reg[i][j] <= 0;
      end
    end
    else
    begin
      // First stage shift register
      shift_reg[0][0] <= data_in;
      for (j = 1; j < M; j = j + 1)
        shift_reg[0][j] <= shift_reg[0][j-1];
      d_comb[0] <= data_in - shift_reg[0][M-1];

      // Generate the rest of the stages
      for (i = 1; i < N; i = i + 1)
      begin
        shift_reg[i][0] <= d_comb[i-1];
        for (j = 1; j < M; j = j + 1)
          shift_reg[i][j] <= shift_reg[i][j-1];
        d_comb[i] <= d_comb[i-1] - shift_reg[i][M-1];
      end
    end
  end

  //! Interpolation by R with zero insertion
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
        d_sync   <= d_comb[N-1];    // Comb stage output
        v_interp <= 1;
      end
      else
      begin
        count    <= count + 16'd1;
        d_sync   <= 0;              // Zero insertion
        v_interp <= 0;
      end
    end
  end

  //! Integration stage (operating at f_clk * R)
  always @(posedge clk_int)
  begin
    if (rst)
    begin
      for (i = 0; i < N; i = i + 1)
        d_int[i] <= 0;
      data_out <= 0;
    end
    else
    begin
      if (v_interp)
      begin
        // First stage integration
        d_int[0] <= d_int[0] + d_sync;

        // Generate the rest of the stages
        for (i = 1; i < N; i = i + 1)
        begin
          d_int[i] <= d_int[i] + d_int[i-1];
        end
      end

      // Scaled output
      data_out <= d_int[N-1] >>> (Width - NBits);
    end
  end

endmodule
