----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2025 10:39:57 AM
-- Design Name: 
-- Module Name: uart_rx_tb - Behavioral
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

entity uart_rx_tb is
--  Port ( );
end uart_rx_tb;

architecture Behavioral of uart_rx_tb is

signal clk : std_logic;
    signal reset : std_logic;
    signal rx : std_logic;
    signal tx_start : std_logic;
    signal clk_div_rst : std_logic;
    signal done : std_logic;
    signal data : std_logic_vector(7 downto 0);
    
begin

    process
    begin
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
    end process;
    
    UUT_uart_rx: entity work.uart_rx
    PORT MAP(
        clk => clk,
        reset => reset,
        rx => rx,
        rx_done => done,
        rx_data => data
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