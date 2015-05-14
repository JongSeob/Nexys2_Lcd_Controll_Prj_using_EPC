//-----------------------------------------------------------------------------
// blaze_stub.v
//-----------------------------------------------------------------------------

module blaze_stub
  (
    fpga_0_LEDS_GPIO_IO_O_pin,
    fpga_0_DIP_Switches_GPIO_IO_I_pin,
    fpga_0_RS232_RX_pin,
    fpga_0_RS232_TX_pin,
    fpga_0_clk_1_sys_clk_pin,
    fpga_0_rst_1_sys_rst_pin,
    xps_epc_0_PRH_Addr_pin,
    xps_epc_0_PRH_CS_n_pin,
    xps_epc_0_PRH_Rd_n_pin,
    xps_epc_0_PRH_Wr_n_pin,
    xps_epc_0_PRH_Rdy_pin,
    xps_epc_0_PRH_BE_pin,
    xps_epc_0_PRH_Data_I_pin,
    xps_epc_0_PRH_Data_O_pin
  );
  output [0:7] fpga_0_LEDS_GPIO_IO_O_pin;
  input [0:7] fpga_0_DIP_Switches_GPIO_IO_I_pin;
  input fpga_0_RS232_RX_pin;
  output fpga_0_RS232_TX_pin;
  input fpga_0_clk_1_sys_clk_pin;
  input fpga_0_rst_1_sys_rst_pin;
  output [0:5] xps_epc_0_PRH_Addr_pin;
  output xps_epc_0_PRH_CS_n_pin;
  output xps_epc_0_PRH_Rd_n_pin;
  output xps_epc_0_PRH_Wr_n_pin;
  input xps_epc_0_PRH_Rdy_pin;
  output [0:3] xps_epc_0_PRH_BE_pin;
  input [0:31] xps_epc_0_PRH_Data_I_pin;
  output [0:31] xps_epc_0_PRH_Data_O_pin;

  (* BOX_TYPE = "user_black_box" *)
  blaze
    blaze_i (
      .fpga_0_LEDS_GPIO_IO_O_pin ( fpga_0_LEDS_GPIO_IO_O_pin ),
      .fpga_0_DIP_Switches_GPIO_IO_I_pin ( fpga_0_DIP_Switches_GPIO_IO_I_pin ),
      .fpga_0_RS232_RX_pin ( fpga_0_RS232_RX_pin ),
      .fpga_0_RS232_TX_pin ( fpga_0_RS232_TX_pin ),
      .fpga_0_clk_1_sys_clk_pin ( fpga_0_clk_1_sys_clk_pin ),
      .fpga_0_rst_1_sys_rst_pin ( fpga_0_rst_1_sys_rst_pin ),
      .xps_epc_0_PRH_Addr_pin ( xps_epc_0_PRH_Addr_pin ),
      .xps_epc_0_PRH_CS_n_pin ( xps_epc_0_PRH_CS_n_pin ),
      .xps_epc_0_PRH_Rd_n_pin ( xps_epc_0_PRH_Rd_n_pin ),
      .xps_epc_0_PRH_Wr_n_pin ( xps_epc_0_PRH_Wr_n_pin ),
      .xps_epc_0_PRH_Rdy_pin ( xps_epc_0_PRH_Rdy_pin ),
      .xps_epc_0_PRH_BE_pin ( xps_epc_0_PRH_BE_pin ),
      .xps_epc_0_PRH_Data_I_pin ( xps_epc_0_PRH_Data_I_pin ),
      .xps_epc_0_PRH_Data_O_pin ( xps_epc_0_PRH_Data_O_pin )
    );

endmodule

module blaze
  (
    fpga_0_LEDS_GPIO_IO_O_pin,
    fpga_0_DIP_Switches_GPIO_IO_I_pin,
    fpga_0_RS232_RX_pin,
    fpga_0_RS232_TX_pin,
    fpga_0_clk_1_sys_clk_pin,
    fpga_0_rst_1_sys_rst_pin,
    xps_epc_0_PRH_Addr_pin,
    xps_epc_0_PRH_CS_n_pin,
    xps_epc_0_PRH_Rd_n_pin,
    xps_epc_0_PRH_Wr_n_pin,
    xps_epc_0_PRH_Rdy_pin,
    xps_epc_0_PRH_BE_pin,
    xps_epc_0_PRH_Data_I_pin,
    xps_epc_0_PRH_Data_O_pin
  );
  output [0:7] fpga_0_LEDS_GPIO_IO_O_pin;
  input [0:7] fpga_0_DIP_Switches_GPIO_IO_I_pin;
  input fpga_0_RS232_RX_pin;
  output fpga_0_RS232_TX_pin;
  input fpga_0_clk_1_sys_clk_pin;
  input fpga_0_rst_1_sys_rst_pin;
  output [0:5] xps_epc_0_PRH_Addr_pin;
  output xps_epc_0_PRH_CS_n_pin;
  output xps_epc_0_PRH_Rd_n_pin;
  output xps_epc_0_PRH_Wr_n_pin;
  input xps_epc_0_PRH_Rdy_pin;
  output [0:3] xps_epc_0_PRH_BE_pin;
  input [0:31] xps_epc_0_PRH_Data_I_pin;
  output [0:31] xps_epc_0_PRH_Data_O_pin;
endmodule

