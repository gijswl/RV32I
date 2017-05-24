library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity csrfile is
	port(
		I_CLK : in  std_logic;
		I_WE  : in  std_logic;
		I_OE  : in  std_logic;
		I_ADR : in  std_logic_vector(11 downto 0);
		I_IN  : in  std_logic_vector(31 downto 0);
		Q_OUT : out std_logic_vector(31 downto 0)
	);
end entity csrfile;

architecture RTL of csrfile is
	constant NOT_IMPL : std_logic_vector(31 downto 0) := X"00000000";

	signal CSR_MISA    : std_logic_vector(31 downto 0) := X"40000100";
	signal CSR_MSTATUS : std_logic_vector(31 downto 0);
	signal L_OUT       : std_logic_vector(31 downto 0) := X"00000000";
begin
	with I_ADR select L_OUT <=
		NOT_IMPL when others;

	Q_OUT <= L_OUT when I_OE = '1';
end architecture RTL;
