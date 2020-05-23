library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity SHIFTROWS is
    port (X : in  std_logic_vector (127 downto 0);
          Y : out std_logic_vector (127 downto 0));
end SHIFTROWS;

architecture PARALLEL of SHIFTROWS is

    constant w : integer := 8;

begin

    -- ROW 1 ----------------------------------------------------------------------
    Y((16 * w - 1) downto (12 * w)) <= X((16 * w - 1) downto (12 * w));

    -- ROW 2 ----------------------------------------------------------------------
    Y((12 * w - 1) downto (8 * w)) <= X((9 * w - 1) downto (8 * w)) & X((12 * w - 1) downto (9 * w));

    -- ROW 3 ----------------------------------------------------------------------
    Y((8 * w - 1) downto (4 * w)) <= X((6 * w - 1) downto (4 * w)) & X((8 * w - 1) downto (6 * w));

    -- ROW 4 ----------------------------------------------------------------------
    Y((4 * w - 1) downto (0 * w)) <= X((3 * w - 1) downto (0 * w)) & X((4 * w - 1) downto (3 * w));

end PARALLEL;
