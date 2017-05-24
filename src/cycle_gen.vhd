library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity cycle_gen is
	port(
		I_CLK   : in  std_logic;
		I_INC   : in  std_logic;
		I_RST   : in  std_logic;
		Q_CYCLE : out std_logic_vector(7 downto 0)
	);
end entity cycle_gen;

architecture RTL of cycle_gen is
	signal L_CYCLE : std_logic_vector(7 downto 0) := "00000001";
begin
	process(I_CLK)
	begin
		if (rising_edge(I_CLK)) then
			if (I_RST = '1') then
				L_CYCLE <= "00000001";
			elsif (I_INC = '1') then
				case L_CYCLE is
					when "00000001" => L_CYCLE <= "00000010";
					when "00000010" => L_CYCLE <= "00000100";
					when "00000100" => L_CYCLE <= "00001000";
					when "00001000" => L_CYCLE <= "00010000";
					when "00010000" => L_CYCLE <= "00100000";
					when "00100000" => L_CYCLE <= "01000000";
					when "01000000" => L_CYCLE <= "10000000";
					when others     => report "C7 overflowed in cycle_gen.RTL" severity failure;
				end case;
			end if;
		end if;
	end process;

	Q_CYCLE <= L_CYCLE;
end architecture RTL;
