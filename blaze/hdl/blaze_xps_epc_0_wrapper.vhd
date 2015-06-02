-------------------------------------------------------------------------------
-- blaze_xps_epc_0_wrapper.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

library xps_epc_v1_02_a;
use xps_epc_v1_02_a.all;

entity blaze_xps_epc_0_wrapper is
  port (
    SPLB_Clk : in std_logic;
    SPLB_Rst : in std_logic;
    PLB_ABus : in std_logic_vector(0 to 31);
    PLB_PAValid : in std_logic;
    PLB_masterID : in std_logic_vector(0 to 0);
    PLB_RNW : in std_logic;
    PLB_BE : in std_logic_vector(0 to 3);
    PLB_size : in std_logic_vector(0 to 3);
    PLB_type : in std_logic_vector(0 to 2);
    PLB_wrDBus : in std_logic_vector(0 to 31);
    Sl_addrAck : out std_logic;
    Sl_SSize : out std_logic_vector(0 to 1);
    Sl_wait : out std_logic;
    Sl_rearbitrate : out std_logic;
    Sl_wrDAck : out std_logic;
    Sl_wrComp : out std_logic;
    Sl_rdDBus : out std_logic_vector(0 to 31);
    Sl_rdDAck : out std_logic;
    Sl_rdComp : out std_logic;
    Sl_MBusy : out std_logic_vector(0 to 1);
    Sl_MWrErr : out std_logic_vector(0 to 1);
    Sl_MRdErr : out std_logic_vector(0 to 1);
    PLB_UABus : in std_logic_vector(0 to 31);
    PLB_SAValid : in std_logic;
    PLB_rdPrim : in std_logic;
    PLB_wrPrim : in std_logic;
    PLB_abort : in std_logic;
    PLB_busLock : in std_logic;
    PLB_MSize : in std_logic_vector(0 to 1);
    PLB_lockErr : in std_logic;
    PLB_wrBurst : in std_logic;
    PLB_rdBurst : in std_logic;
    PLB_wrPendReq : in std_logic;
    PLB_rdPendReq : in std_logic;
    PLB_wrPendPri : in std_logic_vector(0 to 1);
    PLB_rdPendPri : in std_logic_vector(0 to 1);
    PLB_reqPri : in std_logic_vector(0 to 1);
    PLB_TAttribute : in std_logic_vector(0 to 15);
    Sl_wrBTerm : out std_logic;
    Sl_rdWdAddr : out std_logic_vector(0 to 3);
    Sl_rdBTerm : out std_logic;
    Sl_MIRQ : out std_logic_vector(0 to 1);
    PRH_Clk : in std_logic;
    PRH_Rst : in std_logic;
    PRH_CS_n : out std_logic_vector(0 to 1);
    PRH_Addr : out std_logic_vector(0 to 5);
    PRH_ADS : out std_logic;
    PRH_BE : out std_logic_vector(0 to 0);
    PRH_RNW : out std_logic;
    PRH_Rd_n : out std_logic;
    PRH_Wr_n : out std_logic;
    PRH_Burst : out std_logic;
    PRH_Rdy : in std_logic_vector(0 to 1);
    PRH_Data_I : in std_logic_vector(0 to 7);
    PRH_Data_O : out std_logic_vector(0 to 7);
    PRH_Data_T : out std_logic_vector(0 to 7)
  );

  attribute x_core_info : STRING;
  attribute x_core_info of blaze_xps_epc_0_wrapper : entity is "xps_epc_v1_02_a";

end blaze_xps_epc_0_wrapper;

