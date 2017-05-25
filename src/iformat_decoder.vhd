library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity iformat_decoder is
	port(
		I_TYPE   : in  std_logic_vector(32 downto 0);
		Q_FORMAT : out std_logic_vector(5 downto 0)
	);
end entity iformat_decoder;

architecture RTL of iformat_decoder is
begin
	Q_FORMAT(0) <= I_TYPE(3) or I_TYPE(12) or I_TYPE(25);
	Q_FORMAT(1) <= I_TYPE(0) or I_TYPE(4)  or I_TYPE(28);
	Q_FORMAT(2) <= I_TYPE(8);
	Q_FORMAT(3) <= I_TYPE(24);
	Q_FORMAT(4) <= (I_TYPE(5) or I_TYPE(13));
	Q_FORMAT(5) <= I_TYPE(27);
end architecture RTL;
