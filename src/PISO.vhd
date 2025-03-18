----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/25/2024 09:46:43 PM
-- Design Name: 
-- Module Name: PISO - Behavioral
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

entity PISO is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           SE : in STD_LOGIC;
           LOAD : in STD_LOGIC;
           PARALLEL_IN : in STD_LOGIC_VECTOR (9 downto 0);
           SERIAL_OUT : out STD_LOGIC);
end PISO;

architecture Behavioral of PISO is

    signal q: STD_LOGIC_VECTOR(9 downto 0) := "1111111111";

begin

	SERIAL_OUT <= q(0);

    process (CLK)
    begin
		if rising_edge(CLK) then
			if RST = '1' then
				q <= (others => '1');
			elsif LOAD = '1' then
                q <= PARALLEL_IN;
            elsif SE = '1' then
                q <= '1' & q(9 downto 1);
			end if;
		end if;
	end process;


end Behavioral;
