----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/17/2025 09:31:33 AM
-- Design Name: 
-- Module Name: UART_RX_FSM - Behavioral
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

entity UART_RX_FSM is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           RX : in STD_LOGIC;
           CLK_UART : in STD_LOGIC;
           RST_CLK_DIV : out STD_LOGIC;
           RECEIVING : out STD_LOGIC;
           DONE_OUT : out STD_LOGIC);
end UART_RX_FSM;

architecture Behavioral of UART_RX_FSM is

    type state_type is (IDLE, START, START_BIT,
                        BIT0,
                        BIT1,
                        BIT2,
                        BIT3,
                        BIT4,
                        BIT5,
                        BIT6,
                        BIT7,
                        DONE);
    signal state, next_state: state_type;

begin

    sync_proc: process(CLK)
    begin
        if rising_edge(CLK) then
            if (RST = '1') then
                state <= IDLE;
            else
                state <= next_state;
                if (state /= DONE) and (next_state = DONE) then
                    DONE_OUT <= '1';
                else
                    DONE_OUT <= '0';
                end if;
            end if;
        end if;
    end process;

    state_transition: process(state, RX, CLK_UART)
    begin
        next_state <= state;
        case state is
            when IDLE =>
                if RX = '0' then
                    next_state <= START;
                else
                    next_state <= IDLE;
                end if;
            when START => 
                next_state <= START_BIT;
            when START_BIT =>
                if CLK_UART = '1' then
                    next_state <= BIT0;
                end if;
            when BIT0 =>
                if CLK_UART = '1' then
                    next_state <= BIT1;
                end if;
            when BIT1 =>
                if CLK_UART = '1' then
                    next_state <= BIT2;
                end if;
            when BIT2 =>
                if CLK_UART = '1' then
                    next_state <= BIT3;
                end if;
            when BIT3 =>
                if CLK_UART = '1' then
                    next_state <= BIT4;
                end if;
            when BIT4 =>
                if CLK_UART = '1' then
                    next_state <= BIT5;
                end if;
            when BIT5 =>
                if CLK_UART = '1' then
                    next_state <= BIT6;
                end if;
            when BIT6 =>
                if CLK_UART = '1' then
                    next_state <= BIT7;
                end if;
            when BIT7 =>
                if CLK_UART = '1' then
                    next_state <= DONE;
                end if;
            when DONE =>
                if CLK_UART = '1' then
                    next_state <= IDLE;
                end if;
        end case;
    end process;
    
    output_decode: process(state)
    begin
        RST_CLK_DIV <= '0';
        RECEIVING <= '0';
        case state is
            when IDLE =>
                RST_CLK_DIV <= '0';
                RECEIVING <= '0';
            when START => 
                RST_CLK_DIV <= '1';
                RECEIVING <= '0';
            when START_BIT =>
                RST_CLK_DIV <= '0';
                RECEIVING <= '1';
			when BIT0 =>
                RST_CLK_DIV <= '0';
                RECEIVING <= '1';
			when BIT1 =>
                RST_CLK_DIV <= '0';
                RECEIVING <= '1';
			when BIT2 =>
                RST_CLK_DIV <= '0';
                RECEIVING <= '1';
			when BIT3 =>
                RST_CLK_DIV <= '0';
                RECEIVING <= '1';
			when BIT4 =>
                RST_CLK_DIV <= '0';
                RECEIVING <= '1';
			when BIT5 =>
                RST_CLK_DIV <= '0';
                RECEIVING <= '1';
			when BIT6 =>
                RST_CLK_DIV <= '0';
                RECEIVING <= '1';
			when BIT7 =>
                RST_CLK_DIV <= '0';
                RECEIVING <= '1';
			when DONE =>
                RST_CLK_DIV <= '0';
                RECEIVING <= '0';
        end case;
    end process;


end Behavioral;
