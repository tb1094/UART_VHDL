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
           --RST : in STD_LOGIC;
           RX : in STD_LOGIC;
           TX : out STD_LOGIC;
           DONE_OUT : out STD_LOGIC);
end UART_ECHO;

architecture Behavioral of UART_ECHO is

    signal RX_DONE_SIG : std_logic;
    signal RX_DATA : std_logic_vector(7 downto 0);
    
    signal TX_START_SIG : std_logic;
    signal TX_DATA : std_logic_vector(7 downto 0);
    
    signal RST_SIG : std_logic := '1';
    signal counter : integer := 0;
    constant ON_CYCLES : integer := 10416;
    
    signal RX_1, RX_2 : std_logic;

begin

    UART_TX_Inst: entity work.UART_TX
    PORT MAP(
		CLK => CLK,
		RST => RST_SIG,
		DATA_RDY => TX_START_SIG,
		DATA_IN => TX_DATA,
		DONE_OUT => DONE_OUT,
		TX => TX
	);

    UART_RX_Inst: entity work.UART_RX
    PORT MAP(
		CLK => CLK,
		RST => RST_SIG,
		DONE => RX_DONE_SIG,
		DATA => RX_DATA,
		RX => RX_2
	);
	
	process(CLK)
	begin
	   if rising_edge(CLK) then
	       if (RST_SIG = '1') then
                RX_1 <= '1';
                RX_2 <= '1';
            else
                RX_1 <= RX;
                RX_2 <= RX_1;
            end if;
	   end if;
	end process;
	
	process(CLK)
	begin
	   if rising_edge(CLK) then
	       if counter < ON_CYCLES then
	           counter <= counter + 1;
	       else
	           RST_SIG <= '0';
	       end if;
	   end if;
	end process;
	
	-- when RX is done, transfer data from RX to TX and start TX
	process(RX_DONE_SIG)
	begin
	   if RX_DONE_SIG = '1' then
	       TX_DATA <= RX_DATA;
	       TX_START_SIG <= '1';
	   else
	       TX_DATA <= TX_DATA;
	       TX_START_SIG <= '0';
	   end if;
	end process;

end Behavioral;
