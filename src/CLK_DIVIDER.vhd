----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/25/2024 10:08:14 PM
-- Design Name: 
-- Module Name: CLK_DIVIDER - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CLK_DIVIDER is
    Generic ( divider : NATURAL := 10416; -- 9600 baud
	          size : NATURAL := 16 );
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           CE : out STD_LOGIC);
end CLK_DIVIDER;

architecture Behavioral of CLK_DIVIDER is

    signal q : std_logic_vector (size-1 downto 0);

begin

	CE <= '1' when q = divider - 1 else '0';
	
	process (CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				q <= (others => '0');
			else
				if q < divider - 1 then
					q <= q + 1;
				else
					q <= (others => '0');
				end if;
			end if;
		end if;
	end process;

end Behavioral;
