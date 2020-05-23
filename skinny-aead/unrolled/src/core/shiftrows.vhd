library ieee;
use ieee.std_logic_1164.all;

entity shiftrows is
    port (x : in  std_logic_vector (127 downto 0);
          y : out std_logic_vector (127 downto 0));
end shiftrows;


architecture parallel of shiftrows is

    constant w : integer := 8;

begin

    y((16*w-1) downto (12*w)) <= x((16*w-1) downto (12*w));
    y((12*w-1) downto (8*w)) <= x((9*w-1) downto (8*w)) & x((12*w-1) downto (9*w));
    y((8*w-1) downto (4*w)) <= x((6*w-1) downto (4*w)) & x((8*w-1) downto (6*w));
    y((4*w-1) downto (0*w)) <= x((3*w-1) downto (0*w)) & x((4*w-1) downto (3*w));

end Parallel;
