library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity random_control_logic is
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
end entity random_control_logic;

architecture RTL of random_control_logic is
	signal L_FUNC_ALU : std_logic_vector(4 downto 0) := "00000";
	signal L_INST_ALU : std_logic_vector(4 downto 0) := "00000";
	signal L_ALUSEL   : std_logic                    := '0';
	signal L_BT       : std_logic                    := '0';

	signal L_REG : std_logic_vector(4 downto 0) := "00000";

	signal L_RST   : std_logic := '0';
	signal L_CSRSC : std_logic := '0';
	signal L_CSRW  : std_logic := '0';
begin
	L_BT <= (I_CYCLE(2) and I_TYPE(24)) 
				and ((I_FUNC(0) and I_CC(0)) 
					or (I_FUNC(1) and not I_CC(0)) 
					or ((I_FUNC(5) or I_FUNC(7)) and ((not I_CC(1) and not I_CC(2))))
					or ((I_FUNC(4) or I_FUNC(6)) and ((I_CC(1) and I_CC(2)))));
					
	L_CSRSC <= I_TYPE(28) and (I_FUNC(2) or I_FUNC(3) or I_FUNC(6) or (I_FUNC(7)));
	L_CSRW <= I_TYPE(28) and (I_FUNC(1) or I_FUNC(5));

	L_ALUSEL                      <= (I_CYCLE(1) and I_TYPE(4)) or (I_CYCLE(2) and I_TYPE(12));
	with I_FUNC select L_FUNC_ALU <=
		"00010" when "000000001",
		"00011" when "100000001",
		"00100" when "010000000",
		"00101" when "001000000",
		"00110" when "000010000",
		"00111" when "000000100",
		"01000" when "000001000",
		"10000" when "000000010",
		"10001" when "000100000",
		"10010" when "100100000",
		"00000" when others;
	L_INST_ALU <= "00001" when ((I_CYCLE(1) = '1' and I_TYPE(13) = '1') or (I_CYCLE(3) = '1' and L_CSRW = '1')) else 
					"00010" when ((I_CYCLE(1) = '1' and (I_TYPE(0) = '1' or I_TYPE(5) = '1')) or (I_CYCLE(4) = '1' and (I_TYPE(24) = '1' or I_TYPE(25) = '1' or I_TYPE(27) = '1'))) else 
					"00011" when (I_CYCLE(2) = '1' and I_TYPE(24) = '1' and I_FUNC(6) = '0' and I_FUNC(7) = '0') else
					"00101" when (I_CYCLE(3) = '1' and (L_CSRSC = '1' and I_FUNC(2) = '1')) else
					"01010" when (I_CYCLE(2) = '1' and I_TYPE(24) = '1' and I_FUNC(6) = '1' and I_FUNC(7) = '0') else
					"01001" when (I_CYCLE(1) = '1' and (I_TYPE(25) = '1' or I_TYPE(27) ='1')) else 
					"01011" when (I_CYCLE(3) = '1' and (L_CSRSC = '1' and I_FUNC(3) = '1')) else
					"00000";

	L_REG    <= I_INSTR(24 downto 20) when (I_CYCLE(1) = '1' and (I_TYPE(12) = '1' or I_TYPE(24) = '1')) else 
				I_INSTR(19 downto 15) when ((I_CYCLE(3) = '1' and I_TYPE(25) = '1') 
										or (I_CYCLE(0) = '1' and (I_TYPE(0) = '1' or I_TYPE(4) = '1' or I_TYPE(12) = '1' or I_TYPE(24) = '1' or L_CSRSC = '1'))) else 
				I_INSTR(11 downto 7) when ((I_CYCLE(3) = '1' and (I_TYPE(5) = '1' or I_TYPE(12) = '1')) 
										or (I_CYCLE(2) = '1' and (I_TYPE(0) = '1' or I_TYPE(4) = '1' or I_TYPE(5) = '1' or I_TYPE(13) = '1' or I_TYPE(25) = '1' or I_TYPE(27) = '1' or L_CSRW = '1' or L_CSRSC = '1'))) 
				else "00000";
					
	L_RST <= (I_CYCLE(2) and ( I_TYPE(4) or I_TYPE(5) or I_TYPE(13) or (not L_BT and I_TYPE(24)))) 
				or (I_CYCLE(3) and (I_TYPE(0) or I_TYPE(12))) 
				or (I_CYCLE(4) and (L_CSRW or L_CSRSC))
				or (I_CYCLE(5) and (I_TYPE(24) or I_TYPE(25) or I_TYPE(27)))
				or not I_TYPE(32);

	Q_REG       <= L_REG;
	Q_ALUFC     <= L_FUNC_ALU when L_ALUSEL = '1' else L_INST_ALU;
	Q_IMMOUT    <= (I_CYCLE(0) and (I_TYPE(0) or I_TYPE(4) or I_TYPE(5) or I_TYPE(13) or L_CSRSC or L_CSRW)) or (I_CYCLE(4) and (L_CSRSC or L_CSRW)) or (I_CYCLE(3) and (I_TYPE(24) or I_TYPE(25) or I_TYPE(27)));
	Q_LOCKA     <= (I_CYCLE(0) and (I_TYPE(0) or I_TYPE(4) or I_TYPE(5) or I_TYPE(12) or I_TYPE(24) or I_TYPE(25) or I_TYPE(27) or L_CSRSC or L_CSRW)) or (I_CYCLE(3) and (I_TYPE(24) or I_TYPE(25) or I_TYPE(27)));
	Q_LOCKB     <= (I_CYCLE(0) and (I_TYPE(0) or I_TYPE(4) or I_TYPE(5) or I_TYPE(13) or L_CSRSC or L_CSRW)) or (I_CYCLE(1) and (I_TYPE(12) or I_TYPE(24))) or (I_CYCLE(3) and (I_TYPE(24) or I_TYPE(25) or I_TYPE(27)));
	Q_LOCKC     <= (I_CYCLE(1) and (I_TYPE(0) or I_TYPE(4) or I_TYPE(5) or I_TYPE(13) or I_TYPE(25) or I_TYPE(27) or L_CSRSC or L_CSRW)) or (I_CYCLE(2) and I_TYPE(12)) or (I_CYCLE(3) and (L_CSRW or L_CSRSC)) or (I_CYCLE(4) and (I_TYPE(24) or I_TYPE(25) or I_TYPE(27)));
	Q_RBUS      <= (I_CYCLE(0) and (I_TYPE(0) or I_TYPE(4) or I_TYPE(12) or I_TYPE(24) or L_CSRSC or L_CSRW)) or (I_CYCLE(1) and (I_TYPE(12) or I_TYPE(24))) or (I_CYCLE(3) and I_TYPE(25));
	Q_BUSR      <= (I_CYCLE(2) and (I_TYPE(0) or I_TYPE(4) or I_TYPE(5) or I_TYPE(13) or I_TYPE(25) or I_TYPE(27) or L_CSRW or L_CSRSC)) or (I_CYCLE(3) and (I_TYPE(0) or I_TYPE(12)));
	Q_PCBUS     <= (I_CYCLE(0) and (I_TYPE(5) or I_TYPE(25) or I_TYPE(27))) or (I_CYCLE(3) and (I_TYPE(24) or I_TYPE(27)));
	Q_BUSPC     <= I_CYCLE(5) and (I_TYPE(24) or I_TYPE(25) or I_TYPE(27));
	Q_BUSSEL    <= ((I_CYCLE(1) and (I_TYPE(24) or I_TYPE(12))) or (I_CYCLE(2) and (I_TYPE(0))) or (I_CYCLE(0) and (L_CSRSC or L_CSRW)));
	Q_CSRBUS    <= (I_CYCLE(0) and (L_CSRSC or L_CSRW));
	Q_BUSCSR    <= (I_CYCLE(4) and (L_CSRW or L_CSRSC));
	Q_SL        <= (I_CYCLE(2) and I_TYPE(0)) & I_INSTR(14 downto 12);
	Q_CYCLE_INC <= '1';
	Q_CYCLE_RST <= L_RST;
	Q_PC_INC_4  <= L_RST and I_TYPE(32);
end architecture RTL;
