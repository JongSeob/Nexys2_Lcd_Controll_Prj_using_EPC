//-----------------------------------------------------------------------------
// lmb_bram_elaborate.v
//-----------------------------------------------------------------------------

(* keep_hierarchy = "yes" *)
module lmb_bram_elaborate
  (
    BRAM_Rst_A,
    BRAM_Clk_A,
    BRAM_EN_A,
    BRAM_WEN_A,
    BRAM_Addr_A,
    BRAM_Din_A,
    BRAM_Dout_A,
    BRAM_Rst_B,
    BRAM_Clk_B,
    BRAM_EN_B,
    BRAM_WEN_B,
    BRAM_Addr_B,
    BRAM_Din_B,
    BRAM_Dout_B
  );
  parameter
    C_MEMSIZE = 'h8000,
    C_PORT_DWIDTH = 32,
    C_PORT_AWIDTH = 32,
    C_NUM_WE = 4,
    C_FAMILY = "spartan3e";
  input BRAM_Rst_A;
  input BRAM_Clk_A;
  input BRAM_EN_A;
  input [0:C_NUM_WE-1] BRAM_WEN_A;
  input [0:C_PORT_AWIDTH-1] BRAM_Addr_A;
  output [0:C_PORT_DWIDTH-1] BRAM_Din_A;
  input [0:C_PORT_DWIDTH-1] BRAM_Dout_A;
  input BRAM_Rst_B;
  input BRAM_Clk_B;
  input BRAM_EN_B;
  input [0:C_NUM_WE-1] BRAM_WEN_B;
  input [0:C_PORT_AWIDTH-1] BRAM_Addr_B;
  output [0:C_PORT_DWIDTH-1] BRAM_Din_B;
  input [0:C_PORT_DWIDTH-1] BRAM_Dout_B;

  // Internal signals

  wire [31:0] dina;
  wire [31:0] dinb;
  wire [31:0] douta;
  wire [31:0] doutb;

  // Internal assignments

  assign dina[31:0] = BRAM_Dout_A[0:31];
  assign BRAM_Din_A[0:31] = douta[31:0];
  assign dinb[31:0] = BRAM_Dout_B[0:31];
  assign BRAM_Din_B[0:31] = doutb[31:0];

  RAMB16_S2_S2
    #(
      .WRITE_MODE_A ( "WRITE_FIRST" ),
      .WRITE_MODE_B ( "WRITE_FIRST" )
    )
    ramb16_s2_s2_0 (
      .ADDRA ( BRAM_Addr_A[17:29] ),
      .CLKA ( BRAM_Clk_A ),
      .DIA ( dina[31:30] ),
      .DOA ( douta[31:30] ),
      .ENA ( BRAM_EN_A ),
      .SSRA ( BRAM_Rst_A ),
      .WEA ( BRAM_WEN_A[0] ),
      .ADDRB ( BRAM_Addr_B[17:29] ),
      .CLKB ( BRAM_Clk_B ),
      .DIB ( dinb[31:30] ),
      .DOB ( doutb[31:30] ),
      .ENB ( BRAM_EN_B ),
      .SSRB ( BRAM_Rst_B ),
      .WEB ( BRAM_WEN_B[0] )
    );

  RAMB16_S2_S2
    #(
      .WRITE_MODE_A ( "WRITE_FIRST" ),
      .WRITE_MODE_B ( "WRITE_FIRST" )
    )
    ramb16_s2_s2_1 (
      .ADDRA ( BRAM_Addr_A[17:29] ),
      .CLKA ( BRAM_Clk_A ),
      .DIA ( dina[29:28] ),
      .DOA ( douta[29:28] ),
      .ENA ( BRAM_EN_A ),
      .SSRA ( BRAM_Rst_A ),
      .WEA ( BRAM_WEN_A[0] ),
      .ADDRB ( BRAM_Addr_B[17:29] ),
      .CLKB ( BRAM_Clk_B ),
      .DIB ( dinb[29:28] ),
      .DOB ( doutb[29:28] ),
      .ENB ( BRAM_EN_B ),
      .SSRB ( BRAM_Rst_B ),
      .WEB ( BRAM_WEN_B[0] )
    );

  RAMB16_S2_S2
    #(
      .WRITE_MODE_A ( "WRITE_FIRST" ),
      .WRITE_MODE_B ( "WRITE_FIRST" )
    )
    ramb16_s2_s2_2 (
      .ADDRA ( BRAM_Addr_A[17:29] ),
      .CLKA ( BRAM_Clk_A ),
      .DIA ( dina[27:26] ),
      .DOA ( douta[27:26] ),
      .ENA ( BRAM_EN_A ),
      .SSRA ( BRAM_Rst_A ),
      .WEA ( BRAM_WEN_A[0] ),
      .ADDRB ( BRAM_Addr_B[17:29] ),
      .CLKB ( BRAM_Clk_B ),
      .DIB ( dinb[27:26] ),
      .DOB ( doutb[27:26] ),
      .ENB ( BRAM_EN_B ),
      .SSRB ( BRAM_Rst_B ),
      .WEB ( BRAM_WEN_B[0] )
    );

  RAMB16_S2_S2
    #(
      .WRITE_MODE_A ( "WRITE_FIRST" ),
      .WRITE_MODE_B ( "WRITE_FIRST" )
    )
    ramb16_s2_s2_3 (
      .ADDRA ( BRAM_Addr_A[17:29] ),
      .CLKA ( BRAM_Clk_A ),
      .DIA ( dina[25:24] ),
      .DOA ( douta[25:24] ),
      .ENA ( BRAM_EN_A ),
      .SSRA ( BRAM_Rst_A ),
      .WEA ( BRAM_WEN_A[0] ),
      .ADDRB ( BRAM_Addr_B[17:29] ),
      .CLKB ( BRAM_Clk_B ),
      .DIB ( dinb[25:24] ),
      .DOB ( doutb[25:24] ),
      .ENB ( BRAM_EN_B ),
      .SSRB ( BRAM_Rst_B ),
      .WEB ( BRAM_WEN_B[0] )
    );

  RAMB16_S2_S2
    #(
      .WRITE_MODE_A ( "WRITE_FIRST" ),
      .WRITE_MODE_B ( "WRITE_FIRST" )
    )
    ramb16_s2_s2_4 (
      .ADDRA ( BRAM_Addr_A[17:29] ),
      .CLKA ( BRAM_Clk_A ),
      .DIA ( dina[23:22] ),
      .DOA ( douta[23:22] ),
      .ENA ( BRAM_EN_A ),
      .SSRA ( BRAM_Rst_A ),
      .WEA ( BRAM_WEN_A[1] ),
      .ADDRB ( BRAM_Addr_B[17:29] ),
      .CLKB ( BRAM_Clk_B ),
      .DIB ( dinb[23:22] ),
      .DOB ( doutb[23:22] ),
      .ENB ( BRAM_EN_B ),
      .SSRB ( BRAM_Rst_B ),
      .WEB ( BRAM_WEN_B[1] )
    );

  RAMB16_S2_S2
    #(
      .WRITE_MODE_A ( "WRITE_FIRST" ),
      .WRITE_MODE_B ( "WRITE_FIRST" )
    )
    ramb16_s2_s2_5 (
      .ADDRA ( BRAM_Addr_A[17:29] ),
      .CLKA ( BRAM_Clk_A ),
      .DIA ( dina[21:20] ),
      .DOA ( douta[21:20] ),
      .ENA ( BRAM_EN_A ),
      .SSRA ( BRAM_Rst_A ),
      .WEA ( BRAM_WEN_A[1] ),
      .ADDRB ( BRAM_Addr_B[17:29] ),
      .CLKB ( BRAM_Clk_B ),
      .DIB ( dinb[21:20] ),
      .DOB ( doutb[21:20] ),
      .ENB ( BRAM_EN_B ),
      .SSRB ( BRAM_Rst_B ),
      .WEB ( BRAM_WEN_B[1] )
    );

  RAMB16_S2_S2
    #(
      .WRITE_MODE_A ( "WRITE_FIRST" ),
      .WRITE_MODE_B ( "WRITE_FIRST" )
    )
    ramb16_s2_s2_6 (
      .ADDRA ( BRAM_Addr_A[17:29] ),
      .CLKA ( BRAM_Clk_A ),
      .DIA ( dina[19:18] ),
      .DOA ( douta[19:18] ),
      .ENA ( BRAM_EN_A ),
      .SSRA ( BRAM_Rst_A ),
      .WEA ( BRAM_WEN_A[1] ),
      .ADDRB ( BRAM_Addr_B[17:29] ),
      .CLKB ( BRAM_Clk_B ),
      .DIB ( dinb[19:18] ),
      .DOB ( doutb[19:18] ),
      .ENB ( BRAM_EN_B ),
      .SSRB ( BRAM_Rst_B ),
      .WEB ( BRAM_WEN_B[1] )
    );

  RAMB16_S2_S2
    #(
      .WRITE_MODE_A ( "WRITE_FIRST" ),
      .WRITE_MODE_B ( "WRITE_FIRST" )
    )
    ramb16_s2_s2_7 (
      .ADDRA ( BRAM_Addr_A[17:29] ),
      .CLKA ( BRAM_Clk_A ),
      .DIA ( dina[17:16] ),
      .DOA ( douta[17:16] ),
      .ENA ( BRAM_EN_A ),
      .SSRA ( BRAM_Rst_A ),
      .WEA ( BRAM_WEN_A[1] ),
      .ADDRB ( BRAM_Addr_B[17:29] ),
      .CLKB ( BRAM_Clk_B ),
      .DIB ( dinb[17:16] ),
      .DOB ( doutb[17:16] ),
      .ENB ( BRAM_EN_B ),
      .SSRB ( BRAM_Rst_B ),
      .WEB ( BRAM_WEN_B[1] )
    );

  RAMB16_S2_S2
    #(
      .WRITE_MODE_A ( "WRITE_FIRST" ),
      .WRITE_MODE_B ( "WRITE_FIRST" )
    )
    ramb16_s2_s2_8 (
      .ADDRA ( BRAM_Addr_A[17:29] ),
      .CLKA ( BRAM_Clk_A ),
      .DIA ( dina[15:14] ),
      .DOA ( douta[15:14] ),
      .ENA ( BRAM_EN_A ),
      .SSRA ( BRAM_Rst_A ),
      .WEA ( BRAM_WEN_A[2] ),
      .ADDRB ( BRAM_Addr_B[17:29] ),
      .CLKB ( BRAM_Clk_B ),
      .DIB ( dinb[15:14] ),
      .DOB ( doutb[15:14] ),
      .ENB ( BRAM_EN_B ),
      .SSRB ( BRAM_Rst_B ),
      .WEB ( BRAM_WEN_B[2] )
    );

  RAMB16_S2_S2
    #(
      .WRITE_MODE_A ( "WRITE_FIRST" ),
      .WRITE_MODE_B ( "WRITE_FIRST" )
    )
    ramb16_s2_s2_9 (
      .ADDRA ( BRAM_Addr_A[17:29] ),
      .CLKA ( BRAM_Clk_A ),
      .DIA ( dina[13:12] ),
      .DOA ( douta[13:12] ),
      .ENA ( BRAM_EN_A ),
      .SSRA ( BRAM_Rst_A ),
      .WEA ( BRAM_WEN_A[2] ),
      .ADDRB ( BRAM_Addr_B[17:29] ),
      .CLKB ( BRAM_Clk_B ),
      .DIB ( dinb[13:12] ),
      .DOB ( doutb[13:12] ),
      .ENB ( BRAM_EN_B ),
      .SSRB ( BRAM_Rst_B ),
      .WEB ( BRAM_WEN_B[2] )
    );

  RAMB16_S2_S2
    #(
      .WRITE_MODE_A ( "WRITE_FIRST" ),
      .WRITE_MODE_B ( "WRITE_FIRST" )
    )
    ramb16_s2_s2_10 (
      .ADDRA ( BRAM_Addr_A[17:29] ),
      .CLKA ( BRAM_Clk_A ),
      .DIA ( dina[11:10] ),
      .DOA ( douta[11:10] ),
      .ENA ( BRAM_EN_A ),
      .SSRA ( BRAM_Rst_A ),
      .WEA ( BRAM_WEN_A[2] ),
      .ADDRB ( BRAM_Addr_B[17:29] ),
      .CLKB ( BRAM_Clk_B ),
      .DIB ( dinb[11:10] ),
      .DOB ( doutb[11:10] ),
      .ENB ( BRAM_EN_B ),
      .SSRB ( BRAM_Rst_B ),
      .WEB ( BRAM_WEN_B[2] )
    );

  RAMB16_S2_S2
    #(
      .WRITE_MODE_A ( "WRITE_FIRST" ),
      .WRITE_MODE_B ( "WRITE_FIRST" )
    )
    ramb16_s2_s2_11 (
      .ADDRA ( BRAM_Addr_A[17:29] ),
      .CLKA ( BRAM_Clk_A ),
      .DIA ( dina[9:8] ),
      .DOA ( douta[9:8] ),
      .ENA ( BRAM_EN_A ),
      .SSRA ( BRAM_Rst_A ),
      .WEA ( BRAM_WEN_A[2] ),
      .ADDRB ( BRAM_Addr_B[17:29] ),
      .CLKB ( BRAM_Clk_B ),
      .DIB ( dinb[9:8] ),
      .DOB ( doutb[9:8] ),
      .ENB ( BRAM_EN_B ),
      .SSRB ( BRAM_Rst_B ),
      .WEB ( BRAM_WEN_B[2] )
    );

  RAMB16_S2_S2
    #(
      .WRITE_MODE_A ( "WRITE_FIRST" ),
      .WRITE_MODE_B ( "WRITE_FIRST" )
    )
    ramb16_s2_s2_12 (
      .ADDRA ( BRAM_Addr_A[17:29] ),
      .CLKA ( BRAM_Clk_A ),
      .DIA ( dina[7:6] ),
      .DOA ( douta[7:6] ),
      .ENA ( BRAM_EN_A ),
      .SSRA ( BRAM_Rst_A ),
      .WEA ( BRAM_WEN_A[3] ),
      .ADDRB ( BRAM_Addr_B[17:29] ),
      .CLKB ( BRAM_Clk_B ),
      .DIB ( dinb[7:6] ),
      .DOB ( doutb[7:6] ),
      .ENB ( BRAM_EN_B ),
      .SSRB ( BRAM_Rst_B ),
      .WEB ( BRAM_WEN_B[3] )
    );

  RAMB16_S2_S2
    #(
      .WRITE_MODE_A ( "WRITE_FIRST" ),
      .WRITE_MODE_B ( "WRITE_FIRST" )
    )
    ramb16_s2_s2_13 (
      .ADDRA ( BRAM_Addr_A[17:29] ),
      .CLKA ( BRAM_Clk_A ),
      .DIA ( dina[5:4] ),
      .DOA ( douta[5:4] ),
      .ENA ( BRAM_EN_A ),
      .SSRA ( BRAM_Rst_A ),
      .WEA ( BRAM_WEN_A[3] ),
      .ADDRB ( BRAM_Addr_B[17:29] ),
      .CLKB ( BRAM_Clk_B ),
      .DIB ( dinb[5:4] ),
      .DOB ( doutb[5:4] ),
      .ENB ( BRAM_EN_B ),
      .SSRB ( BRAM_Rst_B ),
      .WEB ( BRAM_WEN_B[3] )
    );

  RAMB16_S2_S2
    #(
      .WRITE_MODE_A ( "WRITE_FIRST" ),
      .WRITE_MODE_B ( "WRITE_FIRST" )
    )
    ramb16_s2_s2_14 (
      .ADDRA ( BRAM_Addr_A[17:29] ),
      .CLKA ( BRAM_Clk_A ),
      .DIA ( dina[3:2] ),
      .DOA ( douta[3:2] ),
      .ENA ( BRAM_EN_A ),
      .SSRA ( BRAM_Rst_A ),
      .WEA ( BRAM_WEN_A[3] ),
      .ADDRB ( BRAM_Addr_B[17:29] ),
      .CLKB ( BRAM_Clk_B ),
      .DIB ( dinb[3:2] ),
      .DOB ( doutb[3:2] ),
      .ENB ( BRAM_EN_B ),
      .SSRB ( BRAM_Rst_B ),
      .WEB ( BRAM_WEN_B[3] )
    );

  RAMB16_S2_S2
    #(
      .WRITE_MODE_A ( "WRITE_FIRST" ),
      .WRITE_MODE_B ( "WRITE_FIRST" )
    )
    ramb16_s2_s2_15 (
      .ADDRA ( BRAM_Addr_A[17:29] ),
      .CLKA ( BRAM_Clk_A ),
      .DIA ( dina[1:0] ),
      .DOA ( douta[1:0] ),
      .ENA ( BRAM_EN_A ),
      .SSRA ( BRAM_Rst_A ),
      .WEA ( BRAM_WEN_A[3] ),
      .ADDRB ( BRAM_Addr_B[17:29] ),
      .CLKB ( BRAM_Clk_B ),
      .DIB ( dinb[1:0] ),
      .DOB ( doutb[1:0] ),
      .ENB ( BRAM_EN_B ),
      .SSRB ( BRAM_Rst_B ),
      .WEB ( BRAM_WEN_B[3] )
    );

endmodule

