----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/25/2025 08:48:28 AM
-- Design Name: 
-- Module Name: FULL_UART - Behavioral
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

entity FULL_UART is
    Port ( CLK, RST : in STD_LOGIC;
           RX : in STD_LOGIC;
           R_DATA : out STD_LOGIC_VECTOR (7 downto 0);
           RD_UART : in STD_LOGIC;
           RX_EMPTY : out STD_LOGIC;
           TX : out STD_LOGIC;
           W_DATA : in STD_LOGIC_VECTOR (7 downto 0);
           WR_UART : in STD_LOGIC;
           TX_FULL : out STD_LOGIC
           );
end FULL_UART;

architecture Behavioral of FULL_UART is
    -- signals between RX and RX buffer
    signal RX_DATA : std_logic_vector(7 downto 0);
    signal RX_DONE : std_logic;
    
    -- extra RX signals for timing
    signal RX_1 : std_logic;
    signal RX_2 : std_logic;
    
    -- signals between TX and TX buffer
    signal TX_DATA : std_logic_vector(7 downto 0);
    signal TX_DONE : std_logic;
    signal TX_EMPTY : std_logic;
begin

    RX_Inst: entity work.UART_RX
    PORT MAP(
		CLK => CLK,
		RST => RST,
		DONE => RX_DONE,
		DATA => RX_DATA,
		RX => RX_2
	);
	
	RX_BUFFER_Inst: entity work.BUFFER_REG
	PORT MAP(
        CLK => CLK,
        RST => RST,
	    W_DATA => RX_DATA,
	    R_DATA => R_DATA,
	    WR => RX_DONE,
	    RD => RD_UART,
	    full => open,
	    empty => RX_EMPTY
	);

    TX_Inst: entity work.UART_TX
    PORT MAP(
		CLK => CLK,
		RST => RST,
		DATA_RDY => not TX_EMPTY,
		DATA_IN => TX_DATA,
		DONE_OUT => TX_DONE,
		TX => TX
	);
	
	TX_BUFFER_Inst: entity work.BUFFER_REG
	PORT MAP(
        CLK => CLK,
        RST => RST,
	    W_DATA => W_DATA,
	    R_DATA => TX_DATA,
	    WR => WR_UART,
	    RD => TX_DONE,
	    full => TX_FULL,
	    empty => TX_EMPTY
	);
	
	process(CLK)
	begin
	   if rising_edge(CLK) then
	       if (RST = '1') then
                RX_1 <= '1';
                RX_2 <= '1';
            else
                RX_1 <= RX;
                RX_2 <= RX_1;
            end if;
	   end if;
	end process;

end Behavioral;
