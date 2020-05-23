library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MIXCOLUMNS is
    port (X : in  std_logic_vector (127 downto 0);
          Y : out std_logic_vector (127 downto 0));
end MIXCOLUMNS;

architecture PARALLEL of MIXCOLUMNS is

    constant w : integer := 8;

    signal c1_x2xo, c2_x2xo, c3_x2xo, c4_x2xo : std_logic_vector((w - 1) downto 0);
    signal c1_x2x1, c2_x2x1, c3_x2x1, c4_x2x1 : std_logic_vector((w - 1) downto 0);

begin

    -- X2 XOR X1 ------------------------------------------------------------------
    c1_x2x1 <= X((12 * w - 1) downto (11 * w)) xor X((8 * w - 1) downto (7 * w));
    c2_x2x1 <= X((11 * w - 1) downto (10 * w)) xor X((7 * w - 1) downto (6 * w));
    c3_x2x1 <= X((10 * w - 1) downto (9 * w)) xor X((6 * w - 1) downto (5 * w));
    c4_x2x1 <= X((9 * w - 1) downto (8 * w)) xor X((5 * w - 1) downto (4 * w));

    -- X2 XOR X0 ------------------------------------------------------------------
    c1_x2xo <= X((16 * w - 1) downto (15 * w)) xor X((8 * w - 1) downto (7 * w));
    c2_x2xo <= X((15 * w - 1) downto (14 * w)) xor X((7 * w - 1) downto (6 * w));
    c3_x2xo <= X((14 * w - 1) downto (13 * w)) xor X((6 * w - 1) downto (5 * w));
    c4_x2xo <= X((13 * w - 1) downto (12 * w)) xor X((5 * w - 1) downto (4 * w));

    -- COLUMN 1 -------------------------------------------------------------------
    Y((16 * w - 1) downto (15 * w)) <= c1_x2xo xor X((4 * w - 1) downto (3 * w));
    Y((12 * w - 1) downto (11 * w)) <= X((16 * w - 1) downto (15 * w));
    Y((8 * w - 1) downto (7 * w))   <= c1_x2x1;
    Y((4 * w - 1) downto (3 * w))   <= c1_x2xo;

    -- COLUMN 2 -------------------------------------------------------------------
    Y((15 * w - 1) downto (14 * w)) <= c2_x2xo xor X((3 * w - 1) downto (2 * w));
    Y((11 * w - 1) downto (10 * w)) <= X((15 * w - 1) downto (14 * w));
    Y((7 * w - 1) downto (6 * w))   <= c2_x2x1;
    Y((3 * w - 1) downto (2 * w))   <= c2_x2xo;

    -- COLUMN 3 -------------------------------------------------------------------
    Y((14 * w - 1) downto (13 * w)) <= c3_x2xo xor X((2 * w - 1) downto (1 * w));
    Y((10 * w - 1) downto (9 * w))  <= X((14 * w - 1) downto (13 * w));
    Y((6 * w - 1) downto (5 * w))   <= c3_x2x1;
    Y((2 * w - 1) downto (1 * w))   <= c3_x2xo;

    -- COLUMN 4 -------------------------------------------------------------------
    Y((13 * w - 1) downto (12 * w)) <= c4_x2xo xor X((1 * w - 1) downto (0 * w));
    Y((9 * w - 1) downto (8 * w))   <= X((13 * w - 1) downto (12 * w));
    Y((5 * w - 1) downto (4 * w))   <= c4_x2x1;
    Y((1 * w - 1) downto (0 * w))   <= c4_x2xo;

end PARALLEL;
