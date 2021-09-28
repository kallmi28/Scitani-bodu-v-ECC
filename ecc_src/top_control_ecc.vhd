library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top_control_ecc is
	Port (  clk, reset	: in std_logic;
			start : in std_logic;
			p0, q0 : in std_logic;
			op1 : in std_logic;
			ecc_done : in std_logic;

			copyP : out std_logic;
			ecc_start : out std_logic;
			start_next : out std_logic
		   );
end top_control_ecc;

architecture top_control_ecc_body of top_control_ecc is

--type fsm_state is (INIT, ISZERO, PZERO, QZERO, OPER, INV_QY, ECC_ST, ECC);
type fsm_state is (INIT, OPER1, ISZERO, PZERO, QZERO, ECC_ST, ECC);
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

TRANSITION : process(state, p0, q0, op1, ecc_done, start)
begin
nextstate <= state;
	case state is
		when INIT =>
			if (start = '1') then
				nextstate <= OPER1;
			end if;
		when OPER1 =>
			nextstate <= ISZERO;
		when ISZERO =>
			if (p0 = '1') then
				nextstate <= PZERO;
			elsif (q0 = '1') then
				nextstate <= QZERO;
			elsif (q0 = '0' and p0 = '0') then
				nextstate <= ECC_ST;
			end if;
		when PZERO =>
			nextstate <= INIT;
		when QZERO =>
			nextstate <= INIT;
		when ECC_ST =>
			nextstate <= ECC;
		when ECC =>
			if(ecc_done = '1') then
				nextstate <= INIT;
			end if; 
	end case;
end process;

OUTPUT : process(state, p0, q0, op1, ecc_done, start)
begin
	ecc_start <= '0';
	copyP <= '0';
	start_next <= '0';
	case state is
		when INIT => NULL;
		when OPER1 => 
			if(op1 = '1') then
				copyP <= '1';
			end if;
		when ISZERO => NULL;
		when PZERO =>
			start_next <= '1';
		when QZERO =>
			start_next <= '1';
		when ECC_ST =>
			ecc_start <= '1';
		when ECC =>
			if(ecc_done = '1') then
				start_next <= '1';
			end if;
	end case;
end process;



end top_control_ecc_body;
