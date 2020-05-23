library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity ROUNDFUNCTION is
    port (ROUND_CST : in  std_logic_vector (5 downto 0);
          ROUND_KEY : in  std_logic_vector (383 downto 0);
          ROUND_IN  : in  std_logic_vector (127 downto 0);

          ROUND_OUT : out std_logic_vector (127 downto 0));
end ROUNDFUNCTION;

architecture STRUCTURAL of ROUNDFUNCTION is

    constant w : integer := 8;
    constant n : integer := 128;
    constant t : integer := 384;

    signal state_next, substitute, addition, shiftrows : std_logic_vector((n - 1) downto 0);

begin

    SB : for i in 0 to 15 generate
        S : entity WORK.SBOX
            port map (ROUND_in((w * (i + 1) - 1) downto (w * i)), substitute((w * (i + 1) - 1) downto (w * i)));
    end generate;

    KA : entity WORK.KEYMIXING
        port map (ROUND_CST, ROUND_KEY, substitute, addition);
    SR : entity WORK.SHIFTROWS
        port map (addition, shiftrows);
    MC : entity work.MixColumns
        port map (shiftrows, state_next);

    ROUND_OUT <= state_next;

end STRUCTURAL;
