----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2025 09:14:54 AM
-- Design Name: 
-- Module Name: uart_rx - Behavioral
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_rx is
    Port (
        clk     : in  std_logic;  -- System clock
        reset   : in  std_logic;  -- Active-low reset
        rx      : in  std_logic;  -- UART receive input
        rx_data : out std_logic_vector(7 downto 0); -- Received 8-bit data
        rx_done : out std_logic   -- Signal when reception is complete
    );
end uart_rx;

architecture Behavioral of uart_rx is

    type state_type is (IDLE, START, DATA, STOP);
    signal state, next_state : state_type;

    signal shift_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal bit_count : integer range 0 to 7 := 0;
    
    signal uart_clk : std_logic; -- clock for uart
    signal clk_div_rst : std_logic;

begin

    -- clock divider: default is 115200 baud rate from 100MHz clock
    clk_div_inst: entity work.clk_divider_rx
        port map (
            CLK => clk,
            RST => clk_div_rst,
            CE => uart_clk
        );

    -- FSM Process: State Transition Logic
    process(clk, reset)
    begin
        if reset = '0' then
            state <= IDLE;
        elsif rising_edge(clk) then
            if uart_clk = '1' then
                state <= next_state;
            end if;
        end if;
    end process;

    -- Next State Logic
    process(state, rx, bit_count)
    begin
        next_state <= state; -- Default state remains unchanged

        case state is
            when IDLE =>
                if rx = '0' then -- Start bit detected
                    next_state <= START;
                end if;

            when START =>
                next_state <= DATA;

            when DATA =>
                if bit_count = 7 then  -- After receiving 8 bits
                    next_state <= STOP;
                end if;

            when STOP =>
                if rx = '1' then -- Stop bit received correctly
                    next_state <= IDLE;
                end if;
        end case;
    end process;

    -- Data Reception Logic (Shift Register)
    process(clk)
    begin
        if rising_edge(clk) then
            if uart_clk = '1' then
                clk_div_rst <= '0';
                case state is
                    when IDLE =>
                        rx_done <= '0'; -- Reset the done flag

                    when START =>
                        bit_count <= 0; -- Reset bit counter
                        clk_div_rst <= '1';

                    when DATA =>
                        shift_reg <= rx & shift_reg(7 downto 1); -- Shift in bits
                        bit_count <= bit_count + 1;

                    when STOP =>
                        rx_done <= '1'; -- Reception complete
                        rx_data <= shift_reg; -- Store received data
                end case;
            end if;
        end if;
    end process;

end Behavioral;