architecture STRUCTURE of blaze_xps_epc_0_wrapper is

  component xps_epc is
    generic (
      C_SPLB_CLK_PERIOD_PS : INTEGER;
      C_PRH_CLK_PERIOD_PS : INTEGER;
      C_FAMILY : STRING;
      C_SPLB_AWIDTH : INTEGER;
      C_SPLB_DWIDTH : INTEGER;
      C_SPLB_P2P : INTEGER;
      C_SPLB_MID_WIDTH : INTEGER;
      C_SPLB_NUM_MASTERS : INTEGER;
      C_SPLB_NATIVE_DWIDTH : INTEGER;
      C_SPLB_SUPPORT_BURSTS : INTEGER;
      C_NUM_PERIPHERALS : INTEGER;
      C_PRH_MAX_AWIDTH : INTEGER;
      C_PRH_MAX_DWIDTH : INTEGER;
      C_PRH_MAX_ADWIDTH : INTEGER;
      C_PRH_CLK_SUPPORT : INTEGER;
      C_PRH_BURST_SUPPORT : INTEGER;
      C_PRH0_BASEADDR : std_logic_vector;
      C_PRH0_HIGHADDR : std_logic_vector;
      C_PRH0_FIFO_ACCESS : INTEGER;
      C_PRH0_FIFO_OFFSET : INTEGER;
      C_PRH0_AWIDTH : INTEGER;
      C_PRH0_DWIDTH : INTEGER;
      C_PRH0_DWIDTH_MATCH : INTEGER;
      C_PRH0_SYNC : INTEGER;
      C_PRH0_BUS_MULTIPLEX : INTEGER;
      C_PRH0_ADDR_TSU : INTEGER;
      C_PRH0_ADDR_TH : INTEGER;
      C_PRH0_ADS_WIDTH : INTEGER;
      C_PRH0_CSN_TSU : INTEGER;
      C_PRH0_CSN_TH : INTEGER;
      C_PRH0_WRN_WIDTH : INTEGER;
      C_PRH0_WR_CYCLE : INTEGER;
      C_PRH0_DATA_TSU : INTEGER;
      C_PRH0_DATA_TH : INTEGER;
      C_PRH0_RDN_WIDTH : INTEGER;
      C_PRH0_RD_CYCLE : INTEGER;
      C_PRH0_DATA_TOUT : INTEGER;
      C_PRH0_DATA_TINV : INTEGER;
      C_PRH0_RDY_TOUT : INTEGER;
      C_PRH0_RDY_WIDTH : INTEGER;
      C_PRH1_BASEADDR : std_logic_vector;
      C_PRH1_HIGHADDR : std_logic_vector;
      C_PRH1_FIFO_ACCESS : INTEGER;
      C_PRH1_FIFO_OFFSET : INTEGER;
      C_PRH1_AWIDTH : INTEGER;
      C_PRH1_DWIDTH : INTEGER;
      C_PRH1_DWIDTH_MATCH : INTEGER;
      C_PRH1_SYNC : INTEGER;
      C_PRH1_BUS_MULTIPLEX : INTEGER;
      C_PRH1_ADDR_TSU : INTEGER;
      C_PRH1_ADDR_TH : INTEGER;
      C_PRH1_ADS_WIDTH : INTEGER;
      C_PRH1_CSN_TSU : INTEGER;
      C_PRH1_CSN_TH : INTEGER;
      C_PRH1_WRN_WIDTH : INTEGER;
      C_PRH1_WR_CYCLE : INTEGER;
      C_PRH1_DATA_TSU : INTEGER;
      C_PRH1_DATA_TH : INTEGER;
      C_PRH1_RDN_WIDTH : INTEGER;
      C_PRH1_RD_CYCLE : INTEGER;
      C_PRH1_DATA_TOUT : INTEGER;
      C_PRH1_DATA_TINV : INTEGER;
      C_PRH1_RDY_TOUT : INTEGER;
      C_PRH1_RDY_WIDTH : INTEGER;
      C_PRH2_BASEADDR : std_logic_vector;
      C_PRH2_HIGHADDR : std_logic_vector;
      C_PRH2_FIFO_ACCESS : INTEGER;
      C_PRH2_FIFO_OFFSET : INTEGER;
      C_PRH2_AWIDTH : INTEGER;
      C_PRH2_DWIDTH : INTEGER;
      C_PRH2_DWIDTH_MATCH : INTEGER;
      C_PRH2_SYNC : INTEGER;
      C_PRH2_BUS_MULTIPLEX : INTEGER;
      C_PRH2_ADDR_TSU : INTEGER;
      C_PRH2_ADDR_TH : INTEGER;
      C_PRH2_ADS_WIDTH : INTEGER;
      C_PRH2_CSN_TSU : INTEGER;
      C_PRH2_CSN_TH : INTEGER;
      C_PRH2_WRN_WIDTH : INTEGER;
      C_PRH2_WR_CYCLE : INTEGER;
      C_PRH2_DATA_TSU : INTEGER;
      C_PRH2_DATA_TH : INTEGER;
      C_PRH2_RDN_WIDTH : INTEGER;
      C_PRH2_RD_CYCLE : INTEGER;
      C_PRH2_DATA_TOUT : INTEGER;
      C_PRH2_DATA_TINV : INTEGER;
      C_PRH2_RDY_TOUT : INTEGER;
      C_PRH2_RDY_WIDTH : INTEGER;
      C_PRH3_BASEADDR : std_logic_vector;
      C_PRH3_HIGHADDR : std_logic_vector;
      C_PRH3_FIFO_ACCESS : INTEGER;
      C_PRH3_FIFO_OFFSET : INTEGER;
      C_PRH3_AWIDTH : INTEGER;
      C_PRH3_DWIDTH : INTEGER;
      C_PRH3_DWIDTH_MATCH : INTEGER;
      C_PRH3_SYNC : INTEGER;
      C_PRH3_BUS_MULTIPLEX : INTEGER;
      C_PRH3_ADDR_TSU : INTEGER;
      C_PRH3_ADDR_TH : INTEGER;
      C_PRH3_ADS_WIDTH : INTEGER;
      C_PRH3_CSN_TSU : INTEGER;
      C_PRH3_CSN_TH : INTEGER;
      C_PRH3_WRN_WIDTH : INTEGER;
      C_PRH3_WR_CYCLE : INTEGER;
      C_PRH3_DATA_TSU : INTEGER;
      C_PRH3_DATA_TH : INTEGER;
      C_PRH3_RDN_WIDTH : INTEGER;
      C_PRH3_RD_CYCLE : INTEGER;
      C_PRH3_DATA_TOUT : INTEGER;
      C_PRH3_DATA_TINV : INTEGER;
      C_PRH3_RDY_TOUT : INTEGER;
      C_PRH3_RDY_WIDTH : INTEGER
    );
    port (
      SPLB_Clk : in std_logic;
      SPLB_Rst : in std_logic;
      PLB_ABus : in std_logic_vector(0 to (C_SPLB_AWIDTH-1));
      PLB_PAValid : in std_logic;
      PLB_masterID : in std_logic_vector(0 to (C_SPLB_MID_WIDTH-1));
      PLB_RNW : in std_logic;
      PLB_BE : in std_logic_vector(0 to ((C_SPLB_DWIDTH/8)-1));
      PLB_size : in std_logic_vector(0 to 3);
      PLB_type : in std_logic_vector(0 to 2);
      PLB_wrDBus : in std_logic_vector(0 to (C_SPLB_DWIDTH-1));
      Sl_addrAck : out std_logic;
      Sl_SSize : out std_logic_vector(0 to 1);
      Sl_wait : out std_logic;
      Sl_rearbitrate : out std_logic;
      Sl_wrDAck : out std_logic;
      Sl_wrComp : out std_logic;
      Sl_rdDBus : out std_logic_vector(0 to (C_SPLB_DWIDTH-1));
      Sl_rdDAck : out std_logic;
      Sl_rdComp : out std_logic;
      Sl_MBusy : out std_logic_vector(0 to (C_SPLB_NUM_MASTERS-1));
      Sl_MWrErr : out std_logic_vector(0 to (C_SPLB_NUM_MASTERS-1));
      Sl_MRdErr : out std_logic_vector(0 to (C_SPLB_NUM_MASTERS-1));
      PLB_UABus : in std_logic_vector(0 to 31);
      PLB_SAValid : in std_logic;
      PLB_rdPrim : in std_logic;
      PLB_wrPrim : in std_logic;
      PLB_abort : in std_logic;
      PLB_busLock : in std_logic;
      PLB_MSize : in std_logic_vector(0 to 1);
      PLB_lockErr : in std_logic;
      PLB_wrBurst : in std_logic;
      PLB_rdBurst : in std_logic;
      PLB_wrPendReq : in std_logic;
      PLB_rdPendReq : in std_logic;
      PLB_wrPendPri : in std_logic_vector(0 to 1);
      PLB_rdPendPri : in std_logic_vector(0 to 1);
      PLB_reqPri : in std_logic_vector(0 to 1);
      PLB_TAttribute : in std_logic_vector(0 to 15);
      Sl_wrBTerm : out std_logic;
      Sl_rdWdAddr : out std_logic_vector(0 to 3);
      Sl_rdBTerm : out std_logic;
      Sl_MIRQ : out std_logic_vector(0 to (C_SPLB_NUM_MASTERS-1));
      PRH_Clk : in std_logic;
      PRH_Rst : in std_logic;
      PRH_CS_n : out std_logic_vector(0 to (C_NUM_PERIPHERALS-1));
      PRH_Addr : out std_logic_vector(0 to (C_PRH_MAX_AWIDTH-1));
      PRH_ADS : out std_logic;
      PRH_BE : out std_logic_vector(0 to ((C_PRH_MAX_DWIDTH/8)-1));
      PRH_RNW : out std_logic;
      PRH_Rd_n : out std_logic;
      PRH_Wr_n : out std_logic;
      PRH_Burst : out std_logic;
      PRH_Rdy : in std_logic_vector(0 to (C_NUM_PERIPHERALS-1));
      PRH_Data_I : in std_logic_vector(0 to (C_PRH_MAX_ADWIDTH-1));
      PRH_Data_O : out std_logic_vector(0 to (C_PRH_MAX_ADWIDTH-1));
      PRH_Data_T : out std_logic_vector(0 to (C_PRH_MAX_ADWIDTH-1))
    );
  end component;

