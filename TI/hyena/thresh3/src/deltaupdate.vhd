library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity deltaupdate is
  port (delta_in  : in  std_logic_vector(63 downto 0);
        mode      : in  std_logic_vector(1 downto 0); 
        delta_out : out std_logic_vector(63 downto 0));
end deltaupdate;

architecture parallel of deltaupdate is

    signal mul2 : std_logic_vector(63 downto 0);
    signal mul4 : std_logic_vector(63 downto 0);
    signal mul8 : std_logic_vector(63 downto 0);

    constant cst : std_logic_vector(63 downto 0) := X"000000000000001B";
    
begin

    mul2 <= (delta_in(62 downto 0) & "0") xor (cst and (63 downto 0 => delta_in(63))); 
    mul4 <= (mul2(62 downto 0) & "0") xor (cst and (63 downto 0 => mul2(63)));
    mul8 <= (mul4(62 downto 0) & "0") xor (cst and (63 downto 0 => mul4(63)));

    delta_out <= mul8 when mode = "11" else
                 mul4 when mode = "10" else
                 mul2 when mode = "01" else
                 delta_in;

end architecture parallel;
