library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity KEYMIXING is
    port (CONST     : in std_logic_vector(5 downto 0);
          ROUND_KEY : in std_logic_vector(383 downto 0);
          DATA_IN   : in std_logic_vector(127 downto 0);

          DATA_OUT : out std_logic_vector(127 downto 0));
end KEYMIXING;

architecture BEHAVIOUR of KEYMIXING is

    constant N : integer := 128;
    constant T : integer := 384;
    constant W : integer := 8;

    signal const_addition : std_logic_vector((n - 1) downto 0);

begin

    const_addition(127 downto 124) <= DATA_IN(127 downto 124);
    const_addition(123 downto 120) <= DATA_IN(123 downto 120) xor CONST(3 downto 0);
    const_addition(119 downto 90)  <= DATA_IN(119 downto 90);
    const_addition(89 downto 88)   <= DATA_IN(89 downto 88) xor CONST(5 downto 4);
    const_addition(87 downto 58)   <= DATA_IN(87 downto 58);
    const_addition(57)             <= not(DATA_IN(57));
    const_addition(56 downto 0)    <= DATA_IN(56 downto 0);

    DATA_OUT((16 * w - 1) downto (12 * w)) <= const_addition((16 * w - 1) downto (12 * w)) xor
                                              ROUND_KEY((2 * n + 16 * w - 1) downto (2 * n + 12 * w)) xor
                                              ROUND_KEY((1 * n + 16 * w - 1) downto (1 * n + 12 * w)) xor
                                              ROUND_KEY((16 * w - 1) downto (12 * w));

    DATA_OUT((12 * w - 1) downto (8 * w)) <= const_addition((12 * w - 1) downto (8 * w)) xor
                                             ROUND_KEY((2 * n + 12 * w - 1) downto (2 * n + 8 * w)) xor
                                             ROUND_KEY((1 * n + 12 * w - 1) downto (1 * n + 8 * w)) xor
                                             ROUND_KEY((12 * w - 1) downto (8 * w));

    DATA_OUT((8 * w - 1) downto (4 * w)) <= const_addition((8 * w - 1) downto (4 * w));
    DATA_OUT((4 * w - 1) downto (0 * w)) <= const_addition((4 * w - 1) downto (0 * w));

end BEHAVIOUR;
