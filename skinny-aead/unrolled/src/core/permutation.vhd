library ieee;
use ieee.std_logic_1164.all;

entity permutation is
    port (x : in  std_logic_vector (127 downto 0);
          y : out std_logic_vector (127 downto 0));
end permutation;

architecture parallel of permutation is

    constant w : integer := 8;

begin

    y((16*w-1) downto (15*w)) <= X((7*w-1) downto (6*w));
    y((15*w-1) downto (14*w)) <= X((1*w-1) downto (0*w));
    y((14*w-1) downto (13*w)) <= X((8*w-1) downto (7*w));
    y((13*w-1) downto (12*w)) <= X((3*w-1) downto (2*w));

    y((12*w-1) downto (11*w)) <= X((6*w-1) downto (5*w));
    y((11*w-1) downto (10*w)) <= X((2*w-1) downto (1*w));
    y((10*w-1) downto (9*w))  <= X((4*w-1) downto (3*w));
    y((9*w-1) downto (8*w))   <= X((5*w-1) downto (4*w));

    y((8*w-1) downto (7*w)) <= X((16*w- 1) downto (15*w));
    y((7*w-1) downto (6*w)) <= X((15*w- 1) downto (14*w));
    y((6*w-1) downto (5*w)) <= X((14*w- 1) downto (13*w));
    y((5*w-1) downto (4*w)) <= X((13*w- 1) downto (12*w));

    y((4*w-1) downto (3*w)) <= X((12*w-1) downto (11*w));
    y((3*w-1) downto (2*w)) <= X((11*w-1) downto (10*w));
    y((2*w-1) downto (1*w)) <= X((10*w-1) downto (9*w));
    y((1*w-1) downto (0*w)) <= X((9*w-1) downto (8*w));

end parallel;
