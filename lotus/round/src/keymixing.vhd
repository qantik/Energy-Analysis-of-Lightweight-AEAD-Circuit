library ieee;
use ieee.std_logic_1164.all;

entity keymixing is
    port (round_cst : in  std_logic_vector(5 downto 0);
          round_key : in  std_logic_vector(127 downto 0);
          state_in  : in  std_logic_vector(63 downto 0);
          state_out : out std_logic_vector(63 downto 0));
end entity keymixing;

architecture parallel of keymixing is
    signal temp   : std_logic_vector(63 downto 0);
    signal k0, k1 : std_logic_vector(15 downto 0);
begin

    k0 <= round_key(15 downto 0);
    k1 <= round_key(31 downto 16);

    gen : for i in 0 to 15 generate
        temp(4*i)   <= state_in(4*i) xor k0(i);
        temp(4*i+1) <= state_in(4*i+1) xor k1(i);
        temp(4*i+2) <= state_in(4*i+2);
        temp(4*i+3) <= state_in(4*i+3);
    end generate gen;

    state_out(63)            <= not temp(63);
    state_out(23)            <= temp(23) xor round_cst(5);
    state_out(19)            <= temp(19) xor round_cst(4);
    state_out(15)            <= temp(15) xor round_cst(3);
    state_out(11)            <= temp(11) xor round_cst(2);
    state_out(7)             <= temp(7) xor round_cst(1);
    state_out(3)             <= temp(3) xor round_cst(0);
    state_out(62 downto 24)  <= temp(62 downto 24);
    state_out(22 downto 20)  <= temp(22 downto 20);
    state_out(18 downto 16)  <= temp(18 downto 16);
    state_out(14 downto 12)  <= temp(14 downto 12);
    state_out(10 downto 8)   <= temp(10 downto 8);
    state_out(6 downto 4)    <= temp(6 downto 4);
    state_out(2 downto 0)    <= temp(2 downto 0);

end architecture parallel;

--architecture parallel of keymixing is
--    signal temp   : std_logic_vector(127 downto 0);
--    signal k0, k1 : std_logic_vector(31 downto 0);
--begin
--
--    k0 <= round_key(31 downto 0);
--    k1 <= round_key(95 downto 64);
--
--    temp(63 downto 32)  <= state_in(63 downto 32) xor k1;
--    temp(95 downto 64)  <= state_in(95 downto 64) xor k0;
--    temp(127 downto 96) <= state_in(127 downto 96);
--    temp(31 downto 0)   <= state_in(31 downto 0);
--
--    state_out (31)           <= not temp (31);
--    state_out (5)            <= temp (5) xor round_cst(5);
--    state_out (4)            <= temp (4) xor round_cst(4);
--    state_out (3)            <= temp (3) xor round_cst(3);
--    state_out (2)            <= temp (2) xor round_cst(2);
--    state_out (1)            <= temp (1) xor round_cst(1);
--    state_out (0)            <= temp (0) xor round_cst(0);
--    state_out(127 downto 32) <= temp(127 downto 32);
--    state_out(30 downto 6)   <= temp(30 downto 6);
--
--end architecture parallel;
