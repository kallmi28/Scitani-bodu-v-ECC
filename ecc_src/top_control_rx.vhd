library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top_control_rx is
	Port ( clk, reset	: in std_logic;
		   rx_cnt		: in std_logic_vector(5 downto 0);
		   rx_ack		: in std_logic;
		   cnt_up		: out std_logic;
		   start_next	: out std_logic;
		   reset_cnt	: out std_logic
		   );
end top_control_rx;

architecture top_control_rx_body of top_control_rx is

type fsm_state is (INIT, RX_U, RX_D, DONE);
signal state, nextstate : fsm_state;
begin

CLOCK: process(clk)
begin
	if rising_edge(clk) then
		if reset='1' then 
			state <= INIT;
		else 
			state <= nextstate;
		end if;
	end if;
end process;

TRANSITION : process(state, rx_ack, rx_cnt)
begin
	nextstate <= state;
	case state is
		when INIT =>
			nextstate <= RX_U;
		when RX_U =>
			if(rx_ack = '1') then
				nextstate <= RX_D;
			end if;
		when RX_D =>
			if(rx_cnt = 40) then
				nextstate <= DONE;
			elsif (rx_ack = '0') then
				nextstate <= RX_U;
			end if;
		when DONE =>
			nextstate <= RX_U;
	end case;
end process;

OUTPUT : process(state, rx_ack, rx_cnt)
begin

	cnt_up <= '0';
	start_next <= '0';
	reset_cnt <= '0';
	case state is
		when INIT => 
		  reset_cnt <= '1';
		when RX_U =>
			if(rx_ack = '1') then
				cnt_up <= '1';
			end if;
		when RX_D => NULL;
		when DONE =>
			start_next <= '1';
			reset_cnt <= '1';
	end case;
end process;



end top_control_rx_body;
