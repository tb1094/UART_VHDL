----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2025 02:51:34 PM
-- Design Name: 
-- Module Name: clk_divider - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clk_divider is
    Generic ( divider : NATURAL := 10416; -- 9600 Hz from 100 MHz clock
	          size : NATURAL := 14 );
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           CE : out STD_LOGIC); -- clock enable signal
end clk_divider;

architecture Behavioral of clk_divider is

    signal q : std_logic_vector (size-1 downto 0);

begin

	CE <= '1' when q = divider else '0';
	
	process (CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				q <= (others => '0');
			else
				if q < divider then
					q <= q + 1;
				else
					q <= (others => '0');
				end if;
			end if;
		end if;
	end process;

end Behavioral;