begin

  xps_epc_0 : xps_epc
    generic map (
      C_SPLB_CLK_PERIOD_PS => 20000,
      C_PRH_CLK_PERIOD_PS => 20000,
      C_FAMILY => "spartan3e",
      C_SPLB_AWIDTH => 32,
      C_SPLB_DWIDTH => 32,
      C_SPLB_P2P => 0,
      C_SPLB_MID_WIDTH => 1,
      C_SPLB_NUM_MASTERS => 2,
      C_SPLB_NATIVE_DWIDTH => 32,
      C_SPLB_SUPPORT_BURSTS => 0,
      C_NUM_PERIPHERALS => 2,
      C_PRH_MAX_AWIDTH => 6,
      C_PRH_MAX_DWIDTH => 8,
      C_PRH_MAX_ADWIDTH => 8,
      C_PRH_CLK_SUPPORT => 0,
      C_PRH_BURST_SUPPORT => 0,
      C_PRH0_BASEADDR => X"80800000",
      C_PRH0_HIGHADDR => X"80800007",
      C_PRH0_FIFO_ACCESS => 0,
      C_PRH0_FIFO_OFFSET => 0,
      C_PRH0_AWIDTH => 6,
      C_PRH0_DWIDTH => 8,
      C_PRH0_DWIDTH_MATCH => 0,
      C_PRH0_SYNC => 0,
      C_PRH0_BUS_MULTIPLEX => 0,
      C_PRH0_ADDR_TSU => 40000,
      C_PRH0_ADDR_TH => 30000,
      C_PRH0_ADS_WIDTH => 0,
      C_PRH0_CSN_TSU => 40000,
      C_PRH0_CSN_TH => 30000,
      C_PRH0_WRN_WIDTH => 30000,
      C_PRH0_WR_CYCLE => 60000,
      C_PRH0_DATA_TSU => 30000,
      C_PRH0_DATA_TH => 30000,
      C_PRH0_RDN_WIDTH => 30000,
      C_PRH0_RD_CYCLE => 60000,
      C_PRH0_DATA_TOUT => 15000,
      C_PRH0_DATA_TINV => 25000,
      C_PRH0_RDY_TOUT => 20000,
      C_PRH0_RDY_WIDTH => 120000,
      C_PRH1_BASEADDR => X"80800008",
      C_PRH1_HIGHADDR => X"8080000F",
      C_PRH1_FIFO_ACCESS => 0,
      C_PRH1_FIFO_OFFSET => 0,
      C_PRH1_AWIDTH => 6,
      C_PRH1_DWIDTH => 8,
      C_PRH1_DWIDTH_MATCH => 0,
      C_PRH1_SYNC => 0,
      C_PRH1_BUS_MULTIPLEX => 0,
      C_PRH1_ADDR_TSU => 40000,
      C_PRH1_ADDR_TH => 30000,
      C_PRH1_ADS_WIDTH => 0,
      C_PRH1_CSN_TSU => 40000,
      C_PRH1_CSN_TH => 30000,
      C_PRH1_WRN_WIDTH => 30000,
      C_PRH1_WR_CYCLE => 60000,
      C_PRH1_DATA_TSU => 30000,
      C_PRH1_DATA_TH => 30000,
      C_PRH1_RDN_WIDTH => 30000,
      C_PRH1_RD_CYCLE => 60000,
      C_PRH1_DATA_TOUT => 15000,
      C_PRH1_DATA_TINV => 25000,
      C_PRH1_RDY_TOUT => 20000,
      C_PRH1_RDY_WIDTH => 120000,
      C_PRH2_BASEADDR => X"ffffffff",
      C_PRH2_HIGHADDR => X"00000000",
      C_PRH2_FIFO_ACCESS => 0,
      C_PRH2_FIFO_OFFSET => 0,
      C_PRH2_AWIDTH => 32,
      C_PRH2_DWIDTH => 32,
      C_PRH2_DWIDTH_MATCH => 0,
      C_PRH2_SYNC => 1,
      C_PRH2_BUS_MULTIPLEX => 0,
      C_PRH2_ADDR_TSU => 0,
      C_PRH2_ADDR_TH => 0,
      C_PRH2_ADS_WIDTH => 0,
      C_PRH2_CSN_TSU => 0,
      C_PRH2_CSN_TH => 0,
      C_PRH2_WRN_WIDTH => 0,
      C_PRH2_WR_CYCLE => 0,
      C_PRH2_DATA_TSU => 0,
      C_PRH2_DATA_TH => 0,
      C_PRH2_RDN_WIDTH => 0,
      C_PRH2_RD_CYCLE => 0,
      C_PRH2_DATA_TOUT => 0,
      C_PRH2_DATA_TINV => 0,
      C_PRH2_RDY_TOUT => 0,
      C_PRH2_RDY_WIDTH => 0,
      C_PRH3_BASEADDR => X"ffffffff",
      C_PRH3_HIGHADDR => X"00000000",
      C_PRH3_FIFO_ACCESS => 0,
      C_PRH3_FIFO_OFFSET => 0,
      C_PRH3_AWIDTH => 32,
      C_PRH3_DWIDTH => 32,
      C_PRH3_DWIDTH_MATCH => 0,
      C_PRH3_SYNC => 1,
      C_PRH3_BUS_MULTIPLEX => 0,
      C_PRH3_ADDR_TSU => 0,
      C_PRH3_ADDR_TH => 0,
      C_PRH3_ADS_WIDTH => 0,
      C_PRH3_CSN_TSU => 0,
      C_PRH3_CSN_TH => 0,
      C_PRH3_WRN_WIDTH => 0,
      C_PRH3_WR_CYCLE => 0,
      C_PRH3_DATA_TSU => 0,
      C_PRH3_DATA_TH => 0,
      C_PRH3_RDN_WIDTH => 0,
      C_PRH3_RD_CYCLE => 0,
      C_PRH3_DATA_TOUT => 0,
      C_PRH3_DATA_TINV => 0,
      C_PRH3_RDY_TOUT => 0,
      C_PRH3_RDY_WIDTH => 0
    )
    port map (
      SPLB_Clk => SPLB_Clk,
      SPLB_Rst => SPLB_Rst,
      PLB_ABus => PLB_ABus,
      PLB_PAValid => PLB_PAValid,
      PLB_masterID => PLB_masterID,
      PLB_RNW => PLB_RNW,
      PLB_BE => PLB_BE,
      PLB_size => PLB_size,
      PLB_type => PLB_type,
      PLB_wrDBus => PLB_wrDBus,
      Sl_addrAck => Sl_addrAck,
      Sl_SSize => Sl_SSize,
      Sl_wait => Sl_wait,
      Sl_rearbitrate => Sl_rearbitrate,
      Sl_wrDAck => Sl_wrDAck,
      Sl_wrComp => Sl_wrComp,
      Sl_rdDBus => Sl_rdDBus,
      Sl_rdDAck => Sl_rdDAck,
      Sl_rdComp => Sl_rdComp,
      Sl_MBusy => Sl_MBusy,
      Sl_MWrErr => Sl_MWrErr,
      Sl_MRdErr => Sl_MRdErr,
      PLB_UABus => PLB_UABus,
      PLB_SAValid => PLB_SAValid,
      PLB_rdPrim => PLB_rdPrim,
      PLB_wrPrim => PLB_wrPrim,
      PLB_abort => PLB_abort,
      PLB_busLock => PLB_busLock,
      PLB_MSize => PLB_MSize,
      PLB_lockErr => PLB_lockErr,
      PLB_wrBurst => PLB_wrBurst,
      PLB_rdBurst => PLB_rdBurst,
      PLB_wrPendReq => PLB_wrPendReq,
      PLB_rdPendReq => PLB_rdPendReq,
      PLB_wrPendPri => PLB_wrPendPri,
      PLB_rdPendPri => PLB_rdPendPri,
      PLB_reqPri => PLB_reqPri,
      PLB_TAttribute => PLB_TAttribute,
      Sl_wrBTerm => Sl_wrBTerm,
      Sl_rdWdAddr => Sl_rdWdAddr,
      Sl_rdBTerm => Sl_rdBTerm,
      Sl_MIRQ => Sl_MIRQ,
      PRH_Clk => PRH_Clk,
      PRH_Rst => PRH_Rst,
      PRH_CS_n => PRH_CS_n,
      PRH_Addr => PRH_Addr,
      PRH_ADS => PRH_ADS,
      PRH_BE => PRH_BE,
      PRH_RNW => PRH_RNW,
      PRH_Rd_n => PRH_Rd_n,
      PRH_Wr_n => PRH_Wr_n,
      PRH_Burst => PRH_Burst,
      PRH_Rdy => PRH_Rdy,
      PRH_Data_I => PRH_Data_I,
      PRH_Data_O => PRH_Data_O,
      PRH_Data_T => PRH_Data_T
    );

end architecture STRUCTURE;

