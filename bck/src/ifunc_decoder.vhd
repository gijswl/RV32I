library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ifunc_decoder is
	port(
		I_INSTR  : in  std_logic_vector(31 downto 0);
		I_FORMAT : in  std_logic_vector(5 downto 0);
		Q_FUNC   : out std_logic_vector(8 downto 0)
	);
end entity ifunc_decoder;

architecture RTL of ifunc_decoder is
	signal L_FUNC : std_logic_vector(7 downto 0);
	signal L_EXT  : std_logic;
begin
	with I_INSTR(14 downto 12) select L_FUNC <=
		"00000001" when "000",
		"00000010" when "001",
		"00000100" when "010",
		"00001000" when "011",
		"00010000" when "100",
		"00100000" when "101",
		"01000000" when "110",
		"10000000" when "111",
		"00000000" when others;

	with I_INSTR(31 downto 25) select L_EXT <=
		'1' when "0100000",
		'0' when others;

	Q_FUNC <= (L_EXT & L_FUNC) when (I_FORMAT(0) = '1' or (I_FORMAT(1) = '1' and L_FUNC(5) = '1')) else ('0' & L_FUNC) when (I_FORMAT(4) = '0' and I_FORMAT(5) = '0') else "ZZZZZZZZZ";
end architecture RTL;
