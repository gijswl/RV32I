library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ram is
	port(
		I_CLK  : in  std_logic;
		I_ADDR : in  std_logic_vector(31 downto 0);
		I_WE   : in  std_logic;
		I_ADS  : in  std_logic;
		Q_RDY  : out std_logic;
		I_DATA : in  std_logic_vector(31 downto 0);
		Q_DATA : out std_logic_vector(31 downto 0)
	);
end ram;

architecture RTL of ram is
	type ram_t is array (0 to 8191) of std_logic_vector(7 downto 0);
	signal ram : ram_t := (
		0      => "00000011",           -- LW
		1      => "00100010",
		2      => "10010000",
		3      => "00000001",
		4      => "00010011",           -- ADDI x2, x0, 5
		5      => "00000001",
		6      => "01010000",
		7      => "00000000",
		8      => "10010011",           -- ADDI x1, x0, 0
		9      => "00000000",
		10     => "00000000",
		11     => "00000000",
		12     => "10010011",           -- ADDI x1, x1, 1
		13     => "10000000",
		14     => "00010000",
		15     => "00000000",
		16     => "11100011",           -- BGE
		17     => "01011110",
		18     => "00010001",
		19     => "11111110",
		20     => "11100111",           -- JALR
		21     => "00000001",
		22     => "00000000",
		23     => "00000000",
		24     => "10101101",           -- CAFEDEAD
		25     => "11011110",
		26     => "11111110",
		27     => "11001010",
		4096   => "01100111",           -- JALR
		4097   => "00000000",
		4098   => "00000000",
		4099   => "00000000",
		others => (others => '0')
	);

	signal L_DATA : std_logic_vector(31 downto 0) := X"00000000";
	signal L_IADR : integer;
	signal L_RDY  : std_logic                     := '1';
begin
	L_IADR <= to_integer(unsigned(SHL(I_ADDR(31 downto 2), "10")));

	process(I_CLK)
	begin
		if (I_WE = '1' and I_ADS = '1') then
			ram(L_IADR + 0) <= I_DATA(7 downto 0);
			ram(L_IADR + 1) <= I_DATA(15 downto 8);
			ram(L_IADR + 2) <= I_DATA(23 downto 16);
			ram(L_IADR + 3) <= I_DATA(31 downto 24);
			L_RDY           <= '0';
		elsif (I_WE = '0' and I_ADS = '1') then
			L_DATA <= ram(L_IADR + 3) & ram(L_IADR + 2) & ram(L_IADR + 1) & ram(L_IADR);
			L_RDY  <= '0';
		else
			L_RDY <= '1';
		end if;
	end process;

	Q_DATA <= L_DATA;
	Q_RDY  <= L_RDY;
end RTL;