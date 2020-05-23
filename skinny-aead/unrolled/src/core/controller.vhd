library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port (clk       : in  std_logic;
          round_cst : out std_logic_vector (371 downto 0));
end controller;

architecture parallel of controller is
begin

    round_cst <= x"810A14A952A5C993264C9122448912A746ADD9B3468F1E1CB972C50A1C18B16AF5E9D3A7CF9F1EBF7EFDF9F3C70C1";

end parallel;
