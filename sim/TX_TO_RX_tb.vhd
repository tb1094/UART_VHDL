----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/19/2025 12:25:46 PM
-- Design Name: 
-- Module Name: TX_TO_RX_tb - Behavioral
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

entity TX_TO_RX_tb is
--  Port ( );
end TX_TO_RX_tb;

architecture Behavioral of TX_TO_RX_tb is
    signal CLK : std_logic;
    signal TX_RX_SIG : std_logic;
begin

    process
    begin
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
    end process;
    
    UUT_TX_TO_RX: entity work.TX_TO_RX
    PORT MAP(
        CLK => CLK,
        TX_RX => TX_RX_SIG
    );

end Behavioral;
