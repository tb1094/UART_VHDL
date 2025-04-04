----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2025 12:51:44 AM
-- Design Name: 
-- Module Name: UART_TX - Behavioral
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

entity UART_TX is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           DATA_RDY : in STD_LOGIC;
           DATA_IN : in STD_LOGIC_VECTOR (7 downto 0);
           DONE_OUT : out STD_LOGIC;
           TX : out STD_LOGIC);
end UART_TX;

architecture Behavioral of UART_TX is

    signal SE_SIG: std_logic;
    signal CLK_UART_SIG: std_logic;
    signal PISO_DATA_IN: std_logic_vector(9 downto 0);
    signal SHIFT_OUT_SIG: std_logic;
    signal LOAD_DATA_SIG: std_logic;
    signal RST_CLK_DIV_SIG: std_logic;
    
begin

    PISO_DATA_IN <= DATA_IN & "01";
    SE_SIG <= CLK_UART_SIG and SHIFT_OUT_SIG;

    PISO_Inst: entity work.PISO
    PORT MAP(
		CLK => CLK,
		RST => RST,
		SE => SE_SIG,
		LOAD => LOAD_DATA_SIG,
		PARALLEL_IN => PISO_DATA_IN,
		SERIAL_OUT => TX
	);
	
	CLK_DIVIDER_Inst: entity work.CLK_DIVIDER
    PORT MAP(
		CLK => CLK,
		RST => RST_CLK_DIV_SIG,
		CE => CLK_UART_SIG
	);
	
	UART_TX_FSM_Inst: entity work.UART_TX_FSM
    PORT MAP(
		CLK => CLK,
		RST => RST,
		CLK_UART => CLK_UART_SIG,
		DATA_RDY => DATA_RDY,
		DONE_OUT => DONE_OUT,
		SHIFT_OUT => SHIFT_OUT_SIG,
		LOAD_DATA => LOAD_DATA_SIG,
		RST_CLK_DIV => RST_CLK_DIV_SIG
	);

end Behavioral;
