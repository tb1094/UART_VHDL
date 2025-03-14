----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/13/2025 02:03:28 PM
-- Design Name: 
-- Module Name: TX_TEST - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TX_TEST is
    Port ( clk : in std_logic;
           --reset : in std_logic;
           data : in STD_LOGIC_VECTOR (7 downto 0);
           tx : out STD_LOGIC
           --start : in std_logic;
           --done : out std_logic
           );
end TX_TEST;

architecture Behavioral of TX_TEST is

    signal start_sig : std_logic;
    signal data_sig : std_logic_vector(7 downto 0);
    
    signal reset_sig : std_logic := '0';
    signal done_sig : std_logic;
    
    signal counter : integer := 0;
    constant ON_CYCLES  : integer := 10;
    constant OFF_CYCLES : integer := 10000;
    constant PERIOD     : integer := ON_CYCLES + OFF_CYCLES;
    
begin

    data_sig <= "01100001";
    
    uart_tx_inst: entity work.uart_tx
        port map (
            clk => clk,
            reset => reset_sig,
            data_in => data_sig,
            tx => tx,
            tx_start => start_sig,
            done => done_sig
        );
    
    process(clk, reset_sig)
    begin
        if reset_sig = '0' then
            reset_sig <= '1';
            counter   <= 0;
            start_sig <= '0';
        elsif rising_edge(clk) then
            if counter < PERIOD - 1 then
                counter <= counter + 1;
            else
                counter <= 0;  -- Reset counter
            end if;

            if counter < ON_CYCLES then
                start_sig <= '1';  -- Signal ON
            else
                start_sig <= '0';  -- Signal OFF
            end if;
        end if;
    end process;

end Behavioral;
