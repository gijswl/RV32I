library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity bus_interface is
	port(
		I_CLK  : in  std_logic;
		I_BR   : in  std_logic;
		I_WR   : in  std_logic;
		I_RDY  : in  std_logic;
		I_RST  : in  std_logic;
		I_ADR  : in  std_logic_vector(31 downto 0);
		I_WDT  : in  std_logic_vector(31 downto 0);
		I_DATB : in  std_logic_vector(31 downto 0);
		Q_ACK  : out std_logic;
		Q_STD  : out std_logic;
		Q_WR   : out std_logic;
		Q_ADS  : out std_logic;
		Q_RDT  : out std_logic_vector(31 downto 0);
		Q_ABS  : out std_logic_vector(31 downto 0);
		Q_DATB : out std_logic_vector(31 downto 0)
	);
end entity bus_interface;

architecture RTL of bus_interface is
	signal L_T : std_logic_vector(1 downto 0) := "00";

	signal L_DATB : std_logic_vector(31 downto 0) := X"00000000";
	signal L_ADRB : std_logic_vector(31 downto 0) := X"00000000";
	signal L_DATA : std_logic_vector(31 downto 0) := X"00000000";
	signal L_ACK  : std_logic                     := '0';
	signal L_ADS  : std_logic                     := '0';
	signal L_WR   : std_logic                     := '0';
	signal L_STD  : std_logic                     := '0';
begin
	process(I_CLK)
	begin
		if (I_RST = '1') then
			L_T <= "00";
		end if;
		if (rising_edge(I_CLK)) then
			case (L_T) is
				when "00" =>
					L_STD  <= '0';
					L_ACK  <= '1';
					L_DATB <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
					if (I_BR = '1') then
						L_T <= "01";
					else
						L_T <= "00";
					end if;
				when "01" =>
					L_STD  <= '0';
					L_ACK  <= '0';
					L_ADRB <= I_ADR;
					L_DATB <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
					L_ADS  <= '0';
					L_WR   <= I_WR;
					L_T    <= "10";
				when "10" =>
					L_ADS <= '1';
					if (I_WR = '1') then
						L_DATB <= I_WDT;
					end if;
					if (I_RDY = '0') then
						L_STD <= '1';
						if (I_WR = '0') then
							L_DATA <= I_DATB;
						end if;
						if (I_BR = '0') then
							L_T <= "00";
						else
							L_T <= "01";
						end if;
					else
						L_STD <= '0';
						L_T   <= "10";
					end if;
				when others => report "Bus Interface is in an undefined state" severity failure;
			end case;
		end if;
	end process;

	Q_ACK  <= L_ACK;
	Q_STD  <= L_STD;
	Q_WR   <= L_WR;
	Q_ADS  <= L_ADS;
	Q_RDT  <= L_DATA;
	Q_ABS  <= L_ADRB;
	Q_DATB <= L_DATB;
end architecture RTL;