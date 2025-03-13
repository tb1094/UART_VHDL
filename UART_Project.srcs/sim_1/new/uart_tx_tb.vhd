----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2025 08:28:34 AM
-- Design Name: 
-- Module Name: uart_tx_tb - Behavioral
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

entity uart_tx_tb is
--  Port ( );
end uart_tx_tb;

architecture Behavioral of uart_tx_tb is
    signal clk : std_logic;
    signal reset : std_logic;
    signal tx : std_logic;
    signal tx_start : std_logic;
    signal clk_div_rst : std_logic;
    signal done : std_logic;
    signal data_in : std_logic_vector(7 downto 0);
    
begin

    process
    begin
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
    end process;
    
    UUT_TX_TEST: entity work.TX_TEST
    PORT MAP(
        clk => clk,
        reset => reset,
        tx => tx,
        done => done
    );
    
    process
    begin
        --data_in <= "01010101";
        --wait for 10000 ns;
        --tx_start <= '1';
        --wait for 5000 ns;
        --tx_start <= '0';
        --wait for 20000 ns;
        --data_in <= "11001100";
        --wait for 10000 ns;
        --tx_start <= '1';
        --wait for 5000 ns;
        --tx_start <= '0';
        wait;
    end process;

end Behavioral;
