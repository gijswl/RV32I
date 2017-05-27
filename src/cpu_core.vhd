library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity cpu_core is
	port(
		I_CLK : in  std_logic;
		I_RDY : in  std_logic;
		I_RDT : in  std_logic_vector(31 downto 0);
		Q_WR  : out std_logic;
		Q_ADR : out std_logic_vector(31 downto 0);
		Q_WDT : out std_logic_vector(31 downto 0)
	);
end entity cpu_core;

architecture RTL of cpu_core is
	component control_unit is
		port(
			I_CLK      : in  std_logic;
			I_STALL    : in  std_logic;
			I_CC       : in  std_logic_vector(2 downto 0);
			I_INSTR    : in  std_logic_vector(31 downto 0);
			Q_IMM      : out std_logic_vector(31 downto 0);
			Q_ALUFC    : out std_logic_vector(4 downto 0);
			Q_REG      : out std_logic_vector(4 downto 0);
			Q_RDIR     : out std_logic;
			Q_LOCKA    : out std_logic;
			Q_LOCKB    : out std_logic;
			Q_LOCKC    : out std_logic;
			Q_RBUS     : out std_logic;
			Q_BUSR     : out std_logic;
			Q_PCBUS    : out std_logic;
			Q_BUSPC    : out std_logic;
			Q_CSRBUS   : out std_logic;
			Q_BUSCSR   : out std_logic;
			Q_SL       : out std_logic_vector(4 downto 0);
			Q_BUSSEL   : out std_logic;
			Q_PC_INC_4 : out std_logic
		);
	end component control_unit;

	signal C_IMM    : std_logic_vector(31 downto 0) := X"00000000";
	signal C_ALUFC  : std_logic_vector(4 downto 0)  := "00000";
	signal C_REG    : std_logic_vector(4 downto 0)  := "00000";
	signal C_SL     : std_logic_vector(4 downto 0)  := "00000";
	signal C_LOCKA  : std_logic                     := '0';
	signal C_LOCKB  : std_logic                     := '0';
	signal C_LOCKC  : std_logic                     := '0';
	signal C_RBUS   : std_logic                     := '0';
	signal C_BUSR   : std_logic                     := '0';
	signal C_PCBUS  : std_logic                     := '0';
	signal C_BUSPC  : std_logic                     := '0';
	signal C_CSRBUS : std_logic                     := '0';
	signal C_BUSCSR : std_logic                     := '0';
	signal C_BUSSEL : std_logic                     := '0';
	signal C_INC_4  : std_logic                     := '0';
	signal C_RDIR   : std_logic                     := '0';
	signal C_STALL  : std_logic                     := '1';

	component ifetch_unit is
		port(
			I_CLK   : in  std_logic;
			I_INC_4 : in  std_logic;
			I_LDPC  : in  std_logic;
			I_RDIR  : in  std_logic;
			I_RDY   : in  std_logic;
			I_SL    : in  std_logic_vector(4 downto 0);
			I_PC    : in  std_logic_vector(31 downto 0);
			I_DATA  : in  std_logic_vector(31 downto 0);
			I_ADR   : in  std_logic_vector(31 downto 0);
			Q_WR    : out std_logic;
			Q_STALL : out std_logic;
			Q_ADS   : out std_logic;
			Q_ADR   : out std_logic_vector(31 downto 0);
			Q_IR    : out std_logic_vector(31 downto 0);
			Q_PC    : out std_logic_vector(31 downto 0);
			Q_DATA  : out std_logic_vector(31 downto 0)
		);
	end component ifetch_unit;

	signal F_WR   : std_logic;
	signal F_PC   : std_logic_vector(31 downto 0) := X"00000000";
	signal F_DATA : std_logic_vector(31 downto 0) := X"00000000";
	signal L_DATA : std_logic_vector(31 downto 0) := X"00000000";

	component registerfile is
		port(
			I_CLK : in  std_logic;
			I_WE  : in  std_logic;
			I_OE  : in  std_logic;
			I_REG : in  std_logic_vector(4 downto 0);
			I_IN  : in  std_logic_vector(31 downto 0);
			Q_OUT : out std_logic_vector(31 downto 0)
		);
	end component registerfile;

	signal R_OUT : std_logic_vector(31 downto 0) := X"00000000";

	component csrfile is
		port(
			I_CLK : in  std_logic;
			I_WE  : in  std_logic;
			I_OE  : in  std_logic;
			I_ADR : in  std_logic_vector(11 downto 0);
			I_IN  : in  std_logic_vector(31 downto 0);
			Q_OUT : out std_logic_vector(31 downto 0)
		);
	end component csrfile;

	signal S_OUT : std_logic_vector(31 downto 0) := X"00000000";

	component reg32 is
		generic(
			val : std_logic_vector(31 downto 0)
		);
		port(
			I_CLK : in  std_logic;
			I_D   : in  std_logic_vector(31 downto 0);
			I_W   : in  std_logic;
			Q_D   : out std_logic_vector(31 downto 0)
		);
	end component reg32;

	signal R_IR : std_logic_vector(31 downto 0) := X"00000000";
	signal R_PC : std_logic_vector(31 downto 0) := X"00000000";
	signal R_A  : std_logic_vector(31 downto 0) := X"00000000";
	signal R_B  : std_logic_vector(31 downto 0) := X"00000000";
	signal R_CI : std_logic_vector(31 downto 0) := X"00000000";
	signal R_CO : std_logic_vector(31 downto 0) := X"00000000";

	component alu is
		port(
			I_CLK : in  std_logic;
			I_A   : in  std_logic_vector(31 downto 0);
			I_B   : in  std_logic_vector(31 downto 0);
			I_FC  : in  std_logic_vector(4 downto 0);
			Q_CC  : out std_logic_vector(2 downto 0);
			Q_O   : out std_logic_vector(31 downto 0)
		);
	end component alu;

	signal A_CC : std_logic_vector(2 downto 0) := "000";

	signal L_BUSA : std_logic_vector(31 downto 0) := X"00000000";
	signal L_BUSB : std_logic_vector(31 downto 0) := X"00000000";
	signal L_BUSC : std_logic_vector(31 downto 0) := X"00000000";
