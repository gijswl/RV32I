library ieee;
use ieee.std_logic_1164.all;

entity itype_decoder is
	port(
		I_INSTR : in  std_logic_vector(6 downto 0);
		Q_TYPE  : out std_logic_vector(32 downto 0)
	);
end entity itype_decoder;

architecture RTL of itype_decoder is
	signal L_VALID32 : std_logic := '1';
begin
	L_VALID32 <= '1' when (I_INSTR(1 downto 0) = "11") else '0';

	Q_TYPE(0)  <= '1' when ((I_INSTR(6 downto 2) = "00000") and L_VALID32 = '1') else '0';
	Q_TYPE(1)  <= '1' when ((I_INSTR(6 downto 2) = "00001") and L_VALID32 = '1') else '0';
	Q_TYPE(2)  <= '1' when ((I_INSTR(6 downto 2) = "00010") and L_VALID32 = '1') else '0';
	Q_TYPE(3)  <= '1' when ((I_INSTR(6 downto 2) = "00011") and L_VALID32 = '1') else '0';
	Q_TYPE(4)  <= '1' when ((I_INSTR(6 downto 2) = "00100") and L_VALID32 = '1') else '0';
	Q_TYPE(5)  <= '1' when ((I_INSTR(6 downto 2) = "00101") and L_VALID32 = '1') else '0';
	Q_TYPE(6)  <= '1' when ((I_INSTR(6 downto 2) = "00110") and L_VALID32 = '1') else '0';
	Q_TYPE(7)  <= '1' when ((I_INSTR(6 downto 2) = "00111") and L_VALID32 = '1') else '0';
	Q_TYPE(8)  <= '1' when ((I_INSTR(6 downto 2) = "01000") and L_VALID32 = '1') else '0';
	Q_TYPE(9)  <= '1' when ((I_INSTR(6 downto 2) = "01001") and L_VALID32 = '1') else '0';
	Q_TYPE(10) <= '1' when ((I_INSTR(6 downto 2) = "01010") and L_VALID32 = '1') else '0';
	Q_TYPE(11) <= '1' when ((I_INSTR(6 downto 2) = "01011") and L_VALID32 = '1') else '0';
	Q_TYPE(12) <= '1' when ((I_INSTR(6 downto 2) = "01100") and L_VALID32 = '1') else '0';
	Q_TYPE(13) <= '1' when ((I_INSTR(6 downto 2) = "01101") and L_VALID32 = '1') else '0';
	Q_TYPE(14) <= '1' when ((I_INSTR(6 downto 2) = "01110") and L_VALID32 = '1') else '0';
	Q_TYPE(15) <= '1' when ((I_INSTR(6 downto 2) = "01111") and L_VALID32 = '1') else '0';
	Q_TYPE(16) <= '1' when ((I_INSTR(6 downto 2) = "10000") and L_VALID32 = '1') else '0';
	Q_TYPE(17) <= '1' when ((I_INSTR(6 downto 2) = "10001") and L_VALID32 = '1') else '0';
	Q_TYPE(18) <= '1' when ((I_INSTR(6 downto 2) = "10010") and L_VALID32 = '1') else '0';
	Q_TYPE(19) <= '1' when ((I_INSTR(6 downto 2) = "10011") and L_VALID32 = '1') else '0';
	Q_TYPE(20) <= '1' when ((I_INSTR(6 downto 2) = "10100") and L_VALID32 = '1') else '0';
	Q_TYPE(21) <= '1' when ((I_INSTR(6 downto 2) = "10101") and L_VALID32 = '1') else '0';
	Q_TYPE(22) <= '1' when ((I_INSTR(6 downto 2) = "10110") and L_VALID32 = '1') else '0';
	Q_TYPE(23) <= '1' when ((I_INSTR(6 downto 2) = "10111") and L_VALID32 = '1') else '0';
	Q_TYPE(24) <= '1' when ((I_INSTR(6 downto 2) = "11000") and L_VALID32 = '1') else '0';
	Q_TYPE(25) <= '1' when ((I_INSTR(6 downto 2) = "11001") and L_VALID32 = '1') else '0';
	Q_TYPE(26) <= '1' when ((I_INSTR(6 downto 2) = "11010") and L_VALID32 = '1') else '0';
	Q_TYPE(27) <= '1' when ((I_INSTR(6 downto 2) = "11011") and L_VALID32 = '1') else '0';
	Q_TYPE(28) <= '1' when ((I_INSTR(6 downto 2) = "11100") and L_VALID32 = '1') else '0';
	Q_TYPE(29) <= '1' when ((I_INSTR(6 downto 2) = "11101") and L_VALID32 = '1') else '0';
	Q_TYPE(30) <= '1' when ((I_INSTR(6 downto 2) = "11110") and L_VALID32 = '1') else '0';
	Q_TYPE(31) <= '1' when ((I_INSTR(6 downto 2) = "11111") and L_VALID32 = '1') else '0';
	Q_TYPE(32) <= L_VALID32;
end architecture RTL;
