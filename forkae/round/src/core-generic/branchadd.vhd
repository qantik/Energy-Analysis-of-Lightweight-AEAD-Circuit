library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity BRANCHADD is
    port (DATA_IN   : in std_logic_vector(127 downto 0);

          DATA_OUT : out std_logic_vector(127 downto 0));
end BRANCHADD;

architecture BEHAVIOUR of BRANCHADD is

    constant branch_constants : std_logic_vector(127 downto 0) := x"0102040810204182050A142851A24488";

begin

    DATA_OUT <= DATA_IN xor branch_constants;

end BEHAVIOUR;
