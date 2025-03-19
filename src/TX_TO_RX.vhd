----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/19/2025 10:57:53 AM
-- Design Name: 
-- Module Name: TX_TO_RX - Behavioral
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

entity TX_TO_RX is
    Port ( CLK : in STD_LOGIC
           );
end TX_TO_RX;

architecture Behavioral of TX_TO_RX is
    signal RST_SIG : std_logic;
    
    signal TX_RDY_SIG : std_logic;
    signal TX_DATA : std_logic_vector(7 downto 0);
    signal TX_DONE_SIG : std_logic;
    
    signal RX_DONE_SIG : std_logic;
    signal RX_DATA : std_logic_vector(7 downto 0);
    
    signal counter : integer := 0;
    constant ON_CYCLES  : integer := 1000;
    constant OFF_CYCLES : integer := 200000;
    constant PERIOD     : integer := ON_CYCLES + OFF_CYCLES;
    
    signal TX_RX : std_logic;
begin

    TX_DATA <= "01010101";

    TX_INST: entity work.UART_TX
    PORT MAP(
        CLK => CLK,
        RST => RST_SIG,
        DATA_RDY => TX_RDY_SIG,
        DATA_IN => TX_DATA,
        DONE_OUT => TX_DONE_SIG,
        TX => TX_RX
    );
    
    RX_INST: entity work.UART_RX
    PORT MAP(
        CLK => CLK,
        RST => RST_SIG,
        DONE => RX_DONE_SIG,
        DATA => RX_DATA,
        RX => TX_RX
    );
    
    process(CLK, RST_SIG)
    begin
        if RST_SIG = '1' then
            counter <= 0;
            TX_RDY_SIG <= '0';
        elsif rising_edge(CLK) then
            if counter < PERIOD - 1 then
                counter <= counter + 1;
            else
                counter <= 0;
            end if;

            if counter < ON_CYCLES then
                TX_RDY_SIG <= '1';  -- signal ON
            else
                TX_RDY_SIG <= '0';  -- signal OFF
            end if;
        end if;
    end process;


end Behavioral;
