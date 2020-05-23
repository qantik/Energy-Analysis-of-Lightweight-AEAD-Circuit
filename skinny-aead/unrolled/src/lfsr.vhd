library ieee;
use ieee.std_logic_1164.all;

entity lfsr is
    port (clk    : in  std_logic;
          reset  : in  std_logic;
          clear  : in  std_logic;
          result : out std_logic_vector(63 downto 0));
end;

architecture behaviour of lfsr is

    constant seed : std_logic_vector(63 downto 0) := X"0000000000000001";
    signal state  : std_logic_vector(63 downto 0);

begin

    regs : process(clk, clear)
        variable y1, y3, y4 : std_logic;
    begin
        if clear = '0' then
            state <= seed;
        elsif rising_edge(clk) then
            if reset = '1' then
                state <= seed;
            else
                y1    := state(0) xor state(63);
                y3    := state(2) xor state(63);
                y4    := state(3) xor state(63);
                state <= state(62 downto 4) & y4 & y3 & state(1) & y1 & state(63);
            end if;
        end if;
    end process;

    rev_0 : for i in 0 to 7 generate
        rev_1 : for j in 0 to 7 generate
            result(63 - ((8 * i) + j)) <= state(63 - ((8 * (7 - i)) + j));
        end generate;
    end generate;

end;
