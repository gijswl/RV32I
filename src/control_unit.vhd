library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity control_unit is
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
		Q_SL       : out std_logic_vector(3 downto 0);
		Q_BUSSEL   : out std_logic;
		Q_PC_INC_4 : out std_logic
	);
end entity control_unit;

architecture RTL of control_unit is
	component itype_decoder is
		port(
			I_INSTR : in  std_logic_vector(6 downto 0);
			Q_TYPE  : out std_logic_vector(32 downto 0)
		);
	end component itype_decoder;
	component iformat_decoder is
		port(
			I_TYPE   : in  std_logic_vector(32 downto 0);
			Q_FORMAT : out std_logic_vector(5 downto 0)
		);
	end component iformat_decoder;
	component ifunc_decoder
		port(
			I_INSTR  : in  std_logic_vector(31 downto 0);
			I_FORMAT : in  std_logic_vector(5 downto 0);
			Q_FUNC   : out std_logic_vector(8 downto 0)
		);
	end component;

	signal D_TYPE   : std_logic_vector(32 downto 0) := '0' & X"00000000";
	signal D_FORMAT : std_logic_vector(5 downto 0)  := "000000";
	signal D_FUNC   : std_logic_vector(8 downto 0)  := "000000000";

	component cycle_gen is
		port(
			I_CLK   : in  std_logic;
			I_INC   : in  std_logic;
			I_RST   : in  std_logic;
			Q_CYCLE : out std_logic_vector(7 downto 0)
		);
	end component;

	signal C_INC   : std_logic                    := '0';
	signal C_RST   : std_logic                    := '0';
	signal C_CYCLE : std_logic_vector(7 downto 0) := "00000000";

	component random_control_logic is
		port(
			I_INSTR     : in  std_logic_vector(31 downto 0);
			I_TYPE      : in  std_logic_vector(32 downto 0);
			I_FUNC      : in  std_logic_vector(8 downto 0);
			I_CYCLE     : in  std_logic_vector(7 downto 0);
			I_CC        : in  std_logic_vector(2 downto 0);
			Q_REG       : out std_logic_vector(4 downto 0);
			Q_ALUFC     : out std_logic_vector(4 downto 0);
			Q_IMMOUT    : out std_logic;
			Q_LOCKA     : out std_logic;
			Q_LOCKB     : out std_logic;
			Q_LOCKC     : out std_logic;
			Q_RBUS      : out std_logic;
			Q_BUSR      : out std_logic;
			Q_PCBUS     : out std_logic;
			Q_BUSPC     : out std_logic;
			Q_BUSSEL    : out std_logic;
			Q_CSRBUS    : out std_logic;
			Q_BUSCSR    : out std_logic;
			Q_SL        : out std_logic_vector(3 downto 0);
			Q_CYCLE_INC : out std_logic;
			Q_CYCLE_RST : out std_logic;
			Q_PC_INC_4  : out std_logic
		);
	end component random_control_logic;

	signal R_REG    : std_logic_vector(4 downto 0) := "00000";
	signal R_ALUFC  : std_logic_vector(4 downto 0) := "00000";
	signal R_SL     : std_logic_vector(3 downto 0) := "0000";
	signal R_IMMOUT : std_logic                    := '0';
	signal R_LOCKA  : std_logic                    := '0';
	signal R_LOCKB  : std_logic                    := '0';
	signal R_LOCKC  : std_logic                    := '0';
	signal R_RBUS   : std_logic                    := '0';
	signal R_BUSR   : std_logic                    := '0';
	signal R_PCBUS  : std_logic                    := '0';
	signal R_BUSPC  : std_logic                    := '0';
	signal R_BUSSEL : std_logic                    := '0';
	signal R_CSRBUS : std_logic                    := '0';
	signal R_BUSCSR : std_logic                    := '0';
	signal R_INC    : std_logic                    := '0';
	signal R_RST    : std_logic                    := '0';

	signal L_IMM : std_logic_vector(31 downto 0) := X"00000000";
begin
	it_dec : itype_decoder
		port map(
			I_INSTR => I_INSTR(6 downto 0),
			Q_TYPE  => D_TYPE
		);
	ifo_dec : iformat_decoder
		port map(
			I_TYPE   => D_TYPE,
			Q_FORMAT => D_FORMAT
		);
	ifu_dec : ifunc_decoder
		port map(
			I_INSTR  => I_INSTR,
			I_FORMAT => D_FORMAT,
			Q_FUNC   => D_FUNC
		);
	cg : cycle_gen
		port map(
			I_CLK   => I_CLK,
			I_INC   => C_INC,
			I_RST   => C_RST,
			Q_CYCLE => C_CYCLE
		);
	rcl : random_control_logic
		port map(
			I_INSTR     => I_INSTR,
			I_TYPE      => D_TYPE,
			I_FUNC      => D_FUNC,
			I_CYCLE     => C_CYCLE,
			I_CC        => I_CC,
			Q_REG       => R_REG,
			Q_ALUFC     => R_ALUFC,
			Q_IMMOUT    => R_IMMOUT,
			Q_LOCKA     => R_LOCKA,
			Q_LOCKB     => R_LOCKB,
			Q_LOCKC     => R_LOCKC,
			Q_RBUS      => R_RBUS,
			Q_BUSR      => R_BUSR,
			Q_PCBUS     => R_PCBUS,
			Q_BUSPC     => R_BUSPC,
			Q_BUSSEL    => R_BUSSEL,
			Q_CSRBUS    => R_CSRBUS,
			Q_BUSCSR    => R_BUSCSR,
			Q_SL        => R_SL,
			Q_CYCLE_INC => R_INC,
			Q_CYCLE_RST => R_RST,
			Q_PC_INC_4  => Q_PC_INC_4
		);

	C_INC <= I_STALL;
	C_RST <= R_RST and I_STALL;

	with D_FORMAT select L_IMM <=
		((20 downto 0 => I_INSTR(31)) & I_INSTR(30 downto 25) & I_INSTR(24 downto 21) & I_INSTR(20)) when "000010",
		((20 downto 0 => I_INSTR(31)) & I_INSTR(30 downto 25) & I_INSTR(11 downto 8) & I_INSTR(7)) when "000100",
		((19 downto 0 => I_INSTR(31)) & I_INSTR(7) & I_INSTR(30 downto 25) & I_INSTR(11 downto 8) & '0') when "001000",
		(I_INSTR(31) & I_INSTR(30 downto 20) & I_INSTR(19 downto 12) & (11 downto 0 => '0')) when "010000",
		((11 downto 0 => I_INSTR(31)) & I_INSTR(19 downto 12) & I_INSTR(20) & I_INSTR(31 downto 25) & I_INSTR(24 downto 21)) when "100000",
		X"00000000" when others;

	Q_IMM    <= L_IMM when R_IMMOUT = '1' else "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	Q_REG    <= R_REG;
	Q_ALUFC  <= R_ALUFC;
	Q_LOCKA  <= R_LOCKA;
	Q_LOCKB  <= R_LOCKB;
	Q_LOCKC  <= R_LOCKC;
	Q_RBUS   <= R_RBUS;
	Q_BUSR   <= R_BUSR;
	Q_PCBUS  <= R_PCBUS;
	Q_BUSPC  <= R_BUSPC;
	Q_BUSSEL <= R_BUSSEL;
	Q_CSRBUS <= R_CSRBUS;
	Q_BUSCSR <= R_BUSCSR;
	Q_SL     <= R_SL;
	Q_RDIR   <= R_RST;
end architecture RTL;