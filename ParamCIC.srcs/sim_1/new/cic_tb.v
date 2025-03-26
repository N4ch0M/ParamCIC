//! @title Testbench CIC filter
//! @author J. I. Morales (morales.juan.ignacio@gmail.com)
//! @version 1.0
//! @date Testbench for the CIC filter

`timescale 1ns / 1ps

module cic_tb;

  // --------------------------------------------------------------- //
  //******************* Parameter Declarations **********************//
  // --------------------------------------------------------------- //
  parameter   NBits           = 16;
  parameter   width           = 19;
  parameter   dec_ratio       = 2;
  parameter   NData           = 2000;
  parameter   CLK_PERIOD      = 20;

  // --------------------------------------------------------------- //
  //******************** Register Declarations **********************//
  // --------------------------------------------------------------- //
  reg                         rst;                    //! Reset
  reg                         clk;                    //! Clock
  reg signed  [NBits-1:0]     data_mem[NData-1:0];    //! Input data
  reg         [11:0]          idx;                    //! Index to read the data

  // --------------------------------------------------------------- //
  //*********************** Wire Declarations ***********************//
  // --------------------------------------------------------------- //
  wire signed [NBits-1:0]     data_out;       //! Output data
  wire signed [NBits-1:0]     data_in;


  // --------------------------------------------------------------- //
  //*********************** DUT Instantiation ***********************//
  // --------------------------------------------------------------- //

  cic_dec #(
            // Parameters
            .NBits      (NBits),
            .width      (width),
            .dec_ratio  (dec_ratio)
          ) cic_dec_i (
            // Data Signals
            .data_out   (data_out),
            .data_in    (data_in),
            // Control Signals
            .rst        (rst),
            .clk        (clk),
            .d_clk      (d_clk)
          );

  initial
  begin

    // Read the data from the file
    $readmemh("input_signal_16bit.dat",data_mem,0,NData-1);

    // Initialize Inputs
    rst         = 1'b0;
    idx         = 1'b0;

    // Apply reset
    #(10*CLK_PERIOD);
    rst         = 1'b1;
    #(10*CLK_PERIOD);
    rst         = 1'b0;
    #(20*CLK_PERIOD);

    // Recorrer el vector `data_in` y alimentar el filtro
    for (idx = 0; idx < NData; idx = idx + 1)
    begin
      #CLK_PERIOD;
    end


    $finish;
  end

  assign data_in = data_mem[idx];


  //-------------------------- Generate Clock ------------------------------
  initial
    clk = 1'b1;

  always
    #(CLK_PERIOD/2) clk = !clk;

  //-------------------------- Signal Monitor ------------------------------
  initial
  begin
    $monitor("Time = %0t | data_in = %h | data_out = %h | rst = %b", $time, data_in, data_out, rst);
  end

endmodule
