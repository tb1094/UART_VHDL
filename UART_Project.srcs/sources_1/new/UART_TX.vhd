----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2025 02:46:10 PM
-- Design Name: 
-- Module Name: UART_TX - Behavioral
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

entity uart_tx is
    Port ( clk         : in  std_logic;
           reset       : in  std_logic;
           data_in     : in  std_logic_vector(7 downto 0); -- data to transmit (8 bits)
           tx          : out std_logic; -- UART transmit line
           tx_start    : in  std_logic; -- start transmission signal
           done        : out std_logic -- transmission completed signal
           );
end uart_tx;

architecture Behavioral of uart_tx is

    type state_type is (IDLE, START, DATA, STOP);
    signal state, next_state : state_type;

    signal bit_count : integer range 0 to 7 := 0;  -- counter for data bits
    signal shift_reg : std_logic_vector(7 downto 0) := (others => '0'); -- data shift register

    signal uart_clk : std_logic; -- clock for uart
    
    signal clk_div_rst : std_logic;

begin

    -- clock divider: default is 115200 baud rate from 100MHz clock
    clk_div_inst: entity work.clk_divider
        port map (
            CLK => clk,
            RST => clk_div_rst,
            CE => uart_clk
        );

    -- state transition process
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
    
    process(state, tx_start, bit_count)
    begin
        next_state <= state; -- default state remains unchanged

        case state is
            when IDLE =>
                if tx_start = '1' then
                    next_state <= START;
                end if;

            when START =>
                next_state <= DATA;

            when DATA =>
                if bit_count = 7 then  -- send all 8 bits
                    next_state <= STOP;
                end if;

            when STOP =>
                next_state <= IDLE;
        end case;
    end process;

    -- output logic
    process(clk)
    begin
        if rising_edge(clk) then
            if uart_clk = '1' then
                case state is
                    when IDLE =>
                        tx <= '1'; -- UART idle state is high
                        done <= '0';
                        bit_count <= 0;

                    when START =>
                        tx <= '0'; -- send start bit
                        shift_reg <= data_in; -- load data into shift register

                    when DATA =>
                        tx <= shift_reg(0); -- send LSB first
                        shift_reg <= '0' & shift_reg(7 downto 1); -- shift the register
                        bit_count <= bit_count + 1;

                    when STOP =>
                        tx <= '1'; -- send stop bit
                        done <= '1'; -- transmission complete
                end case;
            end if;
        end if;
    end process;

end Behavioral;
