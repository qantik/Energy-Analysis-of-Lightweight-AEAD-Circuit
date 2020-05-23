library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

entity lfsr56 is
    port (
          input         : in  std_logic_vector(55 downto 0);
          output        : out std_logic_vector(55 downto 0)
          );
end;

architecture behaviour of lfsr56 is

begin

    loop1 : for i in 8 to 55 generate
        output(i) <= input(i-1);
    end generate;

    output(7) <= input(6) xor input(55);
    output(6) <= input(5);
    output(5) <= input(4);
    output(4) <= input(3) xor input(55);
    output(3) <= input(2);
    output(2) <= input(1) xor input(55);
    output(1) <= input(0);
    output(0) <= input(55);

end;

