library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pc_logic is
	generic(
		pc : std_logic_vector(31 downto 0)
	);
	port(
		I_CLK   : in  std_logic;
		I_INC_4 : in  std_logic;
		I_LD    : in  std_logic;
		I_IN    : in  std_logic_vector(31 downto 0);
		Q_PC    : out std_logic_vector(31 downto 0)
	);
end entity pc_logic;

architecture RTL of pc_logic is
	signal L_PC : std_logic_vector(31 downto 0) := pc;
begin
	process(I_CLK)
	begin
		if (rising_edge(I_CLK)) then
			if (I_LD = '1') then
				L_PC <= I_IN;
			elsif (I_INC_4 = '1') then
				L_PC <= L_PC + X"00000004";
			end if;
		end if;
	end process;

	Q_PC <= L_PC;
end architecture RTL;
