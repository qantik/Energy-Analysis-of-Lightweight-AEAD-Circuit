library ieee;
use ieee.std_logic_1164.all;

entity g_mul is
    generic (CLOCK_GATED : boolean := false);
    port(input  : in std_logic_vector(127 downto 0);

         output : out std_logic_vector(127 downto 0));
end;

architecture behaviour of g_mul is

begin


    main : for i in 0 to 15 generate
        inner: for z in 0 to 6 generate
            output(8*i+z) <= input(8*i+z+1);
        end generate;
            output(8*i+7) <= input(8*i) xor input(8*i+7);
    end generate;


end;

