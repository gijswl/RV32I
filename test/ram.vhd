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
	type ram_t is array (0 to 8191) of std_logic_vector(31 downto 0);
	signal ram : ram_t := (
		0      => "00000000010100000000000100010011", -- ADDI x2, x0, 5
		1      => "11000000000100011111100001110011", -- CSRRCI
		2      => "00000000000000000000000010010011", -- ADDI x1, x0, 0
		3      => "00000000000100001000000010010011", -- ADDI x1, x1, 1
		4      => "11111110000100010101111011100011", -- BGE
		5      => "00000000000000000000000111100111", -- JALR
		6      => "10101011110011011110111110101010", -- AAAAAAAA
		7      => "10111011101110111011101110111011", -- BBBBBBBB
		1024   => "00000000010100000000000100010011", -- ADDI x2, x0, 5
		1025   => "01000000001000000000000110110011", -- SUB x3, x0, x2
		1026   => "00000001100000000010110000000011", -- LW
		1027   => "00000011100000000000000010100011", -- SW
		1028   => "00000010000100000010110010000011", -- LW
		1029   => "00000000000000011110010001100011", -- BLTU #$8, x3, x0
		1030   => "00000000000000000000000001100111", -- JALR
		others => (others => '0')
	);

	signal L_DATA : std_logic_vector(31 downto 0) := X"00000000";
	signal L_IADR : integer;
	signal L_RDY  : std_logic                     := '1';
begin
	L_IADR <= to_integer(unsigned(SHL(I_ADDR(31 downto 2), "10"))) / 4;

	process(I_CLK)
	begin
		if (I_WE = '1' and I_ADS = '1') then
			ram(L_IADR) <= I_DATA;
			L_RDY       <= '0';
		elsif (I_WE = '0' and I_ADS = '1') then
			L_DATA <= ram(L_IADR);
			L_RDY  <= '0';
		else
			L_RDY <= '1';
		end if;
	end process;

	Q_DATA <= L_DATA;
	Q_RDY  <= L_RDY;
end RTL;
