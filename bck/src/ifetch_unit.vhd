library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ifetch_unit is
	port(
		I_CLK   : in  std_logic;
		I_INC_4 : in  std_logic;
		I_LDPC  : in  std_logic;
		I_RDIR  : in  std_logic;
		I_RDY   : in  std_logic;
		I_PC    : in  std_logic_vector(31 downto 0);
		I_DATA  : in  std_logic_vector(31 downto 0);
		Q_WR    : out std_logic;
		Q_STALL : out std_logic;
		Q_ADS   : out std_logic;
		Q_ADR   : out std_logic_vector(31 downto 0);
		Q_IR    : out std_logic_vector(31 downto 0);
		Q_PC    : out std_logic_vector(31 downto 0)
	);
end entity ifetch_unit;

architecture RTL of ifetch_unit is
	constant DEFAULT_RSTVEC : std_logic_vector(31 downto 0) := X"00001000";

	component shift_reg64 is
		port(
			I_CLK    : in  std_logic;
			I_D      : in  std_logic_vector(31 downto 0);
			I_W      : in  std_logic;
			I_RST    : in  std_logic;
			I_SHIFT1 : in  std_logic;
			Q_AMT    : out std_logic_vector(1 downto 0);
			Q_D      : out std_logic_vector(31 downto 0)
		);
	end component shift_reg64;

	signal S_W   : std_logic                     := '0';
	signal S_SH1 : std_logic                     := '0';
	signal S_AMT : std_logic_vector(1 downto 0)  := "00";
	signal S_D   : std_logic_vector(31 downto 0) := X"00000000";

	component pc_logic is
		generic(
			pc : std_logic_vector(31 downto 0)
		);
		port(
			I_CLK   : in  std_logic;
			I_INC_4 : in  std_logic;
			I_LD    : in  std_logic;
			I_IN    : in  std_logic_vector(31 downto 0);
			Q_PC    : out std_logic_vector(31 downto 0)
		);
	end component pc_logic;

	signal PC_INC_4 : std_logic := '0';

	component ar_logic is
		generic(
			ar : std_logic_vector(31 downto 0)
		);
		port(
			I_CLK : in std_logic;
			I_INC_4 : in std_logic;
			I_LD : in std_logic;
			I_IN : in std_logic_vector(31 downto 0);
			Q_AR : out std_logic_vector(31 downto 0)
		); end component ar_logic;

	signal A_INC_4 : std_logic                     := '0';
	signal A_AR    : std_logic_vector(31 downto 0) := X"00000000";

	signal L_T     : std_logic_vector(1 downto 0)  := "00";
	signal L_WR    : std_logic                     := '0';
	signal L_ADS   : std_logic                     := '1';
	signal L_STALL : std_logic                     := '1';
	signal L_ADR   : std_logic_vector(31 downto 0) := X"00000000";
begin
	ir : shift_reg64
		port map(
			I_CLK    => I_CLK,
			I_D      => S_D,
			I_W      => S_W,
			I_RST    => I_LDPC,
			I_SHIFT1 => S_SH1,
			Q_AMT    => S_AMT,
			Q_D      => Q_IR
		);
	pc : pc_logic
		generic map(
			pc => DEFAULT_RSTVEC
		)
		port map(
			I_CLK   => I_CLK,
			I_INC_4 => PC_INC_4,
			I_LD    => I_LDPC,
			I_IN    => I_PC,
			Q_PC    => Q_PC
		);

	ar : ar_logic
		generic map(
			ar => DEFAULT_RSTVEC
		)
		port map(
			I_CLK   => I_CLK,
			I_INC_4 => A_INC_4,
			I_LD    => I_LDPC,
			I_IN    => I_PC,
			Q_AR    => A_AR
		);

	process(I_CLK)
	begin
		if (rising_edge(I_CLK)) then
			if (L_T = "00") then
				S_D     <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
				S_W     <= '0';
				A_INC_4 <= '0';
				if ((S_AMT = "00" or S_AMT = "01") and not S_W = '1') then
					L_ADR <= A_AR;
					L_ADS <= '0';
					L_WR  <= '0';
					L_T   <= "10";
					L_T   <= "01";
				end if;
			elsif (L_T = "01") then
				L_ADS   <= '1';
				L_ADR   <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
				A_INC_4 <= '1';
				if (I_RDY = '0') then
					S_D <= I_DATA;
					S_W <= '1';
					L_T <= "00";
				end if;
			end if;
		end if;
	end process;

	S_SH1    <= '1' when (not (S_AMT = "00") and I_RDIR = '1') else '0';
	PC_INC_4 <= I_INC_4;

	Q_ADS   <= L_ADS;
	Q_WR    <= L_WR;
	Q_STALL <= '0' when (S_AMT = "00" and I_RDIR = '1') else '1';
	Q_ADR   <= L_ADR;
end architecture RTL;
