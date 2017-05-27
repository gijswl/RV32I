library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ifetch_unit is
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
end entity ifetch_unit;

architecture RTL of ifetch_unit is
	constant DEFAULT_RSTVEC : std_logic_vector(31 downto 0) := X"00001000";
	constant HI_Z32         : std_logic_vector(31 downto 0) := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";

	component shift_reg64 is
		port(
			I_CLK    : in  std_logic;
			I_D      : in  std_logic_vector(31 downto 0);
			I_W      : in  std_logic;
			I_RST    : in  std_logic;
			I_SHIFT1 : in  std_logic;
			Q_AMT    : out std_logic_vector(2 downto 0);
			Q_D      : out std_logic_vector(31 downto 0)
		);
	end component shift_reg64;

	signal S_W   : std_logic                     := '0';
	signal S_SH1 : std_logic                     := '0';
	signal S_AMT : std_logic_vector(2 downto 0)  := "000";
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
			I_CLK   : in  std_logic;
			I_INC_4 : in  std_logic;
			I_LD    : in  std_logic;
			I_IN    : in  std_logic_vector(31 downto 0);
			Q_AR    : out std_logic_vector(31 downto 0)
		);
	end component ar_logic;

	signal A_INC_4 : std_logic                     := '0';
	signal A_AR    : std_logic_vector(31 downto 0) := X"00000000";

	signal L_T     : std_logic_vector(3 downto 0)  := "0000";
	signal L_WR    : std_logic                     := '0';
	signal L_UDR   : std_logic                     := '0';
	signal L_ADS   : std_logic                     := '1';
	signal L_ADR   : std_logic_vector(31 downto 0) := X"00000000";
	signal L_DATA1 : std_logic_vector(31 downto 0) := X"00000000";
	signal L_DATA2 : std_logic_vector(31 downto 0) := X"00000000";
	signal L_RDAT  : std_logic_vector(31 downto 0) := X"00000000";
	signal L_WDAT  : std_logic_vector(31 downto 0) := X"00000000";
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
		if (falling_edge(I_CLK)) then
			if (L_T = "0000") then      -- idle state
				A_INC_4 <= '0';

				S_W <= '0';
				S_D <= HI_Z32;

				L_UDR   <= '0';
				L_DATA1 <= X"00000000";
				L_DATA2 <= X"00000000";
				L_WR    <= '0';

				if (I_SL(3) = '1' and I_INC_4 = '0') then
					L_ADR <= I_ADR(31 downto 0);
					L_ADS <= '0';
					if (I_ADR(1 downto 0) = "00" or (I_ADR(1 downto 0) = "10" and (I_SL(2 downto 0) = "001" or I_SL(2 downto 0) = "000")) or ((I_ADR(1 downto 0) = "01" or I_ADR(1 downto 0) = "11") and I_SL(2 downto 0) = "000")) then
						L_T <= "0010";
					else
						L_T <= "0101";
					end if;
				elsif (I_SL(4) = '1' and I_INC_4 = '0') then
					L_DATA1 <= I_DATA;
					L_T     <= "0011";
				elsif ((S_AMT = "000" or S_AMT = "001" or S_AMT = "010") and not S_W = '1') then
					L_ADR <= A_AR;
					L_ADS <= '0';
					L_T   <= "0001";
				end if;
			elsif (L_T = "0001") then   -- fetch 2
				if (I_RDY = '0') then
					A_INC_4 <= '1';
					S_W     <= '1';
					S_D     <= I_DATA;

					L_ADS <= '1';
					L_ADR <= HI_Z32;
					L_T   <= "0000";
				end if;
			elsif (L_T = "0010") then   -- load 2
				if (I_RDY = '0') then
					L_DATA2 <= std_logic_vector(unsigned(I_DATA) srl to_integer(unsigned(I_ADR(1 downto 0) & "000")));
					L_UDR   <= '1';

					L_ADS <= '1';
					L_ADR <= HI_Z32;
					L_T   <= "0000";
				end if;
			elsif (L_T = "0011") then   -- store 2
				if (I_SL(4) = '1') then
					L_ADR <= I_ADR;
					if (I_ADR(1 downto 0) = "00" or (I_ADR(1 downto 0) = "10" and (I_SL(2 downto 0) = "001" or I_SL(2 downto 0) = "000")) or (I_ADR(1 downto 0) = "01" and (I_SL(2 downto 0) = "000" or I_SL(2 downto 0) = "001")) or (I_ADR(1 downto 0) = "11" and I_SL(2 downto 0) = "000")) then
						case I_ADR(1 downto 0) is
							when "00"   => case I_SL(2 downto 0) is
									when "000" => L_WDAT <= (31 downto 8 => '0') & L_DATA1(7 downto 0);
									when "001" => L_WDAT <= (31 downto 16 => '0') & L_DATA1(15 downto 0);
									when "010" => L_WDAT <= L_DATA1;
									when others => L_WDAT <= HI_Z32;
										report "invalid SL" severity warning;
									end case;
							when "01"   => case I_SL(2 downto 0) is
									when "000" => L_WDAT <= (31 downto 16 => '0') & L_DATA1(7 downto 0) & X"00";
									when "001" => L_WDAT <= (31 downto 24 => '0')  & L_DATA1(15 downto 0) & X"00";
									when others => L_WDAT <= HI_Z32;
										report "invalid SL" severity warning;
							end case;
							when "10"   => case I_SL(2 downto 0) is
									when "000" => L_WDAT <= (31 downto 24 => '0') & L_DATA1(7 downto 0) & X"0000";
									when "001" => L_WDAT <= L_DATA1(15 downto 0) & X"0000";
									when others => L_WDAT <= HI_Z32;
										report "invalid SL" severity warning;
								end case;
							when "11"   => L_WDAT <= L_DATA1(7 downto 0) & X"000000";
							when others => L_WDAT <= HI_Z32;
						end case;
						L_ADS <= '0';
						L_WR  <= '1';
						L_T   <= "0100";
					else
						case I_ADR(1 downto 0) is
							when "01"   => case I_SL(2 downto 0) is
									when "010" => L_WDAT  <= L_DATA1(23 downto 0) & X"00";
										L_DATA2 <= X"000000" & L_DATA1(31 downto 24);
									when others => L_WDAT  <= HI_Z32;
										L_DATA2 <= HI_Z32;
										report "invalid SL" severity note;
							end case;
							when "10"   => case I_SL(2 downto 0) is
									when "010" => L_WDAT  <= L_DATA1(15 downto 0) & X"0000";
										L_DATA2 <= X"0000" & L_DATA1(31 downto 16);
									when others => L_WDAT  <= HI_Z32;
										L_DATA2 <= HI_Z32;
										report "invalid SL" severity note;
								end case;
							when "11"   => case I_SL(2 downto 0) is
									when "001" => L_WDAT <= L_DATA1(7 downto 0) & X"000000";
										L_DATA2 <= X"000000" & L_DATA1(15 downto 8);
									when "010" => L_WDAT <= L_DATA1(7 downto 0) & X"000000";
										L_DATA2 <= X"00" & L_DATA1(31 downto 8);
									when others => L_WDAT  <= HI_Z32;
										L_DATA2 <= HI_Z32;
										report "invalid SL" severity note;
								end case;
							when others => L_WDAT <= HI_Z32;
						end case;
						L_ADS <= '0';
						L_WR  <= '1';
						L_T   <= "0111";
					end if;
				end if;
			elsif (L_T = "0100") then   -- store 3
				if (I_RDY = '0') then
					L_ADR <= HI_Z32;
					L_ADS <= '1';
					L_UDR <= '1';
					L_WR  <= '0';
					L_T   <= "0000";
				end if;
			elsif (L_T = "0101") then   -- mload 2
				if (I_RDY = '0') then
					L_DATA1 <= std_logic_vector(unsigned(I_DATA) srl to_integer(unsigned(L_ADR(1 downto 0) & "000")));
					L_UDR   <= '0';

					L_ADS <= '0';
					L_ADR <= L_ADR + "100";
					L_T   <= "0110";
				end if;
			elsif (L_T = "0110") then   -- mload 3
				if (I_RDY = '0') then
					case L_ADR(1 downto 0) is
						when "01" => L_DATA2 <= L_DATA1 or (I_DATA(7 downto 0) & X"000000");
						when "10" => L_DATA2 <= L_DATA1 or (I_DATA(15 downto 0) & X"0000");
						when "11" => L_DATA2 <= L_DATA1 or (I_DATA(24 downto 0) & X"00");
						when others => L_DATA2 <= L_DATA1;
							report "invalid displacement" severity note;
					end case;
					L_ADS <= '1';
					L_ADR <= HI_Z32;
					L_UDR <= '1';
					L_T   <= "0000";
				end if;
			elsif (L_T = "0111") then   -- mstore 2
				if (I_RDY = '0') then
					L_WDAT <= L_DATA2;
					L_ADR  <= L_ADR + "100";
					L_ADS  <= '0';
					L_UDR  <= '0';
					L_WR   <= '1';
					L_T    <= "1000";
				end if;
			elsif (L_T = "1000") then   -- mstore 3
				if (I_RDY = '0') then
					L_WDAT <= HI_Z32;
					L_ADR  <= HI_Z32;
					L_ADS  <= '1';
					L_UDR  <= '1';
					L_WR   <= '0';
					L_T    <= "0000";
				end if;
			else
				report "Invalid IFU state" severity failure;
			end if;
		end if;
	end process;

	S_SH1    <= '1' when (not (S_AMT = "000") and I_RDIR = '1') else '0';
	PC_INC_4 <= I_INC_4;

	with I_SL select L_RDAT <=          --
		(31 downto 8 => L_DATA2(7)) & L_DATA2(7 downto 0) when "01000", --
		(31 downto 16 => L_DATA2(15)) & L_DATA2(15 downto 0) when "01001", --
		L_DATA2 when "01010",           --
		(31 downto 8 => '0') & L_DATA2(7 downto 0) when "01100", --
		(31 downto 16 => '0') & L_DATA2(15 downto 0) when "01101", --
		X"00000000" when others;

	Q_DATA <= L_RDAT when I_SL(3) = '1'
		else L_WDAT when I_SL(4) = '1'
		else HI_Z32;

	Q_ADS   <= L_ADS;
	Q_WR    <= L_WR;
	Q_STALL <= '0' when ((S_AMT = "000" and I_RDIR = '1') or ((I_SL(3) = '1' or L_WR = '1') and L_UDR = '0')) else '1';
	Q_ADR   <= L_ADR;
end architecture RTL;
