//-------------------------------------------
//	FPGA Synthesizable Verilog Netlist
//	Description: Netlist Summary
//	Author: Xifan TANG
//	Organization: University of Utah
//	Date: Wed Nov 25 18:07:18 2026
//-------------------------------------------
//----- Time scale -----
`timescale 1ns / 1ps

// ------ Include fabric top-level netlists -----
`include "./SRC/fabric_netlists.v"

`include "counterup16_1clk_posedge_sync_resetp_output_verilog.v"

`include "./SRC/counterup16_1clk_posedge_sync_resetp_top_formal_verification.v"
`include "./SRC/counterup16_1clk_posedge_sync_resetp_formal_random_top_tb.v"
