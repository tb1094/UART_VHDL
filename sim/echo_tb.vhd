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
        TX => TX_SIG,
        RX => RX_SIG,
        DONE_OUT => DONE_SIG
    );
    
    process
        procedure send_byte(signal RX_SIG : out std_logic; data : in std_logic_vector(7 downto 0); bit_period : time) is
        begin
            RX_SIG <= '0'; -- start bit
            wait for bit_period;
        
            for i in 0 to 7 loop
                RX_SIG <= data(i);
                wait for bit_period;
            end loop;
        
            RX_SIG <= '1'; -- stop bit
            wait for bit_period;
        end procedure;
    begin
        RX_SIG <= '1'; -- idle high
        wait for 416640 ns;
        -- send 0x55
        send_byte(RX_SIG, "01010101", 104160 ns);
        wait for 104160 ns;
        -- send 0x00
        send_byte(RX_SIG, "00000000", 104160 ns);
        wait for 104160 ns;
        -- send 0x55
        send_byte(RX_SIG, "01011101", 104160 ns);
        wait for 104160 ns;
        -- send 0x55
        send_byte(RX_SIG, "01110100", 104160 ns);
        wait for 104160 ns;
        -- send 0x55
        send_byte(RX_SIG, "01010101", 104160 ns);
        wait for 104160 ns;
        -- send 0x55
        send_byte(RX_SIG, "11110101", 104160 ns);
        wait for 104160 ns;
        -- send 0x55
        send_byte(RX_SIG, "01010101", 104160 ns);
        wait for 104160 ns;
        -- send 0x55
        send_byte(RX_SIG, "01010101", 104160 ns);
        wait;
    end process;

end Behavioral;
