----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/18/2025 09:42:37 AM
-- Design Name: 
-- Module Name: echo_tb - Behavioral
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

entity echo_tb is
--  Port ( );
end echo_tb;

architecture Behavioral of echo_tb is
    signal CLK : std_logic := '0';
    signal RST : std_logic;
    signal TX_SIG : std_logic;
    signal RX_SIG : std_logic;
    signal DONE_SIG : std_logic;
    signal TX_START_SIG : std_logic;
begin
    process
    begin
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
    end process;

    UUT_UART_ECHO: entity work.UART_ECHO
    PORT MAP(
        CLK => CLK,
        RST => RST,
        TX => TX_SIG,
        RX => RX_SIG,
        DONE_OUT => DONE_SIG,
        TX_START => TX_START_SIG
    );
    
    process
    begin
        RX_SIG <= '1'; -- idle high
        wait for 416640 ns;
        RX_SIG <= '0'; -- start bit
        wait for 104160 ns;
        RX_SIG <= '1'; -- data bit 0
        wait for 104160 ns;
        RX_SIG <= '0';
        wait for 104160 ns;
        RX_SIG <= '1';
        wait for 104160 ns;
        RX_SIG <= '0';
        wait for 104160 ns;
        RX_SIG <= '1';
        wait for 104160 ns;
        RX_SIG <= '0';
        wait for 104160 ns;
        RX_SIG <= '1';
        wait for 104160 ns;
        RX_SIG <= '0'; -- data bit 7
        wait for 104160 ns;
        RX_SIG <= '1'; -- stop bit
        wait for 217056 ns;
        TX_START_SIG <= '1';
        wait for 10000 ns;
        TX_START_SIG <= '0';
        wait;
    end process;

end Behavioral;
