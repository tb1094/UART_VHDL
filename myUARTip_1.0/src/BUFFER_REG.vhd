----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/21/2025 01:01:26 PM
-- Design Name: 
-- Module Name: BUFFER_REG - Behavioral
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

entity BUFFER_REG is
    Port ( CLK, RST : in STD_LOGIC;
           W_DATA : in STD_LOGIC_VECTOR (7 downto 0);
           R_DATA : out STD_LOGIC_VECTOR (7 downto 0);
           WR : in STD_LOGIC;
           RD : in STD_LOGIC;
           full : out STD_LOGIC;
           empty : out STD_LOGIC);
end BUFFER_REG;

architecture Behavioral of BUFFER_REG is

    signal DATA : std_logic_vector(7 downto 0);
    signal empty_sig : std_logic := '1';
    signal full_sig : std_logic := '0';

begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                DATA <= (others => '0');
                empty_sig <= '1';
                full_sig <= '0';
            else
                if RD = '1' and empty_sig = '0' then
                    full_sig <= '0';
                    empty_sig <= '1';
                elsif WR = '1' then -- data is overwritten if full
                    DATA <= W_DATA;
                    full_sig <= '1';
                    empty_sig <= '0';
                end if;
            end if;
        end if;
    end process;
    
    R_DATA <= DATA;
    
    full <= full_sig;
    empty <= empty_sig;

end Behavioral;
