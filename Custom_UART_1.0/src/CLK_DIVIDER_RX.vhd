----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/17/2025 08:45:34 AM
-- Design Name: 
-- Module Name: CLK_DIVIDER_RX - Behavioral
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
use ieee.std_logic_arith.all;
use IEEE.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CLK_DIVIDER_RX is
    Generic ( divider : NATURAL := 10416; -- 9600 baud
	          size : NATURAL := 16 );
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           CE : out STD_LOGIC);
end CLK_DIVIDER_RX;

architecture Behavioral of CLK_DIVIDER_RX is

    signal q : std_logic_vector (size-1 downto 0);

begin

    CE <= '1' when q = divider - 1 else '0';
	
    process (CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                q <= '0' & conv_std_logic_vector(divider,size)(size-1 downto 1); -- q = divider/2
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
