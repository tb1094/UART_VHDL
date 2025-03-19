----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2025 01:16:18 PM
-- Design Name: 
-- Module Name: TX_tb - Behavioral
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

entity TX_tb is
--  Port ( );
end TX_tb;

architecture Behavioral of TX_tb is
    signal CLK : std_logic := '0';
    signal RST : std_logic;
    signal TX_RDY : std_logic;
    signal TX_DONE : std_logic;
    signal TX_DATA : std_logic_vector (7 downto 0);
    signal RX_DONE : std_logic;
    signal RX_DATA : std_logic_vector (7 downto 0);
    signal TX_RX_SIG : std_logic;
begin
    process
    begin
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
    end process;
    
    UUT_TX: entity work.UART_TX
    PORT MAP(
        CLK => CLK,
        RST => RST,
        DATA_RDY => TX_RDY,
        DATA_IN => TX_DATA,
        DONE_OUT => TX_DONE,
        TX => TX_RX_SIG
    );
    
    UUT_RX: entity work.UART_RX
    PORT MAP(
        CLK => CLK,
        RST => RST,
        DONE => RX_DONE,
        DATA => RX_DATA,
        RX => TX_RX_SIG
    );
    
    process
    begin
        wait for 718000 ns;
        TX_DATA <= "01010101";
        wait for 10000 ns;
        TX_RDY <= '1';
        wait for 30000 ns;
        TX_RDY <= '0';
        wait for 2000000 ns;
        TX_DATA <= "00000000";
        wait for 10000 ns;
        TX_RDY <= '1';
        wait for 30000 ns;
        TX_RDY <= '0';
        wait for 2000000 ns;
        TX_DATA <= "10010010";
        wait for 10000 ns;
        TX_RDY <= '1';
        wait for 30000 ns;
        TX_RDY <= '0';
        wait;
    end process;

end Behavioral;
