library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity cpu_fpga is
	port(
		I_CLK_100 : in std_logic
	);
end entity cpu_fpga;

architecture RTL of cpu_fpga is
	component cpu_core
		port(
			I_CLK : in  std_logic;
			I_RDY : in  std_logic;
			I_RDT : in  std_logic_vector(31 downto 0);
			Q_WR  : out std_logic;
			Q_ADR : out std_logic_vector(31 downto 0);
			Q_WDT : out std_logic_vector(31 downto 0)
		);
	end component cpu_core;

	signal C_BR  : std_logic;
	signal C_WR  : std_logic;
	signal C_ACK : std_logic;
	signal C_STD : std_logic;
	signal C_RST : std_logic;
	signal C_ADR : std_logic_vector(31 downto 0);
	signal C_WDT : std_logic_vector(31 downto 0);
	signal C_RDT : std_logic_vector(31 downto 0);

	component ram_sim
		port(
			I_CLK  : in  std_logic;
			I_ADDR : in  std_logic_vector(31 downto 0);
			I_WE   : in  std_logic;
			I_ADS  : in  std_logic;
			I_DATA : in  std_logic_vector(31 downto 0);
			Q_RDY  : out std_logic;
			Q_DATA : out std_logic_vector(31 downto 0)
		);
	end component ram;

	signal R_ADDR : std_logic_vector(31 downto 0) := X"00000000";
	signal R_DATI : std_logic_vector(31 downto 0) := X"00000000";
	signal R_DATO : std_logic_vector(31 downto 0) := X"00000000";
	signal R_WE   : std_logic                     := '0';
	signal R_RDY  : std_logic                     := '1';
	signal R_ADS  : std_logic                     := '1';

	signal L_CLK     : std_logic                    := '0';
	signal L_CLK_CNT : std_logic_vector(2 downto 0) := "111";
begin
	cpu : cpu_core
		port map(
			I_CLK => L_CLK,
			I_RDY => R_RDY,
			I_RDT => R_DATI,
			Q_WR  => R_WE,
			Q_ADR => R_ADDR,
			Q_WDT => R_DATO
		);

	ram_t : ram_sim
		port map(
			I_CLK  => L_CLK,
			I_ADDR => R_ADDR,
			I_WE   => R_WE,
			I_ADS  => R_ADS,
			I_DATA => R_DATO,
			Q_RDY  => R_RDY,
			Q_DATA => R_DATI
		);
	clk_div : process(I_CLK_100)
	begin
		if (rising_edge(I_CLK_100)) then
			L_CLK_CNT <= L_CLK_CNT + "001";
			if (L_CLK_CNT = "001") then
				L_CLK_CNT <= "000";
				L_CLK     <= not L_CLK;
			end if;
		end if;
	end process;
end architecture RTL;
