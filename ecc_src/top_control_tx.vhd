library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top_control_tx is
	Port ( 	clk, reset	: in std_logic;
			start 		: in std_logic;
			tx_ready 	: in std_logic;
			tx_cnt		: in std_logic_vector(4 downto 0);

			copy_data	: out std_logic;
			cnt_up		: out std_logic;
			strobe		: out std_logic;
			reset_cnt	: out std_logic
		);
end top_control_tx;

architecture top_control_tx_body of top_control_tx is

type fsm_state is (INIT, TX, TX_WAIT1, TX_WAIT2);
signal state, nextstate : fsm_state;

begin

CLOCK: process(clk)
begin
	if(clk'event and clk = '1') then
		if reset='1' then 
			state <= INIT;
		else 
			state <= nextstate;
		end if;
	end if;
end process;

TRANSITION : process(state, start, tx_ready, tx_cnt)
begin
	nextstate <= state;
	case state is
		when INIT =>
			if(start = '1') then
				nextstate <= TX;
			end if;
		when TX =>
			if(tx_cnt = 19) then 
				nextstate <= INIT;
			elsif(tx_ready = '1') then
				nextstate <= TX_WAIT1;
			end if;
		when TX_WAIT1 =>
			nextstate <= TX_WAIT2;
		when TX_WAIT2 =>
			nextstate <= TX;
	end case;
end process;


OUTPUT : process(state, start, tx_ready, tx_cnt)
begin

	copy_data <= '0';
	cnt_up <= '0';
	strobe <= '0';
	reset_cnt <= '0';
	case state is
		when INIT =>
			if(start = '1') then
				copy_data <= '1';
				reset_cnt <= '1';
			end if;
		when TX =>
			if(tx_ready = '1') then
				strobe <= '1';
			elsif (tx_cnt = 19) then
				reset_cnt <= '1';
			end if;
		when TX_WAIT1 =>
			cnt_up <= '1';
		when TX_WAIT2 => NULL;
	end case;
end process;


end top_control_tx_body;
