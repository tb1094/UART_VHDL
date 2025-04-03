----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/17/2025 10:15:58 AM
-- Design Name: 
-- Module Name: UART_RX - Behavioral
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

entity UART_RX is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           RX : in STD_LOGIC;
           DONE : out STD_LOGIC;
           DATA : out STD_LOGIC_VECTOR (7 downto 0));
end UART_RX;

architecture Behavioral of UART_RX is

    signal CLK_UART_SIG: std_logic;
    signal SIPO_RST: std_logic;
    signal SIPO_SE: std_logic;
    signal RST_CLK_DIV_SIG: std_logic;
    signal RECEIVING_SIG: std_logic;

begin

    SIPO_RST <= RST or RST_CLK_DIV_SIG;
    SIPO_SE <= CLK_UART_SIG and RECEIVING_SIG;

    SIPO_Inst: entity work.SIPO
    PORT MAP(
		CLK => CLK,
		RST => RST,
		SE => SIPO_SE,
		SERIAL_IN => RX,
		PARALLEL_OUT => DATA
	);
	
	CLK_DIVIDER_RX_Inst: entity work.CLK_DIVIDER_RX
    PORT MAP(
		CLK => CLK,
		RST => RST_CLK_DIV_SIG,
		CE => CLK_UART_SIG
	);
	
	UART_RX_FSM_Inst: entity work.UART_RX_FSM
    PORT MAP(
		CLK => CLK,
		RST => RST,
		RX => RX,
		CLK_UART => CLK_UART_SIG,
		RST_CLK_DIV => RST_CLK_DIV_SIG,
		RECEIVING => RECEIVING_SIG,
		DONE_OUT => DONE
	);

end Behavioral;
