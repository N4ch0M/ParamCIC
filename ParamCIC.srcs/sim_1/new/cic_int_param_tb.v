//! @title Testbench CIC filter
//! @author J. I. Morales (morales.juan.ignacio@gmail.com)
//! @version 1.0
//! @date Testbench for the CIC filter

`timescale 1ns / 1ps

module cic_int_param_tb;

  // --------------------------------------------------------------- //
  //******************* Parameter Declarations **********************//
  // --------------------------------------------------------------- //
  parameter integer   NBits           = 16;
  parameter integer   Width           = 19;
  parameter integer   R               = 10;
  parameter integer   M               = 2;
  parameter integer   N               = 3;
  parameter integer   NData           = 500;
  parameter integer   CLK_PERIOD      = 40;
  parameter integer   CLK_INT_PERIOD  = CLK_PERIOD/R;

  // --------------------------------------------------------------- //
  //******************** Register Declarations **********************//
  // --------------------------------------------------------------- //
  reg                         rst;                    //! Reset
  reg                         clk;                    //! Clock
  reg                         clk_int;                //! Interpolation Clock
  reg signed  [NBits-1:0]     data_mem[0:NData-1];    //! Mem data
  reg         [11:0]          idx;                    //! Index to read the data

  // --------------------------------------------------------------- //
  //*********************** Wire Declarations ***********************//
  // --------------------------------------------------------------- //
  wire signed [NBits-1:0]     data_out;     //! Output data
  wire signed [NBits-1:0]     data_in;      //! Input data

  // --------------------------------------------------------------- //
  //*********************** DUT Instantiation ***********************//
  // --------------------------------------------------------------- //

  cic_int_param #(
                  // Parameters
                  .NBits      (NBits),
                  .Width      (Width),
                  .R          (R),
                  .M          (M),
                  .N          (N)
                ) cic_int_param_i (
                  // Data Signals
                  .data_out   (data_out),
                  .data_in    (data_in),
                  // Control Signals
                  .rst        (rst),
                  .clk        (clk),
                  .clk_int    (clk_int)
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

    // Scan data_in and feed the filter
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

  //-------------------- Generate Interpolation Clock ----------------------
  initial
    clk_int = 1'b1;
  always
    #(CLK_INT_PERIOD/2) clk_int = !clk_int;

  //-------------------------- Signal Monitor ------------------------------
  initial
  begin
    $monitor("Time = %0t | data_in = %h | data_out = %h | rst = %b",
             $time, data_in, data_out, rst);
  end

endmodule