begin
	cu : control_unit
		port map(
			I_CLK      => I_CLK,
			I_STALL    => C_STALL,
			I_INSTR    => R_IR,
			I_CC       => A_CC,
			Q_RDIR     => C_RDIR,
			Q_IMM      => C_IMM,
			Q_ALUFC    => C_ALUFC,
			Q_REG      => C_REG,
			Q_LOCKA    => C_LOCKA,
			Q_LOCKB    => C_LOCKB,
			Q_LOCKC    => C_LOCKC,
			Q_RBUS     => C_RBUS,
			Q_BUSR     => C_BUSR,
			Q_PCBUS    => C_PCBUS,
			Q_BUSPC    => C_BUSPC,
			Q_CSRBUS   => C_CSRBUS,
			Q_BUSCSR   => C_BUSCSR,
			Q_SL       => C_SL,
			Q_BUSSEL   => C_BUSSEL,
			Q_PC_INC_4 => C_INC_4
		);
	rf : registerfile
		port map(
			I_CLK => I_CLK,
			I_WE  => C_BUSR,
			I_OE  => C_RBUS,
			I_REG => C_REG,
			I_IN  => L_BUSC,
			Q_OUT => R_OUT
		);
	cf : csrfile
		port map(
			I_CLK => I_CLK,
			I_WE  => C_BUSCSR,
			I_OE  => C_CSRBUS,
			I_ADR => C_IMM(11 downto 0),
			I_IN  => L_BUSC,
			Q_OUT => S_OUT
		);
	ifu : ifetch_unit
		port map(
			I_CLK   => I_CLK,
			I_RDY   => I_RDY,
			I_LDPC  => C_BUSPC,
			I_INC_4 => C_INC_4,
			I_RDIR  => C_RDIR,
			I_SL    => C_SL,
			I_PC    => F_PC,
			I_DATA  => L_DATA,
			I_ADR   => R_CI,
			Q_WR    => F_WR,
			Q_STALL => C_STALL,
			Q_ADR   => Q_ADR,
			Q_IR    => R_IR,
			Q_PC    => R_PC,
			Q_DATA  => F_DATA
		);

	reg_a : reg32
		generic map(
			val => X"00000000"
		)
		port map(
			I_CLK => I_CLK,
			I_D   => L_BUSA,
			I_W   => C_LOCKA,
			Q_D   => R_A
		);
	reg_b : reg32
		generic map(
			val => X"00000000"
		)
		port map(
			I_CLK => I_CLK,
			I_D   => L_BUSB,
			I_W   => C_LOCKB,
			Q_D   => R_B
		);
	reg_c : reg32
		generic map(
			val => X"00000000"
		)
		port map(
			I_CLK => I_CLK,
			I_D   => R_CI,
			I_W   => C_LOCKC,
			Q_D   => R_CO
		);

	alu_t : alu
		port map(
			I_CLK => I_CLK,
			I_A   => R_A,
			I_B   => R_B,
			I_FC  => C_ALUFC,
			Q_CC  => A_CC,
			Q_O   => R_CI
		);

	L_BUSA <= R_PC when C_PCBUS = '1'
		else R_OUT when C_BUSSEL = '0'
		else S_OUT when C_BUSSEL = '1'
	;
	L_BUSB <= R_OUT when C_BUSSEL = '1' else C_IMM;
	L_BUSC <= F_DATA when C_BUSSEL = '1' else R_CO;

	L_DATA <= I_RDT when C_SL(4) = '0' else L_BUSC;
	F_PC <= L_BUSC when C_BUSPC = '1';

	Q_WDT <= F_DATA when F_WR = '1' else "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	Q_WR  <= F_WR;
end architecture RTL;
