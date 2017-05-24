library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ram_sim is
	port(
		I_CLK  : in  std_logic;
		I_ADDR : in  std_logic_vector(31 downto 0);
		I_WE   : in  std_logic;
		I_ADS  : in  std_logic;
		Q_RDY  : out std_logic;
		I_DATA : in  std_logic_vector(31 downto 0);
		Q_DATA : out std_logic_vector(31 downto 0)
	);
end ram_sim;

architecture RTL of ram_sim is
	signal L_DATA : std_logic_vector(31 downto 0) := X"00000000";
	signal L_IADR : integer;
	signal L_RDY  : std_logic                     := '1';
begin
	L_IADR <= to_integer(unsigned(SHL(I_ADDR(31 downto 2), "10")));

	process(I_CLK)
	begin
		if (I_WE = '0' and I_ADS = '1') then
			if(I_ADDR(31 downto 2) = X"0000000" & "000000") then
			     L_DATA <= "00000001" & "10010000" & "00100010" & "00000011";
			elsif(I_ADDR(31 downto 2) = X"000010" & "000000") then
			     L_DATA <= "00000000" & "00000010" & "00000000" & "01100111";
			else
			     L_DATA <= X"00000000";
			end if;
			L_RDY  <= '0';
		else
			L_RDY <= '1';
		end if;
	end process;

	Q_DATA <= L_DATA;
	Q_RDY  <= L_RDY;
end RTL;