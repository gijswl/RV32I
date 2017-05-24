library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ar_logic is
	generic(
		ar : std_logic_vector(31 downto 0)
	);
	port(
		I_CLK   : in  std_logic;
		I_INC_4 : in  std_logic;
		I_LD    : in  std_logic;
		I_IN    : in  std_logic_vector(31 downto 0);
		Q_AR    : out std_logic_vector(31 downto 0)
	);
end entity ar_logic;

architecture RTL of ar_logic is
	signal L_AR : std_logic_vector(31 downto 0) := ar;
begin
	process(I_CLK)
	begin
		if (rising_edge(I_CLK)) then
			if (I_LD = '1') then
				L_AR <= I_IN;
			elsif (I_INC_4 = '1') then
				L_AR <= L_AR + X"00000004";
			end if;
		end if;
	end process;

	Q_AR <= L_AR;
end architecture RTL;
