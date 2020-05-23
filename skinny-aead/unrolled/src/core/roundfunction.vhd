library ieee;
use ieee.std_logic_1164.all;

entity roundfunction is
    port (clk       : in  std_logic;
          round_cst : in  std_logic_vector (5 downto 0);
          round_key : in  std_logic_vector (383 downto 0);
          round_in  : in  std_logic_vector (127 downto 0);
          round_out : out std_logic_vector (127 downto 0));
end roundfunction;

architecture structural of roundfunction is

    constant w : integer := 8;
    constant n : integer := 128;
    constant t : integer := 383;

    signal substitute, addition, shiftrows : std_logic_vector((n-1) downto 0);

begin

    sb : for i in 0 to 15 generate
        s : entity work.sbox
            port map (round_in((w*(i+1)-1) downto (w*i)), substitute((w*(i+1)-1) downto (w*i)));
    end generate;

    ka : entity work.keymixing
        port map (round_cst, round_key, substitute, addition);

    sr : entity work.shiftrows
        port map (addition, shiftrows);

    mc : entity work.mixcolumns
        port map (shiftrows, round_out);

end structural;
