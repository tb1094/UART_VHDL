----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2025 12:45:34 AM
-- Design Name: 
-- Module Name: UART_TX_FSM - Behavioral
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

entity UART_TX_FSM is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           CLK_UART : in STD_LOGIC;
           DATA_RDY : in STD_LOGIC;
           DONE_OUT : out STD_LOGIC;
           SHIFT_OUT : out STD_LOGIC;
           LOAD_DATA : out STD_LOGIC;
           RST_CLK_DIV : out STD_LOGIC);
end UART_TX_FSM;

architecture Behavioral of UART_TX_FSM is

    type state_type is (IDLE, PRE_SEND, SEND_START,
                        SEND_BIT0,
                        SEND_BIT1,
                        SEND_BIT2,
                        SEND_BIT3,
                        SEND_BIT4,
                        SEND_BIT5,
                        SEND_BIT6,
                        SEND_BIT7);
    signal state, next_state: state_type;
    signal start_sig : std_logic := '0';

begin

    sync_proc: process(CLK)
    begin
        if rising_edge(CLK) then
            if (RST = '1') then
                state <= IDLE;
                start_sig <= '0';
            else
                state <= next_state;
                if state = IDLE and DATA_RDY = '1' then
                    start_sig <= '1';
                elsif state = PRE_SEND then
                    start_sig <= '0';
                end if;
                if (state /= SEND_BIT7) and (next_state = SEND_BIT7) then
                    DONE_OUT <= '1';
                else
                    DONE_OUT <= '0';
                end if;
                if (state /= PRE_SEND) and (next_state = PRE_SEND) then
                    LOAD_DATA <= '1';
                else
                    LOAD_DATA <= '0';
                end if;
            end if;
        end if;
    end process;

    state_transition: process(state, CLK_UART, start_sig)
    begin
        next_state <= state;
        case state is
            when IDLE =>
                if start_sig = '1' then
                    next_state <= PRE_SEND;
                else
                    next_state <= IDLE;
                end if;
            when PRE_SEND => 
                if CLK_UART = '1' then
                    next_state <= SEND_START;
                end if;
            when SEND_START =>
                if CLK_UART = '1' then
                    next_state <= SEND_BIT0;
                end if;
            when SEND_BIT0 =>
                if CLK_UART = '1' then
                    next_state <= SEND_BIT1;
                end if;
            when SEND_BIT1 =>
                if CLK_UART = '1' then
                    next_state <= SEND_BIT2;
                end if;
            when SEND_BIT2 =>
                if CLK_UART = '1' then
                    next_state <= SEND_BIT3;
                end if;
            when SEND_BIT3 =>
                if CLK_UART = '1' then
                    next_state <= SEND_BIT4;
                end if;
            when SEND_BIT4 =>
                if CLK_UART = '1' then
                    next_state <= SEND_BIT5;
                end if;
            when SEND_BIT5 =>
                if CLK_UART = '1' then
                    next_state <= SEND_BIT6;
                end if;
            when SEND_BIT6 =>
                if CLK_UART = '1' then
                    next_state <= SEND_BIT7;
                end if;
            when SEND_BIT7 =>
                if CLK_UART = '1' then
                    next_state <= IDLE;
                end if;
        end case;
    end process;
    
    output_decode: process(state)
    begin
        SHIFT_OUT <= '0';
        RST_CLK_DIV <= '0';
        case state is
            when IDLE =>
                SHIFT_OUT <= '0';
                RST_CLK_DIV <= '1';
            when PRE_SEND =>
                SHIFT_OUT <= '1';
                RST_CLK_DIV <= '0';
            when SEND_START =>
                SHIFT_OUT <= '1';
                RST_CLK_DIV <= '0';
			when SEND_BIT0 =>
                SHIFT_OUT <= '1';
                RST_CLK_DIV <= '0';
			when SEND_BIT1 =>
                SHIFT_OUT <= '1';
                RST_CLK_DIV <= '0';
			when SEND_BIT2 =>
                SHIFT_OUT <= '1';
                RST_CLK_DIV <= '0';
			when SEND_BIT3 =>
                SHIFT_OUT <= '1';
                RST_CLK_DIV <= '0';
			when SEND_BIT4 =>
                SHIFT_OUT <= '1';
                RST_CLK_DIV <= '0';
			when SEND_BIT5 =>
                SHIFT_OUT <= '1';
                RST_CLK_DIV <= '0';
			when SEND_BIT6 =>
                SHIFT_OUT <= '1';
                RST_CLK_DIV <= '0';
			when SEND_BIT7 =>
                SHIFT_OUT <= '1';
                RST_CLK_DIV <= '0';
        end case;
    end process;

end Behavioral;
