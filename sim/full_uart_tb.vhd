----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/25/2025 10:06:58 AM
-- Design Name: 
-- Module Name: full_uart_tb - Behavioral
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

entity full_uart_tb is
--  Port ( );
end full_uart_tb;

architecture Behavioral of full_uart_tb is

    signal CLK : std_logic := '0';
    signal RST : std_logic := '0';
    signal TX_SIG : std_logic;
    signal RX_SIG : std_logic;
    signal R_DATA_SIG : std_logic_vector(7 downto 0);
    signal RD_UART_SIG : std_logic;
    signal RX_EMPTY_SIG : std_logic;
    signal W_DATA_SIG : std_logic_vector(7 downto 0);
    signal WR_UART_SIG : std_logic;
    signal TX_FULL_SIG : std_logic;
    
begin
    process
    begin
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
    end process;

    UUT_FULL_UART: entity work.FULL_UART
    PORT MAP(
        CLK => CLK,
        RST => RST,
        RX => RX_SIG,
        R_DATA => R_DATA_SIG,
        RD_UART => RD_UART_SIG,
        RX_EMPTY => RX_EMPTY_SIG,
        TX => TX_SIG,
        W_DATA => W_DATA_SIG,
        WR_UART => WR_UART_SIG,
        TX_FULL => TX_FULL_SIG
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
        -- send 0x55 over RX line
        send_byte(RX_SIG, "01010101", 104160 ns);
        wait for 104160 ns;
        RD_UART_SIG <= '1';
        wait for 15 ns;
        RD_UART_SIG <= '0';
        -- send 0xAA over RX line
        send_byte(RX_SIG, "10101010", 104160 ns);
        wait for 104160 ns;
        RD_UART_SIG <= '1';
        wait for 15 ns;
        RD_UART_SIG <= '0';
        wait for 100000 ns;
        -- tell TX to send 0x55
        W_DATA_SIG <= "01010101";
        WR_UART_SIG <= '1';
        wait for 15 ns;
        WR_UART_SIG <= '0';
        wait until TX_FULL_SIG = '0';
        -- tell TX to send 0x6B
        W_DATA_SIG <= "01101011";
        WR_UART_SIG <= '1';
        wait for 15 ns;
        WR_UART_SIG <= '0';
        wait until TX_FULL_SIG = '0';
        -- tell TX to send 0x00
        W_DATA_SIG <= "00000000";
        WR_UART_SIG <= '1';
        wait for 15 ns;
        WR_UART_SIG <= '0';
        wait;
    end process;


end Behavioral;
