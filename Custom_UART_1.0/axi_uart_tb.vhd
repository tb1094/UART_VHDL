----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/02/2025 10:08:18 AM
-- Design Name: 
-- Module Name: axi_uart_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity axi_uart_tb is
--  Port ( );
end axi_uart_tb;

architecture Behavioral of axi_uart_tb is

-- Component under test
    component Custom_UART_v1_0
        generic (
            C_S_AXI_DATA_WIDTH : integer := 32;
            C_S_AXI_ADDR_WIDTH : integer := 4;
            C_S_AXI_INTR_DATA_WIDTH : integer := 32;
            C_S_AXI_INTR_ADDR_WIDTH : integer := 5;
            C_NUM_OF_INTR : integer := 1;
            C_INTR_SENSITIVITY : std_logic_vector := x"FFFFFFFF";
            C_INTR_ACTIVE_STATE : std_logic_vector := x"FFFFFFFF";
            C_IRQ_SENSITIVITY : integer := 1;
            C_IRQ_ACTIVE_STATE : integer := 1
        );
        port (
            RX : in std_logic;
            TX : out std_logic;
            s_axi_aclk : in std_logic;
            s_axi_aresetn : in std_logic;
            s_axi_awaddr : in std_logic_vector(3 downto 0);
            s_axi_awprot : in std_logic_vector(2 downto 0);
            s_axi_awvalid : in std_logic;
            s_axi_awready : out std_logic;
            s_axi_wdata : in std_logic_vector(31 downto 0);
            s_axi_wstrb : in std_logic_vector(3 downto 0);
            s_axi_wvalid : in std_logic;
            s_axi_wready : out std_logic;
            s_axi_bresp : out std_logic_vector(1 downto 0);
            s_axi_bvalid : out std_logic;
            s_axi_bready : in std_logic;
            s_axi_araddr : in std_logic_vector(3 downto 0);
            s_axi_arprot : in std_logic_vector(2 downto 0);
            s_axi_arvalid : in std_logic;
            s_axi_arready : out std_logic;
            s_axi_rdata : out std_logic_vector(31 downto 0);
            s_axi_rresp : out std_logic_vector(1 downto 0);
            s_axi_rvalid : out std_logic;
            s_axi_rready : in std_logic;
            s_axi_intr_aclk : in std_logic := '0';
            s_axi_intr_aresetn : in std_logic := '0';
            s_axi_intr_awaddr : in std_logic_vector(4 downto 0) := (others => '0');
            s_axi_intr_awprot : in std_logic_vector(2 downto 0) := (others => '0');
            s_axi_intr_awvalid : in std_logic := '0';
            s_axi_intr_awready : out std_logic;
            s_axi_intr_wdata : in std_logic_vector(31 downto 0) := (others => '0');
            s_axi_intr_wstrb : in std_logic_vector(3 downto 0) := (others => '0');
            s_axi_intr_wvalid : in std_logic := '0';
            s_axi_intr_wready : out std_logic;
            s_axi_intr_bresp : out std_logic_vector(1 downto 0);
            s_axi_intr_bvalid : out std_logic;
            s_axi_intr_bready : in std_logic := '0';
            s_axi_intr_araddr : in std_logic_vector(4 downto 0) := (others => '0');
            s_axi_intr_arprot : in std_logic_vector(2 downto 0) := (others => '0');
            s_axi_intr_arvalid : in std_logic := '0';
            s_axi_intr_arready : out std_logic;
            s_axi_intr_rdata : out std_logic_vector(31 downto 0);
            s_axi_intr_rresp : out std_logic_vector(1 downto 0);
            s_axi_intr_rvalid : out std_logic;
            s_axi_intr_rready : in std_logic := '0';
            irq : out std_logic
        );
    end component;

    -- Signals
    signal clk    : std_logic := '0';
    signal rstn   : std_logic := '0';

    -- AXI Lite signals
    signal awaddr, araddr : std_logic_vector(3 downto 0) := (others => '0');
    signal awprot, arprot : std_logic_vector(2 downto 0) := (others => '0');
    signal awvalid, wvalid, bready, arvalid, rready : std_logic := '0';
    signal awready, wready, bvalid, arready, rvalid : std_logic;
    signal wdata : std_logic_vector(31 downto 0) := (others => '0');
    signal wstrb : std_logic_vector(3 downto 0) := (others => '1');
    signal bresp, rresp : std_logic_vector(1 downto 0);
    signal rdata : std_logic_vector(31 downto 0);

    signal RX : std_logic := '1';
    signal TX : std_logic;

begin

    -- Clock process
    clk_proc : process
    begin
        clk <= '1'; 
        wait for 5 ns;
        clk <= '0'; 
        wait for 5 ns;
    end process;

    -- Reset process
    rst_proc : process
    begin
        rstn <= '0';
        wait for 20 ns;
        rstn <= '1';
        wait;
    end process;

    -- DUT instantiation
    DUT : Custom_UART_v1_0
        generic map (
            C_S_AXI_DATA_WIDTH => 32,
            C_S_AXI_ADDR_WIDTH => 4,
            C_S_AXI_INTR_DATA_WIDTH => 32,
            C_S_AXI_INTR_ADDR_WIDTH => 5,
            C_NUM_OF_INTR => 1,
            C_INTR_SENSITIVITY => x"FFFFFFFF",
            C_INTR_ACTIVE_STATE => x"FFFFFFFF",
            C_IRQ_SENSITIVITY => 1,
            C_IRQ_ACTIVE_STATE => 1
        )
        port map (
            RX => RX,
            TX => TX,
            s_axi_aclk => clk,
            s_axi_aresetn => rstn,
            s_axi_awaddr => awaddr,
            s_axi_awprot => awprot,
            s_axi_awvalid => awvalid,
            s_axi_awready => awready,
            s_axi_wdata => wdata,
            s_axi_wstrb => wstrb,
            s_axi_wvalid => wvalid,
            s_axi_wready => wready,
            s_axi_bresp => bresp,
            s_axi_bvalid => bvalid,
            s_axi_bready => bready,
            s_axi_araddr => araddr,
            s_axi_arprot => arprot,
            s_axi_arvalid => arvalid,
            s_axi_arready => arready,
            s_axi_rdata => rdata,
            s_axi_rresp => rresp,
            s_axi_rvalid => rvalid,
            s_axi_rready => rready
        );

    process
        procedure send_byte(signal RX_SIG : out std_logic; data : in std_logic_vector(7 downto 0); bit_period : time) is
        begin
            RX_SIG <= '0'; -- start bit
            wait for bit_period;
        
            for i in 0 to 7 loop
                RX_SIG <= data(i);
                wait for bit_period;
            end loop;
        
            RX_SIG <= '1'; -- stop bit
            wait for bit_period;
        end procedure;
    begin
        wait until rstn = '1';
        wait for 416640 ns;
        -- send 0x55 over RX line
        send_byte(RX, "01010101", 104160 ns);
        wait;
    end process;


end Behavioral;
