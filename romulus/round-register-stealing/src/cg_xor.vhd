library ieee;
use ieee.std_logic_1164.all;

entity cg_xor is
    port(clk    : in std_logic;
         enable : in std_logic;

         clken  : out std_logic);
end;

architecture behaviour of cg_xor is

begin

    clken <= clk or enable;
end;

