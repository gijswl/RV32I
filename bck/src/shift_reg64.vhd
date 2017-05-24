library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity shift_reg64 is
	port(
		I_CLK    : in  std_logic;
		I_D      : in  std_logic_vector(31 downto 0);
		I_W      : in  std_logic;
		I_RST    : in  std_logic;
		I_SHIFT1 : in  std_logic;
		Q_AMT    : out std_logic_vector(1 downto 0);
		Q_D      : out std_logic_vector(31 downto 0)
	);
end entity shift_reg64;

architecture RTL of shift_reg64 is
	signal L_AMT     : std_logic_vector(1 downto 0)  := "00";
	signal L_CONTENT : std_logic_vector(63 downto 0) := X"00000000" & X"00000000";
begin
	process(I_CLK)
	begin
		if (rising_edge(I_CLK)) then
			if (I_RST = '1') then
				L_AMT     <= "00";
				L_CONTENT <= X"00000000" & X"00000000";
			else
				if (I_SHIFT1 = '1' and I_W = '1') then
					case L_AMT is
						when "01"   => L_CONTENT(31 downto 0) <= I_D;
						when "10"   => L_CONTENT(63 downto 32) <= I_D;
						when others => report "Error writing to shift_reg64" severity failure;
					end case;
				else
					if (I_SHIFT1 = '1') then
						L_CONTENT <= SHR(L_CONTENT, CONV_STD_LOGIC_VECTOR(32, 6));
						L_AMT     <= L_AMT - "01";
					end if;
					if (I_W = '1') then
						case L_AMT is
							when "00"   => L_CONTENT(31 downto 0) <= I_D;
							when "01"   => L_CONTENT(63 downto 32) <= I_D;
							when others => report "Tried writing to full shift_reg64" severity failure;
						end case;
						L_AMT <= L_AMT + "01";
					end if;
				end if;
			end if;
		end if;
	end process;

	Q_AMT <= L_AMT;
	Q_D   <= L_CONTENT(31 downto 0);
end architecture RTL;