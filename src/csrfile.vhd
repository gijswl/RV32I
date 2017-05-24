library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

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
	--	constant CSR_MVENDORID : std_logic_vector(31 downto 0) := X"00000000";
	--	constant CSR_MARCHID   : std_logic_vector(31 downto 0) := X"00000000";
	--	constant CSR_MIMPID    : std_logic_vector(31 downto 0) := X"00000000";
	--	constant CSR_MHARTID   : std_logic_vector(31 downto 0) := X"00000000";
	--
	--	signal CSR_MISA    : std_logic_vector(31 downto 0) := X"40000100";
	--	signal CSR_MSTATUS : std_logic_vector(31 downto 0);

	signal CSR_CYCLE   : std_logic_vector(63 downto 0) := X"0000000000000000";
	signal CSR_TIME    : std_logic_vector(63 downto 0) := X"0000000000000000";
	signal CSR_INSTRET : std_logic_vector(63 downto 0) := X"0000000000000000";
	signal L_OUT       : std_logic_vector(31 downto 0) := X"00000000";
begin
	process(I_CLK)
	begin
		if (rising_edge(I_CLK)) then
			CSR_CYCLE <= CSR_CYCLE + X"0000000000000001";
			CSR_TIME  <= CSR_TIME + X"0000000000000001";
		end if;
	end process;

	with I_ADR select L_OUT <=
		CSR_CYCLE(31 downto 0) when X"C00",
		CSR_TIME(31 downto 0) when X"C01",
		CSR_INSTRET(31 downto 0) when X"C02",
		CSR_CYCLE(63 downto 32) when X"C80",
		CSR_TIME(63 downto 32) when X"C81",
		CSR_INSTRET(63 downto 32) when X"C82",
		NOT_IMPL when others;

	Q_OUT <= L_OUT when I_OE = '1';
end architecture RTL;