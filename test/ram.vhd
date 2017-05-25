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
		0      => "00000001100000000010001000000011", -- LW
		4      => "00000000010100000000000100010011", -- ADDI x2, x0, 5
		8      => "00000000000000000000000010010011", -- ADDI x1, x0, 0
		12     => "00000000000100001000000010010011", -- ADDI x1, x1, 1
		16     => "11111110000100010101111011100011", -- BGE
		20     => "00000000000000000000000111100111", -- JALR
		24     => "11001010111111101101111010101101", -- CAFEDEAD
		28     => "11001010111111101101111010101111", -- CAFEDEAD
		4096   => "00000000000000000000000001100111", -- JALR
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
