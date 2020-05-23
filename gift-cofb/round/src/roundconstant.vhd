library ieee;
use ieee.std_logic_1164.all;

entity roundconstant is
    port (cst_in  : in  std_logic_vector(5 downto 0);
          cst_out : out std_logic_vector (5 downto 0));
end roundconstant;

architecture parallel of roundconstant is
begin

    cst_out <= cst_in(4 downto 0) & (cst_in(4) xnor cst_in(5));

end parallel;
