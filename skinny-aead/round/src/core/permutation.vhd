library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity PERMUTATION is
    port (X : in  std_logic_vector (127 downto 0);
          Y : out std_logic_vector (127 downto 0));
end PERMUTATION;

architecture PARALLEL of PERMUTATION is

    constant w : integer := 8;

begin

    -- Row 1 ----------------------------------------------------------------------
    Y((16 * w - 1) downto (15 * w)) <= X((7 * w - 1) downto (6 * w));
    Y((15 * w - 1) downto (14 * w)) <= X((1 * w - 1) downto (0 * w));
    Y((14 * w - 1) downto (13 * w)) <= X((8 * w - 1) downto (7 * w));
    Y((13 * w - 1) downto (12 * w)) <= X((3 * w - 1) downto (2 * w));

    -- Row 2 ----------------------------------------------------------------------
    Y((12 * w - 1) downto (11 * w)) <= X((6 * w - 1) downto (5 * w));
    Y((11 * w - 1) downto (10 * w)) <= X((2 * w - 1) downto (1 * w));
    Y((10 * w - 1) downto (9 * w))  <= X((4 * w - 1) downto (3 * w));
    Y((9 * w - 1) downto (8 * w))   <= X((5 * w - 1) downto (4 * w));

    -- Row 3 ----------------------------------------------------------------------
    Y((8 * w - 1) downto (7 * w)) <= X((16 * w - 1) downto (15 * w));
    Y((7 * w - 1) downto (6 * w)) <= X((15 * w - 1) downto (14 * w));
    Y((6 * w - 1) downto (5 * w)) <= X((14 * w - 1) downto (13 * w));
    Y((5 * w - 1) downto (4 * w)) <= X((13 * w - 1) downto (12 * w));

    -- Row 4 ----------------------------------------------------------------------
    Y((4 * w - 1) downto (3 * w)) <= X((12 * w - 1) downto (11 * w));
    Y((3 * w - 1) downto (2 * w)) <= X((11 * w - 1) downto (10 * w));
    Y((2 * w - 1) downto (1 * w)) <= X((10 * w - 1) downto (9 * w));
    Y((1 * w - 1) downto (0 * w)) <= X((9 * w - 1) downto (8 * w));

end PARALLEL;
