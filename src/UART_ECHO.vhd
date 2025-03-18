----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/29/2024 10:06:04 PM
-- Design Name: 
-- Module Name: UART_ECHO - Behavioral
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

entity UART_ECHO is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           RX : in STD_LOGIC;
           TX : out STD_LOGIC;
           DONE_OUT : out STD_LOGIC;
           TX_START : in STD_LOGIC);
end UART_ECHO;

architecture Behavioral of UART_ECHO is

    signal RX_DONE_SIG: std_logic;
    signal RX_DATA: std_logic_vector(7 downto 0);
    signal TX_DATA: std_logic_vector(7 downto 0);
    signal DATA: std_logic_vector(7 downto 0);
    signal TX_START_SIG: std_logic;

begin

    UART_TX_Inst: entity work.UART_TX
    PORT MAP(
		CLK => CLK,
		RST => RST,
		DATA_RDY => TX_START,
		DATA_IN => DATA,
		DONE_OUT => DONE_OUT,
		TX => TX
	);

    UART_RX_Inst: entity work.UART_RX
    PORT MAP(
		CLK => CLK,
		RST => RST,
		DONE => RX_DONE_SIG,
		DATA => DATA,
		RX => RX
	);
	
	process(CLK, RST)
    begin
        if RST = '1' then
            TX_START_SIG <= '0';
        elsif rising_edge(CLK) then
            if RX_DONE_SIG = '1' then
                TX_START_SIG <= '1';
            else
                TX_START_SIG <= '0';
            end if;
        end if;
    end process;


end Behavioral;
