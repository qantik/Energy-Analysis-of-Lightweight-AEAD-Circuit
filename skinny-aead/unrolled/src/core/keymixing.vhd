library ieee;
use ieee.std_logic_1164.all;

entity keymixing is
    port (const     : in  std_logic_vector(5 downto 0);
          round_key : in  std_logic_vector(383 downto 0);
          data_in   : in  std_logic_vector(127 downto 0);
          data_out  : out std_logic_vector(127 downto 0));
end keymixing;

architecture parallel of keymixing is

    constant n : integer := 128;
    constant t : integer := 384;
    constant w : integer := 8;

    signal const_addition : std_logic_vector((n-1) downto 0);

begin

    const_addition(127 downto 124) <= data_in(127 downto 124);
    const_addition(123 downto 120) <= data_in(123 downto 120) xor const(3 downto 0);
    const_addition(119 downto 90)  <= data_in(119 downto 90);
    const_addition(89 downto 88)   <= data_in(89 downto 88) xor const(5 downto 4);
    const_addition(87 downto 58)   <= data_in(87 downto 58);
    const_addition(57)             <= not(data_in(57));
    const_addition(56 downto 0)    <= data_in(56 downto 0);

    --data_out((16*w-1) downto (12*w)) <= const_addition((16*w-1) downto (12*w)) xor round_key((2*n+16*w-1) downto (2*n+12*w)) xor round_key((1*n+1*w-1) downto (1*n+12*w)) xor round_key((16*w-1) downto (12*w));
    data_out((16*w-1) DOWNTO (12*w)) <= const_addition((16*w-1) DOWNTO (12*w)) XOR round_key((2*n+16*w-1) DOWNTO (2*n+12*w)) XOR round_key((1*n+16*w-1) DOWNTO (1*n+12*w)) XOR round_key((16*w-1) DOWNTO (12*w));
    data_out((12*w-1) downto (8*w)) <= const_addition((12*w-1) downto (8*w)) xor round_key((2*n+12*w-1) downto (2*n+8*w)) xor round_key((1*n+12*w-1) downto (1*n+8*w)) xor round_key((12*w-1) downto (8*w));

		--DATA_OUT((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY((2 * N + 12 * W - 1) DOWNTO (2 * N +  8 * W)) XOR ROUND_KEY((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY((12 * W - 1) DOWNTO ( 8 * W));

    data_out((8*w-1) downto (4*w)) <= const_addition((8*w-1) downto (4*w));
    data_out((4*w-1) downto (0*w)) <= const_addition((4*w-1) downto (0*w));

end parallel;
